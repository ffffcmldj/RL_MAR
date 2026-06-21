"""
DeepSeek Single Agent Baseline Experiment for RL_MAR v4 Comparison

This script implements a baseline experiment using DeepSeek API directly,
following the same workflow as the GPT-4o baseline experiments.
"""

import sys
import os
import json
import time
import re
import argparse
import requests
from pathlib import Path
from typing import Dict, List, Any
from datetime import datetime
from loguru import logger

# Load environment variables from .env file
env_file = Path(__file__).parent.joinpath('.env')
if env_file.exists():
    with open(env_file, 'r') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#') and '=' in line:
                key, value = line.split('=', 1)
                os.environ.setdefault(key.strip(), value.strip())

# Add parent directory to path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../..')))

from MAR.Tools.PLC.validators import st_syntax_checker_tool
from comparison.validate_with_codesys import CODESYSValidator

# Pre-compile regex for ST code extraction
ST_CODE_PATTERN = re.compile(r'```st(.*?)```', re.DOTALL | re.MULTILINE)


class DeepSeekClient:
    """Direct DeepSeek API client following official pricing structure"""

    def __init__(self, api_key: str, base_url: str = "https://api.deepseek.com"):
        """
        Initialize DeepSeek client

        Args:
            api_key: API key for the service
            base_url: Base URL for the API
        """
        self.api_key = api_key
        self.base_url = base_url
        self.endpoint = f"{base_url}/v1/chat/completions"
        self.model = "deepseek-chat"  # DeepSeek-V3.2 non-reasoning mode

        # Setup session
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {self.api_key}',
            'Content-Type': 'application/json'
        })

        logger.info(f"DeepSeek client initialized: {self.endpoint}")

    def generate(self, messages: List[Dict[str, str]], temperature: float = 0.3,
                 max_tokens: int = 3000, timeout: int = 120) -> Dict[str, Any]:
        """
        Generate response using DeepSeek API

        Args:
            messages: List of message dictionaries with 'role' and 'content'
            temperature: Sampling temperature
            max_tokens: Maximum tokens to generate
            timeout: Request timeout in seconds

        Returns:
            Dictionary containing response and metadata
        """
        payload = {
            "model": self.model,
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens
        }

        try:
            start_time = time.time()
            response = self.session.post(
                self.endpoint,
                json=payload,
                timeout=timeout
            )
            duration = time.time() - start_time

            if response.status_code == 200:
                result = response.json()

                # Extract content and usage information
                content = result['choices'][0]['message']['content']
                usage = result.get('usage', {})

                # DeepSeek-specific: cache hit/miss information
                prompt_cache_hit_tokens = usage.get('prompt_cache_hit_tokens', 0)
                prompt_tokens = usage.get('prompt_tokens', 0)
                completion_tokens = usage.get('completion_tokens', 0)
                total_tokens = usage.get('total_tokens', 0)

                return {
                    'success': True,
                    'content': content,
                    'raw_response': result,
                    'duration': duration,
                    'prompt_tokens': prompt_tokens,
                    'completion_tokens': completion_tokens,
                    'total_tokens': total_tokens,
                    'prompt_cache_hit_tokens': prompt_cache_hit_tokens,
                    'error': None
                }
            else:
                error_info = response.json() if response.headers.get('content-type', '').startswith('application/json') else response.text
                logger.error(f"DeepSeek API error: {response.status_code} - {error_info}")

                return {
                    'success': False,
                    'content': '',
                    'raw_response': error_info,
                    'duration': duration,
                    'prompt_tokens': 0,
                    'completion_tokens': 0,
                    'total_tokens': 0,
                    'prompt_cache_hit_tokens': 0,
                    'error': f"API call failed: {response.status_code}"
                }

        except requests.exceptions.Timeout:
            logger.error("DeepSeek API timeout")
            return {
                'success': False,
                'content': '',
                'raw_response': None,
                'duration': timeout,
                'prompt_tokens': 0,
                'completion_tokens': 0,
                'total_tokens': 0,
                'prompt_cache_hit_tokens': 0,
                'error': 'Request timeout'
            }

        except Exception as e:
            logger.error(f"DeepSeek API exception: {e}")
            return {
                'success': False,
                'content': '',
                'raw_response': None,
                'duration': 0,
                'prompt_tokens': 0,
                'completion_tokens': 0,
                'total_tokens': 0,
                'prompt_cache_hit_tokens': 0,
                'error': str(e)
            }


class DeepSeekSingleAgentBaseline:
    """
    DeepSeek Single Agent Baseline for PLC Code Generation

    Features:
    - Direct DeepSeek API integration
    - Same workflow as GPT-4o baseline
    - Cost calculation based on official DeepSeek pricing (RMB) with USD conversion
    - Integrated dual validation (ANTLR + CODESYS)
    """

    # DeepSeek official pricing (RMB per million tokens)
    # Source: https://api-docs.deepseek.com/zh-cn/quick_start/pricing
    PRICING_INPUT_CACHE_HIT = 0.2  # RMB per million tokens (cache hit)
    PRICING_INPUT_CACHE_MISS = 2.0  # RMB per million tokens (cache miss)
    PRICING_OUTPUT = 3.0  # RMB per million tokens

    # Exchange rate for uniform comparison (RMB to USD)
    RMB_TO_USD_RATE = 0.138  # As of April 2026 (~7.25 RMB = 1 USD)

    def __init__(self, api_key: str, base_url: str = "https://api.deepseek.com", use_codesys: bool = True):
        """
        Initialize the DeepSeek single agent baseline

        Args:
            api_key: API key for DeepSeek service
            base_url: Base URL for the API
            use_codesys: Whether to use CODESYS validation (auto-detect if True)
        """
        self.deepseek_client = DeepSeekClient(api_key, base_url)

        # Initialize CODESYS validator
        self.codesys_validator = CODESYSValidator() if use_codesys else None

        # System prompt for single agent (same as GPT-4o version)
        self.system_prompt = """You are an expert PLC programmer specializing in Structured Text (ST) language according to IEC 61131-3 standards. Your task is to generate high-quality, syntactically correct ST code based on the given requirements.

Requirements:
1. Follow IEC 61131-3 syntax strictly
2. Use proper variable declarations (VAR_INPUT, VAR_OUTPUT, VAR_IN_OUT, VAR)
3. Implement the logic correctly and efficiently
4. Include proper error handling when specified
5. Output ONLY the ST code block wrapped in ```st ... ``` markers

Generate clean, readable, and maintainable industrial automation code."""

    def calculate_cost(self, prompt_tokens: int, completion_tokens: int,
                      prompt_cache_hit_tokens: int) -> Dict[str, float]:
        """
        Calculate cost based on DeepSeek official pricing

        Args:
            prompt_tokens: Total input tokens
            completion_tokens: Generated output tokens
            prompt_cache_hit_tokens: Tokens that hit the cache

        Returns:
            Dictionary with cost breakdown in USD (for uniform comparison)
        """
        # Calculate cache miss tokens
        prompt_cache_miss_tokens = prompt_tokens - prompt_cache_hit_tokens

        # Calculate input cost (RMB)
        input_cost_cache_hit_rmb = (prompt_cache_hit_tokens / 1_000_000) * self.PRICING_INPUT_CACHE_HIT
        input_cost_cache_miss_rmb = (prompt_cache_miss_tokens / 1_000_000) * self.PRICING_INPUT_CACHE_MISS
        output_cost_rmb = (completion_tokens / 1_000_000) * self.PRICING_OUTPUT

        # Total cost in RMB
        total_cost_rmb = input_cost_cache_hit_rmb + input_cost_cache_miss_rmb + output_cost_rmb

        # Convert to USD for uniform comparison with GPT-4o models
        input_cost_cache_hit_usd = input_cost_cache_hit_rmb * self.RMB_TO_USD_RATE
        input_cost_cache_miss_usd = input_cost_cache_miss_rmb * self.RMB_TO_USD_RATE
        output_cost_usd = output_cost_rmb * self.RMB_TO_USD_RATE
        total_cost_usd = total_cost_rmb * self.RMB_TO_USD_RATE

        return {
            'input_cost_cache_hit_rmb': input_cost_cache_hit_rmb,
            'input_cost_cache_miss_rmb': input_cost_cache_miss_rmb,
            'output_cost_rmb': output_cost_rmb,
            'total_cost_rmb': total_cost_rmb,
            'input_cost_cache_hit_usd': input_cost_cache_hit_usd,
            'input_cost_cache_miss_usd': input_cost_cache_miss_usd,
            'output_cost_usd': output_cost_usd,
            'total_cost_usd': total_cost_usd
        }

    def generate_code(self, task_description: str) -> Dict[str, Any]:
        """
        Generate PLC code for a single task using DeepSeek

        Args:
            task_description: Natural language description of the PLC task

        Returns:
            Dictionary containing generation results and metadata
        """
        start_time = time.time()

        try:
            # Prepare messages (same format as GPT-4o)
            messages = [
                {"role": "system", "content": self.system_prompt},
                {"role": "user", "content": f"Generate the ST function block code for the following task:\n\n{task_description}"}
            ]

            # Generate code using DeepSeek
            api_result = self.deepseek_client.generate(messages)

            if not api_result['success']:
                return {
                    "success": False,
                    "generated_code": "",
                    "raw_response": api_result.get('raw_response', ''),
                    "execution_time": time.time() - start_time,
                    "task_cost_usd": 0.0,
                    "task_cost_rmb": 0.0,
                    "prompt_tokens": 0,
                    "completion_tokens": 0,
                    "total_tokens": 0,
                    "prompt_cache_hit_tokens": 0,
                    "error": api_result['error']
                }

            # Extract code block (same logic as GPT-4o)
            generated_response = api_result['content']
            code_match = ST_CODE_PATTERN.search(generated_response)
            generated_code = code_match.group(1).strip() if code_match else generated_response.strip()

            # Calculate task-specific metrics
            execution_time = time.time() - start_time

            # Calculate cost using DeepSeek pricing
            cost_breakdown = self.calculate_cost(
                api_result['prompt_tokens'],
                api_result['completion_tokens'],
                api_result.get('prompt_cache_hit_tokens', 0)
            )

            return {
                "success": True,
                "generated_code": generated_code,
                "raw_response": generated_response,
                "execution_time": execution_time,
                "task_cost_usd": cost_breakdown['total_cost_usd'],
                "task_cost_rmb": cost_breakdown['total_cost_rmb'],
                "cost_breakdown": cost_breakdown,
                "prompt_tokens": api_result['prompt_tokens'],
                "completion_tokens": api_result['completion_tokens'],
                "total_tokens": api_result['total_tokens'],
                "prompt_cache_hit_tokens": api_result.get('prompt_cache_hit_tokens', 0),
                "error": None
            }

        except Exception as e:
            execution_time = time.time() - start_time
            logger.error(f"Error generating code: {e}")

            return {
                "success": False,
                "generated_code": "",
                "raw_response": "",
                "execution_time": execution_time,
                "task_cost_usd": 0.0,
                "task_cost_rmb": 0.0,
                "prompt_tokens": 0,
                "completion_tokens": 0,
                "total_tokens": 0,
                "prompt_cache_hit_tokens": 0,
                "error": str(e)
            }

    def evaluate_code(self, generated_code: str) -> Dict[str, Any]:
        """
        Evaluate generated code using syntax checker (same as GPT-4o)

        Args:
            generated_code: The generated ST code

        Returns:
            Dictionary containing evaluation results
        """
        try:
            # Use the same syntax checker as the main project
            check_result = st_syntax_checker_tool(generated_code)

            return {
                "syntax_check": check_result,
                "is_solved": check_result.get("passed", False),
                "error_message": check_result.get("error") if not check_result.get("passed") else None
            }
        except Exception as e:
            logger.error(f"Error during code evaluation: {e}")
            return {
                "syntax_check": {"passed": False, "error": str(e)},
                "is_solved": False,
                "error_message": str(e)
            }

    def run_single_task(self, task_id: str, task_description: str, true_category: str) -> Dict[str, Any]:
        """
        Run the complete pipeline for a single task (same as GPT-4o)

        Args:
            task_id: Unique identifier for the task
            task_description: Natural language task description
            true_category: The true category of the task

        Returns:
            Complete result dictionary with dual validation
        """
        logger.info(f"Processing task: {task_id}")

        # Generate code
        generation_result = self.generate_code(task_description)

        # ANTLR Evaluation
        evaluation_result = self.evaluate_code(generation_result["generated_code"])

        # CODESYS Validation (integrated)
        codesys_result = None
        if self.codesys_validator:
            validation_result = self.codesys_validator.validate_code(
                generation_result["generated_code"], task_id
            )
            # Convert to the format expected by the rest of the code
            codesys_result = {
                "compilation_success": validation_result.get("compilation_success", False),
                "errors": validation_result.get("errors", []),
                "available": validation_result.get("response_status") == 200,
                "validation_time": validation_result.get("validation_time", 0.0)
            }

        # Combine results with dual validation (same structure as GPT-4o)
        complete_result = {
            "task_id": task_id,
            "query": task_description,
            "generated_code": generation_result["generated_code"],
            "antlr_validation": {
                "passed": evaluation_result["is_solved"],
                "error": evaluation_result["error_message"]
            },
            "codesys_validation": codesys_result if codesys_result else None,
            "task_cost": generation_result["task_cost_usd"],  # Use USD for uniform comparison
            "task_cost_usd": generation_result["task_cost_usd"],
            "task_cost_rmb": generation_result["task_cost_rmb"],
            "execution_time": generation_result["execution_time"],
            "prompt_tokens": generation_result["prompt_tokens"],
            "completion_tokens": generation_result["completion_tokens"],
            "total_tokens": generation_result["total_tokens"],
            "prompt_cache_hit_tokens": generation_result.get("prompt_cache_hit_tokens", 0),
            "true_category": true_category,
            "method": "single_agent_baseline",
            "model": "deepseek-chat",
            "generation_success": generation_result["success"],
            "generation_error": generation_result["error"]
        }

        # Set final verdict based on available validations (same logic as GPT-4o)
        if codesys_result and codesys_result.get("available", False):
            # CODESYS validation available - use it as final verdict
            compilation_success = codesys_result.get("compilation_success", False)
            complete_result["is_solved"] = compilation_success
            complete_result["error"] = None if compilation_success else codesys_result["errors"][0].get("ErrorDesc") if codesys_result["errors"] else None
        else:
            # CODESYS not available - use ANTLR result
            complete_result["is_solved"] = evaluation_result["is_solved"]
            complete_result["error"] = evaluation_result["error_message"]

        return complete_result


class ExperimentRunner:
    """Manage the complete experiment workflow (same as GPT-4o)"""

    def __init__(self, args):
        self.args = args
        self.baseline = DeepSeekSingleAgentBaseline(
            api_key=args.api_key,
            base_url=args.base_url,
            use_codesys=not args.no_codesys
        )
        self.results = []

        # Setup logging
        log_dir = Path(__file__).parent.parent.joinpath("logs")
        log_dir.mkdir(exist_ok=True)
        log_file = log_dir.joinpath(f"deepseek_baseline_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log")
        logger.add(log_file, level="DEBUG")

    def load_dataset(self) -> List[Dict]:
        """Load the dataset from JSONL file"""
        dataset = []
        try:
            with open(self.args.dataset_path, 'r', encoding='utf-8') as f:
                for line in f:
                    if line.strip():
                        data = json.loads(line)
                        dataset.append(data)
            logger.info(f"Loaded {len(dataset)} tasks from {self.args.dataset_path}")
            return dataset
        except Exception as e:
            logger.error(f"Error loading dataset: {e}")
            raise

    def run_experiment(self):
        """Run the complete experiment"""
        logger.info("Starting DeepSeek Single Agent Baseline Experiment")
        logger.info(f"API: {self.args.base_url}")
        logger.info(f"Dataset: {self.args.dataset_path}")

        # Load dataset
        dataset = self.load_dataset()

        # Process each task
        total_tasks = len(dataset)
        successful_tasks = 0

        for i, task in enumerate(dataset, 1):
            task_id = task.get('task_id', f'task_{i}')
            task_description = task.get('prompt', '')
            true_category = task.get('category', 'Unknown')

            logger.info(f"[{i}/{total_tasks}] Processing {task_id}")

            # Run single task
            result = self.baseline.run_single_task(task_id, task_description, true_category)
            self.results.append(result)

            if result['is_solved']:
                successful_tasks += 1

            # Log progress
            if i % 10 == 0 or i == total_tasks:
                pass_rate = successful_tasks / i * 100
                total_cost_usd = sum(r['task_cost_usd'] for r in self.results)
                total_cost_rmb = sum(r['task_cost_rmb'] for r in self.results)
                logger.info(f"Progress: {i}/{total_tasks} | Pass Rate: {pass_rate:.1f}% | "
                          f"Total Cost: ${total_cost_usd:.4f} (¥{total_cost_rmb:.2f})")

        # Save results
        self.save_results()

        # Print summary
        self.print_summary()

    def save_results(self):
        """Save experiment results to JSON file"""
        results_dir = Path(__file__).parent.parent.joinpath("results")
        results_dir.mkdir(exist_ok=True)

        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        results_file = results_dir.joinpath(f"deepseek_baseline_{timestamp}.json")

        with open(results_file, 'w', encoding='utf-8') as f:
            json.dump(self.results, f, indent=2, ensure_ascii=False)

        logger.info(f"Results saved to {results_file}")

    def print_summary(self):
        """Print experiment summary statistics (same as GPT-4o)"""
        if not self.results:
            logger.warning("No results to summarize")
            return

        # Calculate statistics with dual validation support
        total_tasks = len(self.results)
        solved_tasks = sum(1 for r in self.results if r['is_solved'])
        pass_rate = solved_tasks / total_tasks * 100 if total_tasks > 0 else 0

        # Separate ANTLR and CODESYS pass rates
        antlr_solved = sum(1 for r in self.results if r.get('antlr_validation', {}).get('passed', False))
        antlr_pass_rate = antlr_solved / total_tasks * 100 if total_tasks > 0 else 0

        codesys_available_results = [r for r in self.results if r.get('codesys_validation') and r['codesys_validation'].get('available', False)]
        if codesys_available_results:
            codesys_solved = sum(1 for r in codesys_available_results if r['codesys_validation'].get('compilation_success', False))
            codesys_pass_rate = codesys_solved / len(codesys_available_results) * 100
        else:
            codesys_solved = 0
            codesys_pass_rate = 0

        total_cost_usd = sum(r['task_cost_usd'] for r in self.results)
        total_cost_rmb = sum(r['task_cost_rmb'] for r in self.results)
        total_time = sum(r['execution_time'] for r in self.results)
        total_tokens = sum(r['total_tokens'] for r in self.results)

        avg_cost_usd = total_cost_usd / total_tasks if total_tasks > 0 else 0
        avg_cost_rmb = total_cost_rmb / total_tasks if total_tasks > 0 else 0
        avg_time = total_time / total_tasks if total_tasks > 0 else 0
        avg_tokens = total_tokens / total_tasks if total_tasks > 0 else 0

        # Category-wise statistics
        category_stats = {}
        for result in self.results:
            category = result['true_category']
            if category not in category_stats:
                category_stats[category] = {'total': 0, 'solved': 0, 'cost_usd': 0.0, 'cost_rmb': 0.0, 'antlr_solved': 0, 'codesys_solved': 0}
            category_stats[category]['total'] += 1
            if result['is_solved']:
                category_stats[category]['solved'] += 1
            if result.get('antlr_validation', {}).get('passed', False):
                category_stats[category]['antlr_solved'] += 1
            if result.get('codesys_validation'):
                codesys_success = result['codesys_validation'].get('compilation_success', False)
                if codesys_success:
                    category_stats[category]['codesys_solved'] += 1
            category_stats[category]['cost_usd'] += result['task_cost_usd']
            category_stats[category]['cost_rmb'] += result['task_cost_rmb']

        # Print summary (same format as GPT-4o, with both RMB and USD)
        print("\n" + "=" * 80)
        print(" " * 20 + "DeepSeek Single Agent Baseline Experiment Results")
        print("=" * 80)

        print(f"\n📊 Overall Performance:")
        print(f"   Total Tasks: {total_tasks}")
        print(f"   Solved Tasks: {solved_tasks}")
        print(f"   Final Pass Rate: {pass_rate:.2f}%")

        # Show dual validation breakdown if available
        print(f"\n🔍 Validation Breakdown:")
        print(f"   ANTLR Pass Rate: {antlr_pass_rate:.2f}%")
        if codesys_available_results:
            print(f"   CODESYS Pass Rate: {codesys_pass_rate:.2f}% (n={len(codesys_available_results)})")
        else:
            print(f"   CODESYS Validation: Not available")

        print(f"\n💰 Cost Metrics (USD for comparison):")
        print(f"   Total Cost: ${total_cost_usd:.4f}")
        print(f"   Average Cost/Task: ${avg_cost_usd:.4f}")

        print(f"\n💵 Cost Metrics (RMB - official DeepSeek pricing):")
        print(f"   Total Cost: ¥{total_cost_rmb:.2f}")
        print(f"   Average Cost/Task: ¥{avg_cost_rmb:.2f}")

        print(f"\n⏱️  Time Metrics:")
        print(f"   Total Execution Time: {total_time:.2f}s")
        print(f"   Average Time/Task: {avg_time:.2f}s")
        print(f"   Total Tokens: {total_tokens:,.0f}")
        print(f"   Average Tokens/Task: {avg_tokens:,.0f}")

        print(f"\n📈 Performance by Category:")
        print(f"{'Category':<35} {'Total':>6} {'Final':>6} {'ANTLR':>8} {'CODESYS':>8} {'Avg Cost':>10}")
        print("-" * 80)

        for category in sorted(category_stats.keys()):
            stats = category_stats[category]
            cat_total = stats['total']
            cat_solved = stats['solved']
            cat_pass_rate = cat_solved / cat_total * 100 if cat_total > 0 else 0
            cat_antlr_rate = stats['antlr_solved'] / cat_total * 100 if cat_total > 0 else 0
            cat_codesys_rate = stats['codesys_solved'] / cat_total * 100 if cat_total > 0 else 0
            cat_avg_cost = stats['cost_usd'] / cat_total if cat_total > 0 else 0

            print(f"{category:<35} {cat_total:>6} {cat_solved:>6} {cat_antlr_rate:>7.1f}% {cat_codesys_rate:>7.1f}% ${cat_avg_cost:>9.4f}")

        print("=" * 80)


def main():
    """Main function to run the experiment"""
    parser = argparse.ArgumentParser(
        description="DeepSeek Single Agent Baseline Experiment for PLC Code Generation"
    )

    parser.add_argument(
        '--dataset_path',
        type=str,
        default='Datasets/plcdataset.json',
        help='Path to the dataset JSONL file'
    )

    parser.add_argument(
        '--api_key',
        type=str,
        default=os.environ.get('DEEPSEEK_API_KEY'),
        help='API key for DeepSeek service (default: from .env file)'
    )

    parser.add_argument(
        '--base_url',
        type=str,
        default=os.environ.get('DEEPSEEK_BASE_URL', 'https://api.deepseek.com'),
        help='Base URL for the API (default: from .env file or https://api.deepseek.com)'
    )

    parser.add_argument(
        '--no_codesys',
        action='store_true',
        help='Disable CODESYS validation (use ANTLR only)'
    )

    args = parser.parse_args()

    # Validate required parameters
    if not args.api_key:
        logger.error("API key is required! Set DEEPSEEK_API_KEY in .env file or use --api_key parameter")
        parser.print_help()
        sys.exit(1)

    # Create and run experiment
    runner = ExperimentRunner(args)

    try:
        runner.run_experiment()
    except KeyboardInterrupt:
        logger.info("Experiment interrupted by user")
        if runner.results:
            runner.save_results()
            runner.print_summary()
    except Exception as e:
        logger.error(f"Experiment failed: {e}")
        raise


if __name__ == "__main__":
    main()