import sys
import os
import io
import time
import argparse
import json
import re
import torch
import torch.nn.functional as F
from loguru import logger
from torch.utils.data import DataLoader
from collections import defaultdict
from typing import Dict, List

ST_CODE_PATTERN = re.compile(r'```st(.*?)```', re.DOTALL | re.MULTILINE)

DOMAIN_ORDER = [
    'SequentialLogicControl',
    'ProcessControl',
    'MotionAndSortingControl',
    'DataHandlingAndCommunication',
    'SafetyAndMonitoring'
]

TOPOLOGY_ORDER = ['IO', 'CoT', 'Chain', 'FullConnected', 'Debate', 'Reflection']

_project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.append(_project_root)
sys.path.append(os.path.join(_project_root, 'framework'))
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

from MAR.RL_MAR.RL_MAR import IntelligentPLCRouter
from MAR.LLM.llm_profile import llm_profile
from MAR.LLM.price import get_currency
from MAR.Agent.reasoning_profile import reasoning_profile
from MAR.Prompts.tasks_profile import tasks_profile

from MAR.Tools.PLC.validators import st_syntax_checker_tool
from Datasets.plc_dataset import PLCDataset

os.environ["TOKENIZERS_PARALLELISM"] = "false"

def fix_random_seed(seed=1234):
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False

def configure_logging(print_level="INFO", logfile_level="DEBUG", log_name="log.txt"):
    logger.remove()
    logger.add(sys.stderr, level=print_level)
    logger.add(f'logs/{log_name}', level=logfile_level)

def parse_args():
    parser = argparse.ArgumentParser(description="RL_MAR Experiments on PLC Code Generation")
    parser.add_argument("--data_path", type=str, default="Datasets/plcdataset.json", help="Path to dataset")
    parser.add_argument('--lr', type=float, default=0.01, help="learning rate for the router")
    parser.add_argument('--batch_size', type=int, default=1, help="batch size (recommend 1 for generation tasks)")
    parser.add_argument('--epochs', type=int, default=1, help="Number of epochs")
    parser.add_argument('--prompt_file', type=str, default='MAR/Roles/FinalNode/plc.json', help='Prompt template for Final Node')
    parser.add_argument('--cost_rate', type=float, default=20.0, help="Penalty factor for token cost")
    parser.add_argument('--model', type=str, default=None, help="Force a specific model (e.g., 'DeepSeek-V3.2'). If not set, Router auto-selects from llm_profile.")
    parser.add_argument('--max_agent', type=int, default=6, help="Maximum number of agents allowed")
    parser.add_argument('--train_mode', action='store_true', help="If set, will update router parameters based on syntax check results")
    parser.add_argument('--task_id', type=str, default=None, help="Run a single task by task_id (e.g., 'hf_1')")

    parser.add_argument('--ablation', type=str, default=None,
                        choices=['no_router', 'no_codesys_feedback', 'fixed_topo_io', 'no_domain_roles', 'no_post_process'],
                        help='Ablation mode: disables specific RL_MAR components')

    parser.add_argument('--use_async', action='store_true', help='使用异步并行执行 Agent (性能优化)')
    parser.add_argument('--max_concurrent_agents', type=int, default=3, help='Agent 级最大并发数')
    parser.add_argument('--use_cache', action='store_true', default=True, help='使用静态 Embedding 缓存')
    parser.add_argument('--log_level', type=str, default='INFO', choices=['DEBUG', 'INFO', 'WARNING', 'ERROR'],
                        help='日志级别 (性能优化: 减少日志输出)')

    args = parser.parse_args()
    return args

def collate_fn(batch):
    return batch



class ExperimentMetrics:
    def __init__(self, dataset_data: List[Dict]):
        self.dataset_data = dataset_data
        self.task_to_category = {item['task_id']: item['category'] for item in dataset_data}

        self.samples = []

        self.domain_name_to_idx = {
            'SequentialLogicControl': 0,
            'ProcessControl': 1,
            'MotionAndSortingControl': 2,
            'DataHandlingAndCommunication': 3,
            'SafetyAndMonitoring': 4
        }

    def add_sample(self, task_id: str, query: str, result: str, is_solved: bool,
                   cost: float, utility: float, error_msg: str = None,
                   predicted_domain_idx: int = None, predicted_topology: str = None,
                   num_agents: float = None, latency: float = None,
                   prompt_tokens: int = 0, completion_tokens: int = 0):
        true_category = self.task_to_category.get(task_id, 'Unknown')

        sample = {
            'task_id': task_id,
            'query': query,
            'result': result,
            'is_solved': is_solved,
            'cost': cost,
            'utility': utility,
            'error': error_msg,
            'true_category': true_category,
            'predicted_domain_idx': predicted_domain_idx,
            'predicted_domain_name': self._idx_to_domain_name(predicted_domain_idx) if predicted_domain_idx is not None else None,
            'topology': predicted_topology,
            'num_agents': num_agents,
            'latency': latency,
            'prompt_tokens': prompt_tokens,
            'completion_tokens': completion_tokens,
            'total_tokens': prompt_tokens + completion_tokens,
        }
        self.samples.append(sample)

    def _idx_to_domain_name(self, idx: int) -> str:
        idx_to_name = {v: k for k, v in self.domain_name_to_idx.items()}
        return idx_to_name.get(idx, 'Unknown')

    def compute_and_print(self):
        if not self.samples:
            logger.warning("No samples to compute metrics!")
            return None

        metrics = self._compute_all_metrics()
        self._print_summary_table(metrics)
        self._print_detailed_metrics(metrics)

        return metrics

    def _compute_all_metrics(self) -> Dict:
        total = len(self.samples)
        solved = [s for s in self.samples if s['is_solved']]

        overall_pass_rate = len(solved) / total if total > 0 else 0
        avg_cost = sum(s['cost'] for s in self.samples) / total if total > 0 else 0
        avg_agents = sum(s['num_agents'] for s in self.samples if s['num_agents'] is not None) / total if total > 0 else 0
        avg_latency = sum(s['latency'] for s in self.samples if s['latency'] is not None) / len([s for s in self.samples if s['latency'] is not None]) if total > 0 else 0
        total_cost = sum(s['cost'] for s in self.samples)

        total_prompt_tokens = sum(s.get('prompt_tokens', 0) or 0 for s in self.samples)
        total_completion_tokens = sum(s.get('completion_tokens', 0) or 0 for s in self.samples)
        total_tokens = total_prompt_tokens + total_completion_tokens
        avg_tokens_per_task = total_tokens / total if total > 0 else 0

        domain_stats = {}
        for domain in DOMAIN_ORDER:
            domain_samples = [s for s in self.samples if s['true_category'] == domain]
            domain_solved = [s for s in domain_samples if s['is_solved']]
            domain_stats[domain] = {
                'total': len(domain_samples),
                'solved': len(domain_solved),
                'pass_rate': len(domain_solved) / len(domain_samples) if domain_samples else 0,
                'avg_cost': sum(s['cost'] for s in domain_samples) / len(domain_samples) if domain_samples else 0,
                'avg_agents': sum(s['num_agents'] for s in domain_samples if s['num_agents'] is not None) / len(domain_samples) if domain_samples else 0
            }

        routing_correct = 0
        routing_total = 0
        for s in self.samples:
            if s['predicted_domain_name'] is not None:
                routing_total += 1
                if s['predicted_domain_name'] == s['true_category']:
                    routing_correct += 1
        routing_accuracy = routing_correct / routing_total if routing_total > 0 else 0

        topology_distribution = defaultdict(int)
        topology_solved = defaultdict(int)
        for s in self.samples:
            if s['topology']:
                topology_distribution[s['topology']] += 1
                if s['is_solved']:
                    topology_solved[s['topology']] += 1

        agent_count_dist = defaultdict(int)
        for s in self.samples:
            if s['num_agents'] is not None:
                agent_count_dist[int(s['num_agents'])] += 1

        error_types = defaultdict(int)
        for s in self.samples:
            if not s['is_solved'] and s['error']:
                error = s['error']
                if 'No ST code block' in str(error):
                    error_types['No Code Block'] += 1
                elif 'syntax' in str(error).lower():
                    error_types['Syntax Error'] += 1
                elif 'undeclared' in str(error).lower():
                    error_types['Undeclared Variable'] += 1
                elif 'type' in str(error).lower():
                    error_types['Type Mismatch'] += 1
                else:
                    error_types['Other'] += 1

        domain_routing_acc = {}
        for domain in DOMAIN_ORDER:
            domain_samples = [s for s in self.samples if s['true_category'] == domain]
            if domain_samples:
                correct = sum(1 for s in domain_samples if s['predicted_domain_name'] == domain)
                domain_routing_acc[domain] = correct / len(domain_samples)
            else:
                domain_routing_acc[domain] = 0.0

        return {
            'total_samples': total,
            'overall_pass_rate': overall_pass_rate,
            'overall_solved': len(solved),
            'avg_cost': avg_cost,
            'total_cost': total_cost,
            'avg_agents': avg_agents,
            'avg_latency': avg_latency,
            'total_prompt_tokens': total_prompt_tokens,
            'total_completion_tokens': total_completion_tokens,
            'total_tokens': total_tokens,
            'avg_tokens_per_task': avg_tokens_per_task,
            'domain_stats': domain_stats,
            'routing_accuracy': routing_accuracy,
            'routing_correct': routing_correct,
            'routing_total': routing_total,
            'topology_distribution': dict(topology_distribution),
            'topology_solved': dict(topology_solved),
            'agent_count_dist': dict(agent_count_dist),
            'error_types': dict(error_types),
            'domain_routing_acc': domain_routing_acc
        }

    def _print_summary_table(self, metrics: Dict):
        print("\n" + "=" * 100)
        print(" " * 30 + "RL_MAR: PLC Code Generation Results")
        print("=" * 100)

        print(f"\n{'Domain':<35} {'Pass':>6} {'Total':>6} {'Rate':>8} {'AvgCost':>10} {'AvgAgent':>8}")
        print("-" * 100)

        for domain in DOMAIN_ORDER:
            stats = metrics['domain_stats'].get(domain, {})
            print(f"{domain:<35} {stats.get('solved', 0):>6} {stats.get('total', 0):>6} "
                  f"{stats.get('pass_rate', 0)*100:>7.1f}% ¥{stats.get('avg_cost', 0):>8.4f} {stats.get('avg_agents', 0):>8.1f}")

        print("-" * 100)
        print(f"{'OVERALL':<35} {metrics['overall_solved']:>6} {metrics['total_samples']:>6} "
              f"{metrics['overall_pass_rate']*100:>7.1f}% ¥{metrics['avg_cost']:>8.4f} {metrics['avg_agents']:>8.1f}")
        print("=" * 100)

        print(f"\nTotal Execution Time: {metrics['avg_latency']:.2f}s per task (average)")
        print(f"Total Token Cost: ¥{metrics['total_cost']:.4f}")
        print(f"Total Tokens: {metrics['total_tokens']} (Prompt: {metrics['total_prompt_tokens']}, Completion: {metrics['total_completion_tokens']})")
        print(f"Avg Tokens per Task: {metrics['avg_tokens_per_task']:.0f}")
        print(f"Routing Accuracy: {metrics['routing_accuracy']*100:.1f}% ({metrics['routing_correct']}/{metrics['routing_total']})")

    def _print_detailed_metrics(self, metrics: Dict):
        print("\n" + "=" * 100)
        print(" " * 35 + "Detailed Metrics")
        print("=" * 100)

        print("\n--- Topology Distribution ---")
        print(f"{'Topology':<20} {'Count':>8} {'Solved':>8} {'Success Rate':>15}")
        for topo in TOPOLOGY_ORDER:
            count = metrics['topology_distribution'].get(topo, 0)
            solved = metrics['topology_solved'].get(topo, 0)
            rate = solved / count * 100 if count > 0 else 0
            print(f"{topo:<20} {count:>8} {solved:>8} {rate:>14.1f}%")

        print("\n--- Agent Count Distribution ---")
        for num in sorted(metrics['agent_count_dist'].keys()):
            count = metrics['agent_count_dist'][num]
            print(f"{num} agents: {count} tasks ({count/len(self.samples)*100:.1f}%)")

        print("\n--- Per-Domain Routing Accuracy ---")
        print(f"{'Domain':<35} {'Accuracy':>10}")
        for domain in DOMAIN_ORDER:
            acc = metrics['domain_routing_acc'].get(domain, 0)
            print(f"{domain:<35} {acc*100:>9.1f}%")

        if metrics['error_types']:
            print("\n--- Error Type Distribution ---")
            for error_type, count in metrics['error_types'].items():
                print(f"{error_type}: {count}")

        print("=" * 100)

    def save_metrics(self, filepath: str, metrics: Dict):
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(metrics, f, indent=2, ensure_ascii=False)
        logger.info(f"Metrics saved to {filepath}")

    def get_latex_table(self) -> str:
        lines = []
        lines.append("\\begin{table}[t]")
        lines.append("\\centering")
        lines.append("\\caption{Per-Domain Performance of RL_MAR}")
        lines.append("\\label{tab:per_domain_results}")
        lines.append("\\begin{tabular}{lcccc}")
        lines.append("\\hline")
        lines.append("Domain & Samples & Pass Rate & Avg Cost & Avg Agents \\\\")
        lines.append("\\hline")

        domain_short_names = {
            'SequentialLogicControl': 'Sequential Logic',
            'ProcessControl': 'Process Control',
            'MotionAndSortingControl': 'Motion \\& Sorting',
            'DataHandlingAndCommunication': 'Data Handling',
            'SafetyAndMonitoring': 'Safety \\& Monitoring'
        }

        for domain in DOMAIN_ORDER:
            stats = self._compute_all_metrics()['domain_stats'].get(domain, {})
            short_name = domain_short_names.get(domain, domain)
            lines.append(f"{short_name} & {stats.get('total', 0)} & "
                        f"{stats.get('pass_rate', 0)*100:.1f}\\% & "
                        f"${stats.get('avg_cost', 0):.4f}$ & "
                        f"{stats.get('avg_agents', 0):.1f} \\\\")

        metrics = self._compute_all_metrics()
        lines.append("\\hline")
        lines.append(f"Overall & {metrics['total_samples']} & "
                    f"{metrics['overall_pass_rate']*100:.1f}\\% & "
                    f"${metrics['avg_cost']:.4f}$ & "
                    f"{metrics['avg_agents']:.1f} \\\\")
        lines.append("\\hline")
        lines.append("\\end{tabular}")
        lines.append("\\end{table}")

        return "\n".join(lines)

def main():
    args = parse_args()
    
    fix_random_seed(1234)
    current_time = time.strftime("%Y-%m-%d-%H-%M-%S", time.localtime())
    log_file = f"logs/plc_experiment_{current_time}.log"
    if not os.path.exists("logs"):
        os.makedirs("logs")
    configure_logging(log_name=log_file)

    logger.remove()
    logger.add(sys.stderr, level=args.log_level)
    logger.add(log_file, level="DEBUG")  # 文件保留 DEBUG 级别

    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    logger.info(f"Using device: {device}")
    logger.info(f"Optimization settings: use_async={args.use_async}, "
               f"max_concurrent_agents={args.max_concurrent_agents}, use_cache={args.use_cache}")

    logger.info("Loading PLC Dataset...")
    try:
        dataset = PLCDataset(args.data_path)
    except Exception as e:
        logger.error(f"Failed to load dataset: {e}")
        return

    if args.task_id:
        target_ids = set(args.task_id.split(','))
        filtered = [item for item in dataset.data if item.get('task_id') in target_ids]
        if not filtered:
            logger.error(f"Task(s) '{args.task_id}' not found in dataset. Available tasks: {[item.get('task_id') for item in dataset.data[:10]]}...")
            return
        dataset.data = filtered
        logger.info(f"Running {len(filtered)} tasks: {[item.get('task_id') for item in filtered]}")

    data_loader = DataLoader(dataset, batch_size=args.batch_size, shuffle=False, collate_fn=collate_fn)

    router = IntelligentPLCRouter(max_agent=args.max_agent, device=device, use_cache=args.use_cache, training_mode=args.train_mode).to(device)
    
    optimizer = torch.optim.Adam(router.parameters(), lr=args.lr) if args.train_mode else None
    
    tasks = tasks_profile
    llms = llm_profile
    reasonings = reasoning_profile

    if args.model:
        llms = [m for m in llms if m['Name'] == args.model]
        if not llms:
            available = [m['Name'] for m in llm_profile]
            logger.error(f"Model '{args.model}' not found in llm_profile. Available: {available}")
            sys.exit(1)
        logger.info(f"强制使用模型: {args.model} (Router 模型选择已锁定)")

    model_name = llms[0]['Name'] if llms else "unknown"

    timestamp_str = time.strftime("%Y%m%d_%H%M%S", time.localtime())
    model_safe = model_name.replace('/', '_').replace('\\', '_')
    if args.ablation:
        output_dir = f"Experiments/results/Ablation_{args.ablation}_{model_safe}_{timestamp_str}"
        if args.ablation == 'no_post_process' and args.prompt_file == 'MAR/Roles/FinalNode/plc.json':
            no_pp_prompt = 'plc_no_post_process.json'
            if os.path.exists(no_pp_prompt):
                args.prompt_file = no_pp_prompt
                logger.info(f"消融模式: 自动切换 FinalNode prompt → {no_pp_prompt}")
    else:
        output_dir = f"Experiments/results/RL_MAR_{model_safe}_{timestamp_str}"
    os.makedirs(output_dir, exist_ok=True)
    logger.info(f"结构化输出目录: {output_dir}")

    logger.info(">>> Start Pipeline Execution...")

    if args.ablation == 'no_router':
        import random
        random.seed(42)
        logger.info("消融模式: 固定 random.seed(42) 保证可复现")

    final_results_json = []

    metrics_collector = ExperimentMetrics(dataset.data)

    for epoch in range(args.epochs):
        if args.epochs > 1:
            logger.info(f"=== Epoch {epoch+1}/{args.epochs} ===")

        total_solved = 0
        total_executed = 0
        codesys_validated_count = 0
        codesys_cumulative_pass = 0

        for i_batch, current_batch in enumerate(data_loader):
            start_ts = time.time()
            logger.info(f"--- Batch {i_batch} ---")

            queries = [item['prompt'] for item in current_batch]
            task_ids = [item.get('task_id', f"batch_{i_batch}_{j}") for j, item in enumerate(current_batch)]
            true_categories = [item.get('category', 'Unknown') for item in current_batch]


            if args.train_mode:
                optimizer.zero_grad()

            results, costs, log_probs, tasks_probs, vae_loss, agents_num, prompt_tokens_list, completion_tokens_list, predicted_topologies, retry_counts_list, first_pass_codes_list = router.forward(
                design_specs=queries,           # 左边对应 RL_MAR.py 的新参数名，右边保持原变量 queries
                domain_definitions=tasks,       # tasks -> domain_definitions
                engine_profiles=llms,           # llms -> engine_profiles
                workflow_topologies=reasonings, # collabs -> workflow_topologies
                fixed_domain_idx=None,          # given_task -> fixed_domain_idx
                prompt_file=args.prompt_file,
                use_async_graph=args.use_async,  # 异步并行执行
                max_concurrent_agents=args.max_concurrent_agents,  # 最大并发 Agent 数
                ablation=args.ablation,          # 消融模式
            )

            predicted_domains = []
            predicted_domain_indices = []

            for prob in tasks_probs:
                pred_idx = int(torch.argmax(prob).item())
                predicted_domain_indices.append(pred_idx)
                predicted_domains.append(metrics_collector._idx_to_domain_name(pred_idx))

            logger.info(f"拓扑分布: { {t: predicted_topologies.count(t) for t in set(predicted_topologies)} }")

            utilities = []
            answers_loss = []
            is_solved_list = []

            for j, (query, result, log_prob, cost, true_cat, pred_domain, pred_topo) in enumerate(
                zip(queries, results, log_probs, costs, true_categories, predicted_domains, predicted_topologies)):

                match = ST_CODE_PATTERN.search(result)
                code_content = ""
                if match:
                    code_content = match.group(1).strip()
                    check_result = st_syntax_checker_tool(code_content)
                    is_solved = 1.0 if check_result['passed'] else 0.0
                    if not check_result['passed']:
                         logger.warning(f"Task {task_ids[j]} Syntax Error: {check_result['error'][:100]}...")
                else:
                    is_solved = 0.0
                    check_result = {'error': "No ST code block found"}
                    logger.warning(f"Task {task_ids[j]}: No ```st ... ``` block found.")

                total_solved += is_solved
                total_executed += 1

                utility = is_solved - cost * args.cost_rate
                utilities.append(utility)
                is_solved_list.append(is_solved)

                pred_domain_idx = None
                if pred_domain in metrics_collector.domain_name_to_idx:
                    pred_domain_idx = metrics_collector.domain_name_to_idx[pred_domain]

                retry_count = int(retry_counts_list[j]) if j < len(retry_counts_list) else 0
                first_pass_code = first_pass_codes_list[j] if j < len(first_pass_codes_list) else None
                first_pass_antlr_passed = None
                if first_pass_code:
                    fp_check = st_syntax_checker_tool(first_pass_code)
                    first_pass_antlr_passed = fp_check.get('passed', False)

                num_agents_val = agents_num[j].item() if torch.is_tensor(agents_num[j]) else agents_num[j]
                latency = time.time() - start_ts
                prompt_tok = int(prompt_tokens_list[j]) if j < len(prompt_tokens_list) else 0
                completion_tok = int(completion_tokens_list[j]) if j < len(completion_tokens_list) else 0

                metrics_collector.add_sample(
                    task_id=task_ids[j],
                    query=query,
                    result=result,
                    is_solved=bool(is_solved),
                    cost=float(cost),
                    utility=float(utility),
                    error_msg=check_result.get('error'),
                    predicted_domain_idx=pred_domain_idx,
                    predicted_topology=pred_topo,
                    num_agents=float(num_agents_val),
                    latency=latency,
                    prompt_tokens=prompt_tok,
                    completion_tokens=completion_tok
                )

                final_results_json.append({
                    "task_id": task_ids[j],
                    "query": query,
                    "generated_code": code_content,
                    "is_solved": bool(is_solved),
                    "antlr_validation": {
                        "passed": check_result.get('passed', False),
                        "error": check_result.get('error')
                    },
                    "error": check_result.get('error'),
                    "router_cost": float(cost),
                    "utility": float(utility),
                    "true_category": true_cat,
                    "predicted_domain": pred_domain,
                    "predicted_topology": pred_topo,
                    "num_agents": float(num_agents_val),
                    "execution_time": latency,
                    "prompt_tokens": prompt_tok,
                    "completion_tokens": completion_tok,
                    "total_tokens": prompt_tok + completion_tok,
                    "ablation_mode": args.ablation,
                    "first_pass_antlr_passed": first_pass_antlr_passed,
                    "codesys_retry_count": retry_count,
                })


                if args.train_mode:
                    ans_loss = -log_prob * utility
                    answers_loss.append(ans_loss)

            if args.train_mode and answers_loss:
                answer_loss_tensor = torch.stack(answers_loss).sum() / len(answers_loss)
                vae_loss_mean = vae_loss.mean()
                
                is_solved_tensor = torch.tensor(is_solved_list, dtype=torch.float32, device=device).unsqueeze(1)
                loss = answer_loss_tensor + vae_loss_mean * 0.001
                
                loss.backward()
                optimizer.step()
                
                logger.info(f"Loss: {loss.item():.4f} (Ans: {answer_loss_tensor.item():.4f}, VAE: {vae_loss_mean.item():.4f})")

            batch_acc = sum(is_solved_list) / len(is_solved_list)
            logger.info(f"Batch Time: {time.time() - start_ts:.3f}s | Batch Acc: {batch_acc:.0%}")
            logger.info(f"Generated output preview: {results[0][:100].replace(chr(10), ' ')}...") # 打印第一个结果的前100字符

            tasks_processed = len(final_results_json)
            if tasks_processed - codesys_validated_count >= 15:
                try:
                    from MAR.Tools.PLC.codesys_client import get_codesys_client
                    client = get_codesys_client()
                    new_tasks = final_results_json[codesys_validated_count:]
                    new_pass = 0
                    for item in new_tasks:
                        task_id = item['task_id']
                        code = item.get('generated_code', '')
                        if not code or not code.strip():
                            result = {"success": False, "errors": [{"ErrorDesc": "Empty code"}]}
                        else:
                            result = client.compile_code(code)
                        passed = result.get('success', False)
                        item['codesys_validation'] = {
                            "compilation_success": passed,
                            "errors": result.get("errors", []),
                            "validation_time": result.get("validation_time", 0.0)
                        }
                        item['codesys_passed'] = passed
                        if passed:
                            new_pass += 1
                    codesys_cumulative_pass += new_pass
                    codesys_validated_count = tasks_processed
                    cum_rate = codesys_cumulative_pass / codesys_validated_count * 100
                    logger.info(f"[CODESYS Progress] {codesys_validated_count} tasks validated | "
                                f"This batch: {new_pass}/{len(new_tasks)} | "
                                f"Cumulative: {codesys_cumulative_pass}/{codesys_validated_count} ({cum_rate:.1f}%)")
                except Exception as e:
                    logger.warning(f"Incremental CODESYS validation error: {e}")

        epoch_acc = total_solved / total_executed if total_executed > 0 else 0
        logger.info(f"Epoch {epoch+1} Finished. Total Accuracy: {epoch_acc:.2%}")

        if args.train_mode:
            save_path = f"Experiments/masrouter_plc_epoch{epoch+1}.pth"
            torch.save(router.state_dict(), save_path)
            logger.info(f"Model saved to {save_path}")

    logger.info("\n" + "="*100)
    logger.info("Computing Final Metrics...")
    logger.info("="*100)

    metrics = metrics_collector.compute_and_print()
    metrics['experiment_info'] = {
        'model': model_name,
        'model_timestamp': timestamp_str,
        'train_mode': args.train_mode,
        'cost_rate': args.cost_rate,
        'max_agent': args.max_agent,
        'use_async': args.use_async,
        'data_path': args.data_path,
        'output_dir': output_dir,
        'cost_currency': get_currency(model_name),
        'ablation_mode': args.ablation,
    }

    if args.ablation:
        retry_counts_all = [item.get('codesys_retry_count', 0) for item in final_results_json]
        first_pass_antlr_results = [item.get('first_pass_antlr_passed') for item in final_results_json]
        first_pass_antlr_valid = [x for x in first_pass_antlr_results if x is not None]
        first_pass_passed = sum(1 for x in first_pass_antlr_valid if x)
        first_pass_total = len(first_pass_antlr_valid)

        metrics['ablation_metrics'] = {
            'mode': args.ablation,
            'avg_retry_count': sum(retry_counts_all) / len(retry_counts_all) if retry_counts_all else 0,
            'total_retries': sum(retry_counts_all),
            'tasks_with_retry': sum(1 for r in retry_counts_all if r > 0),
            'first_pass_antlr_pass_rate': first_pass_passed / first_pass_total if first_pass_total > 0 else 0,
            'first_pass_antlr_passed': first_pass_passed,
            'first_pass_antlr_total': first_pass_total,
        }
        logger.info(f"\n[Ablation Metrics] mode={args.ablation}, avg_retry={metrics['ablation_metrics']['avg_retry_count']:.2f}, "
                    f"first_pass_antlr={first_pass_passed}/{first_pass_total} ({metrics['ablation_metrics']['first_pass_antlr_pass_rate']*100:.1f}%)")

    logger.info("\n" + "="*100)
    logger.info(f"CODESYS Validation: {codesys_validated_count} already validated, {len(final_results_json) - codesys_validated_count} remaining...")
    logger.info("="*100)

    codesys_pass_count = codesys_cumulative_pass
    codesys_error_details = []

    try:
        from MAR.Tools.PLC.codesys_client import get_codesys_client
        client = get_codesys_client()

        for item in final_results_json:
            if 'codesys_validation' in item:
                continue

            code = item.get('generated_code', '')
            task_id = item['task_id']

            if not code or not code.strip():
                codesys_result = {"success": False, "errors": [{"ErrorDesc": "Empty code"}], "validation_time": 0.0}
            else:
                logger.info(f"  CODESYS validating {task_id}...")
                codesys_result = client.compile_code(code)

            codesys_passed = codesys_result.get("success", False)
            item['codesys_validation'] = {
                "compilation_success": codesys_passed,
                "errors": codesys_result.get("errors", []),
                "validation_time": codesys_result.get("validation_time", 0.0)
            }
            item['codesys_passed'] = codesys_passed

            if codesys_passed:
                codesys_pass_count += 1
            else:
                for err in codesys_result.get("errors", []):
                    codesys_error_details.append(f"{task_id}: {err.get('ErrorDesc', str(err))}")
    except Exception as e:
        logger.error(f"CODESYS validation error: {e}")
        logger.warning("CODESYS validation skipped.")

    codesys_total = len(final_results_json)

    if codesys_total > 0:
        antlr_pass = sum(1 for item in final_results_json if item.get('is_solved', False))
        codesys_rate = codesys_pass_count / codesys_total * 100
        antlr_rate = antlr_pass / codesys_total * 100

        both_pass = sum(1 for item in final_results_json if item.get('is_solved', False) and item.get('codesys_passed', False))
        both_fail = sum(1 for item in final_results_json if not item.get('is_solved', False) and not item.get('codesys_passed', False))
        antlr_only = antlr_pass - both_pass
        codesys_only = codesys_pass_count - both_pass

        logger.info("")
        logger.info("-" * 100)
        logger.info(f"{'ANTLR vs CODESYS Comparison':^100}")
        logger.info("-" * 100)
        logger.info(f"{'Metric':<40} {'ANTLR':>15} {'CODESYS':>15} {'Diff':>15}")
        logger.info("-" * 100)
        logger.info(f"{'Total Tasks':<40} {codesys_total:>15} {codesys_total:>15} {'N/A':>15}")
        logger.info(f"{'Passed':<40} {antlr_pass:>15} {codesys_pass_count:>15} {codesys_pass_count - antlr_pass:>+15}")
        logger.info(f"{'Pass Rate (%)':<40} {antlr_rate:>15.2f} {codesys_rate:>15.2f} {codesys_rate - antlr_rate:>+15.2f}")
        logger.info("-" * 100)
        logger.info(f"Both passed: {both_pass} | Both failed: {both_fail} | ANTLR only: {antlr_only} | CODESYS only: {codesys_only}")
        logger.info("=" * 100)

        metrics['codesys_validation'] = {
            'total': codesys_total,
            'passed': codesys_pass_count,
            'pass_rate': round(codesys_rate / 100, 4),
            'antlr_pass_rate': round(antlr_rate / 100, 4),
        }
        metrics['codesys_comparison'] = {
            'both_pass': both_pass,
            'both_fail': both_fail,
            'antlr_only': antlr_only,
            'codesys_only': codesys_only,
        }
    else:
        metrics['codesys_validation'] = {
            'total': 0, 'passed': 0, 'pass_rate': 0.0,
            'note': 'CODESYS validation was not performed'
        }


    for item in final_results_json:
        task_file = os.path.join(output_dir, f"{item['task_id']}.st")
        with open(task_file, 'w', encoding='utf-8') as f:
            f.write(item['generated_code'])
    logger.info(f"Per-task ST code files saved to {output_dir}")

    results_summary = []
    for item in final_results_json:
        entry = {
            'task_id': item['task_id'],
            'query': item['query'],
            'generated_code': item['generated_code'],
            'is_solved': item['is_solved'],
            'antlr_validation': item['antlr_validation'],
            'codesys_validation': item.get('codesys_validation', {"compilation_success": False, "errors": [], "validation_time": 0.0}),
            'codesys_passed': item.get('codesys_passed', False),
            'error': item['error'],
            'router_cost': item['router_cost'],
            'utility': item['utility'],
            'true_category': item['true_category'],
            'predicted_domain': item['predicted_domain'],
            'predicted_topology': item['predicted_topology'],
            'num_agents': item['num_agents'],
            'execution_time': item['execution_time'],
            'prompt_tokens': item['prompt_tokens'],
            'completion_tokens': item['completion_tokens'],
            'total_tokens': item['total_tokens'],
            'ablation_mode': item.get('ablation_mode'),
            'first_pass_antlr_passed': item.get('first_pass_antlr_passed'),
            'codesys_retry_count': item.get('codesys_retry_count'),
        }
        results_summary.append(entry)

    results_summary_file = os.path.join(output_dir, 'results_summary.json')
    with open(results_summary_file, 'w', encoding='utf-8') as f:
        json.dump(results_summary, f, indent=2, ensure_ascii=False)
    logger.info(f"Results summary saved to {results_summary_file}")

    metrics_summary_file = os.path.join(output_dir, 'metrics_summary.json')
    metrics_collector.save_metrics(metrics_summary_file, metrics)


if __name__ == '__main__':
    main()
