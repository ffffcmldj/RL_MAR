"""
Qwen3.5-9B Single Agent Baseline Experiment for RL_MAR v4 Comparison

This script implements a baseline experiment using Qwen3.5-9B model via SiliconFlow API,
following the same workflow as other baseline experiments.

API Provider: SiliconFlow (https://api.siliconflow.cn/v1)
Model: Qwen/Qwen3.5-9B
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


class QwenClient:
    """Direct Qwen3.5-9B API client via SiliconFlow"""

    def __init__(self, api_key: str, base_url: str = "https://api.siliconflow.cn/v1"):
        """
        Initialize Qwen client

        Args:
            api_key: API key for SiliconFlow service
            base_url: Base URL for the API
        """
        self.api_key = api_key
        self.base_url = base_url
        self.endpoint = f"{base_url}/chat/completions"
        self.model = "Qwen/Qwen3.5-9B"

        # Setup session
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {self.api_key}',
            'Content-Type': 'application/json'
        })

        logger.info(f"Qwen3.5-9B client initialized: {self.endpoint}")

    def generate(self, messages: List[Dict[str, str]], temperature: float = 0.3,
                 max_tokens: int = 3000, timeout: int = 180) -> Dict[str, Any]:
        """
        Generate response using Qwen3.5-9B API

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
            "max_tokens": max_tokens,
            "enable_thinking": False  # 禁用思考模式，直接生成代码
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

                return {
                    'success': True,
                    'content': content,
                    'raw_response': result,
                    'duration': duration,
                    'prompt_tokens': usage.get('prompt_tokens', 0),
                    'completion_tokens': usage.get('completion_tokens', 0),
                    'total_tokens': usage.get('total_tokens', 0),
                    'error': None
                }
            else:
                error_info = response.json() if response.headers.get('content-type', '').startswith('application/json') else response.text
                logger.error(f"Qwen API error: {response.status_code} - {error_info}")

                return {
                    'success': False,
                    'content': '',
                    'raw_response': error_info,
                    'duration': duration,
                    'prompt_tokens': 0,
                    'completion_tokens': 0,
                    'total_tokens': 0,
                    'error': f"API call failed: {response.status_code}"
                }

        except requests.exceptions.Timeout:
            logger.error("Qwen API timeout")
            return {
                'success': False,
                'content': '',
                'raw_response': None,
                'duration': timeout,
                'prompt_tokens': 0,
                'completion_tokens': 0,
                'total_tokens': 0,
                'error': 'Request timeout'
            }

        except Exception as e:
            logger.error(f"Qwen API exception: {e}")
            return {
                'success': False,
                'content': '',
                'raw_response': None,
                'duration': 0,
                'prompt_tokens': 0,
                'completion_tokens': 0,
                'total_tokens': 0,
                'error': str(e)
            }


class QwenSingleAgentBaseline:
    """
    Qwen3.5-9B Single Agent Baseline for PLC Code Generation

    Features:
    - Direct Qwen3.5-9B API integration via SiliconFlow
    - Same workflow as other baseline experiments
    - Cost and performance tracking with tiered pricing
    - Integrated dual validation (ANTLR + CODESYS)
    """

    def __init__(self, api_key: str, base_url: str = "https://api.siliconflow.cn/v1", use_codesys: bool = True):
        """
        Initialize the Qwen single agent baseline

        Args:
            api_key: API key for SiliconFlow service
            base_url: Base URL for the API
            use_codesys: Whether to use CODESYS validation (auto-detect if True)
        """
        self.qwen_client = QwenClient(api_key, base_url)

        # Initialize CODESYS validator
        self.codesys_validator = CODESYSValidator() if use_codesys else None

        # Pricing configuration (SiliconFlow Qwen3.5-9B)
        # Using 0-128K tier prices (PLC tasks typically use < 10K tokens)
        # Pricing in CNY, converted to USD for consistency with other baselines
        self.cny_to_usd = 0.14  # Exchange rate (approximate)
        self.input_price_cny = 0.50  # ¥0.50/M tokens (0-128K tier)
        self.output_price_cny = 4.00  # ¥4.00/M tokens (0-128K tier)

        # System prompt for single agent
        self.system_prompt = """You are an expert PLC programmer specializing in Structured Text (ST) language according to IEC 61131-3 standards. Generate syntactically correct ST code.

CRITICAL REQUIREMENTS:
1. Follow IEC 61131-3 syntax strictly
2. Use proper variable declarations (VAR_INPUT, VAR_OUTPUT, VAR_IN_OUT, VAR)
3. Implement the logic correctly and efficiently
4. Output ONLY the FUNCTION_BLOCK code wrapped in ```st ... ``` markers
5. NO COMMENTS - Do not include any comments in the generated code
6. Use clear, descriptive variable names for code clarity

CODE STRUCTURE:
- Self-documenting variable names (e.g., "emergencyStop" instead of "es")
- Proper indentation and logical organization
- No explanatory text, no comments, no PROGRAM blocks
- Pure FUNCTION_BLOCK implementation only

Generate efficient, production-ready ST code without comments."""

    def calculate_cost(self, prompt_tokens: int, completion_tokens: int) -> float:
        """
        Calculate cost using SiliconFlow tiered pricing (0-128K tier)
        For PLC tasks, token usage is typically < 10K, so we use the base tier

        Args:
            prompt_tokens: Number of input tokens
            completion_tokens: Number of output tokens

        Returns:
            Cost in USD
        """
        # Calculate cost in CNY using 0-128K tier pricing
        input_cost_cny = (prompt_tokens / 1_000_000) * self.input_price_cny
        output_cost_cny = (completion_tokens / 1_000_000) * self.output_price_cny
        total_cost_cny = input_cost_cny + output_cost_cny

        # Convert to USD
        total_cost_usd = total_cost_cny * self.cny_to_usd

        return total_cost_usd

    def generate_code(self, task_description: str) -> Dict[str, Any]:
        """
        Generate PLC code for a single task using Qwen3.5-9B

        Args:
            task_description: Natural language description of the PLC task

        Returns:
            Dictionary containing generation results and metadata
        """
        start_time = time.time()

        try:
            # Prepare messages
            messages = [
                {"role": "system", "content": self.system_prompt},
                {"role": "user", "content": f"Generate the ST function block code for the following task:\n\n{task_description}"}
            ]

            # Generate code using Qwen
            api_result = self.qwen_client.generate(messages)

            if not api_result['success']:
                return {
                    "success": False,
                    "generated_code": "",
                    "raw_response": api_result.get('raw_response', ''),
                    "execution_time": time.time() - start_time,
                    "task_cost": 0.0,
                    "prompt_tokens": 0,
                    "completion_tokens": 0,
                    "total_tokens": 0,
                    "error": api_result['error']
                }

            # Extract code block
            generated_response = api_result['content']
            code_match = ST_CODE_PATTERN.search(generated_response)
            generated_code = code_match.group(1).strip() if code_match else generated_response.strip()

            # Calculate task-specific metrics
            execution_time = time.time() - start_time

            # Cost calculation using SiliconFlow tiered pricing (0-128K tier)
            task_cost = self.calculate_cost(
                api_result['prompt_tokens'],
                api_result['completion_tokens']
            )

            return {
                "success": True,
                "generated_code": generated_code,
                "raw_response": generated_response,
                "execution_time": execution_time,
                "task_cost": task_cost,
                "prompt_tokens": api_result['prompt_tokens'],
                "completion_tokens": api_result['completion_tokens'],
                "total_tokens": api_result['total_tokens'],
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
                "task_cost": 0.0,
                "prompt_tokens": 0,
                "completion_tokens": 0,
                "total_tokens": 0,
                "error": str(e)
            }

    def evaluate_code(self, generated_code: str) -> Dict[str, Any]:
        """
        Evaluate generated code using syntax checker

        Args:
            generated_code: The generated ST code

        Returns:
            Dictionary containing evaluation results
        """
        # 检查空代码
        if not generated_code or not generated_code.strip():
            logger.warning("Empty code detected, marking as failed")
            return {
                "syntax_check": {"passed": False, "error": "Empty code generated"},
                "is_solved": False,
                "error_message": "Empty code generated"
            }

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
        Run the complete pipeline for a single task

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

        # Combine results with dual validation
        complete_result = {
            "task_id": task_id,
            "query": task_description,
            "generated_code": generation_result["generated_code"],
            "antlr_validation": {
                "passed": evaluation_result["is_solved"],
                "error": evaluation_result["error_message"]
            },
            "codesys_validation": codesys_result if codesys_result else None,
            "task_cost": generation_result["task_cost"],
            "execution_time": generation_result["execution_time"],
            "prompt_tokens": generation_result["prompt_tokens"],
            "completion_tokens": generation_result["completion_tokens"],
            "total_tokens": generation_result["total_tokens"],
            "true_category": true_category,
            "method": "single_agent_baseline",
            "model": "Qwen/Qwen3.5-9B",
            "generation_success": generation_result["success"],
            "generation_error": generation_result["error"]
        }

        # Set final verdict based on available validations
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
    """Manage the complete experiment workflow"""

    def __init__(self, args):
        self.args = args
        self.baseline = QwenSingleAgentBaseline(
            api_key=args.api_key,
            base_url=args.base_url,
            use_codesys=not args.no_codesys
        )
        self.results = []

        # Setup logging
        log_dir = Path(__file__).parent.parent.joinpath("logs")
        log_dir.mkdir(exist_ok=True)
        log_file = log_dir.joinpath(f"qwen_baseline_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log")
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
        logger.info("Starting Qwen3.5-9B Single Agent Baseline Experiment")
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
                total_cost = sum(r['task_cost'] for r in self.results)
                logger.info(f"Progress: {i}/{total_tasks} | Pass Rate: {pass_rate:.1f}% | "
                          f"Total Cost: ${total_cost:.4f}")

        # Save results
        self.save_results()

        # Print summary
        self.print_summary()

    def save_results(self):
        """Save experiment results to JSON file"""
        results_dir = Path(__file__).parent.parent.joinpath("results")
        results_dir.mkdir(exist_ok=True)

        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        results_file = results_dir.joinpath(f"qwen_baseline_{timestamp}.json")

        with open(results_file, 'w', encoding='utf-8') as f:
            json.dump(self.results, f, indent=2, ensure_ascii=False)

        logger.info(f"Results saved to {results_file}")

    def print_summary(self):
        """Print experiment summary statistics"""
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

        total_cost = sum(r['task_cost'] for r in self.results)
        total_time = sum(r['execution_time'] for r in self.results)
        total_tokens = sum(r['total_tokens'] for r in self.results)

        avg_cost = total_cost / total_tasks if total_tasks > 0 else 0
        avg_time = total_time / total_tasks if total_tasks > 0 else 0
        avg_tokens = total_tokens / total_tasks if total_tasks > 0 else 0

        # Category-wise statistics
        category_stats = {}
        for result in self.results:
            category = result['true_category']
            if category not in category_stats:
                category_stats[category] = {'total': 0, 'solved': 0, 'cost': 0.0, 'antlr_solved': 0, 'codesys_solved': 0}
            category_stats[category]['total'] += 1
            if result['is_solved']:
                category_stats[category]['solved'] += 1
            if result.get('antlr_validation', {}).get('passed', False):
                category_stats[category]['antlr_solved'] += 1
            if result.get('codesys_validation'):
                codesys_success = result['codesys_validation'].get('compilation_success', False)
                if codesys_success:
                    category_stats[category]['codesys_solved'] += 1
            category_stats[category]['cost'] += result['task_cost']

        # Print summary
        print("\n" + "=" * 80)
        print(" " * 15 + "Qwen3.5-9B Single Agent Baseline Experiment Results")
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

        print(f"\n💰 Cost Metrics:")
        print(f"   Total Cost: ${total_cost:.4f}")
        print(f"   Average Cost/Task: ${avg_cost:.4f}")

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
            cat_avg_cost = stats['cost'] / cat_total if cat_total > 0 else 0

            print(f"{category:<35} {cat_total:>6} {cat_solved:>6} {cat_antlr_rate:>7.1f}% {cat_codesys_rate:>7.1f}% ${cat_avg_cost:>9.4f}")

        print("=" * 80)
        print("\n📝 Pricing Information:")
        print(f"   API Provider: SiliconFlow (https://api.siliconflow.cn/v1)")
        print(f"   Model: Qwen/Qwen3.5-9B")
        print(f"   Pricing Tier: 0-128K tokens (PLC tasks typically use < 10K tokens)")
        print(f"   Input Price: ¥{self.baseline.input_price_cny:.2f}/M tokens ≈ ${self.baseline.input_price_cny * self.baseline.cny_to_usd:.4f}/M tokens")
        print(f"   Output Price: ¥{self.baseline.output_price_cny:.2f}/M tokens ≈ ${self.baseline.output_price_cny * self.baseline.cny_to_usd:.4f}/M tokens")
        print(f"   Exchange Rate Used: 1 CNY = ${self.baseline.cny_to_usd:.2f} USD")
        print("=" * 80)


def main():
    """Main function to run the experiment"""
    parser = argparse.ArgumentParser(
        description="Qwen3.5-9B Single Agent Baseline Experiment for PLC Code Generation"
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
        default=os.environ.get('QWEN_API_KEY'),
        help='API key for SiliconFlow service (default: from .env file)'
    )

    parser.add_argument(
        '--base_url',
        type=str,
        default=os.environ.get('QWEN_BASE_URL', 'https://api.siliconflow.cn/v1'),
        help='Base URL for the API (default: from .env file or https://api.siliconflow.cn/v1)'
    )

    parser.add_argument(
        '--no_codesys',
        action='store_true',
        help='Disable CODESYS validation (use ANTLR only)'
    )

    args = parser.parse_args()

    # Validate required parameters
    if not args.api_key:
        logger.error("API key is required! Set QWEN_API_KEY in .env file or use --api_key parameter")
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
