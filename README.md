# RL-MAR: Reinforcement Learning-based Multi-Agent Routing for Verifiable PLC Code Generation

[👉 中文版本](README_zh.md)

This repository contains the source code and experiment results for RL-MAR, a neural-symbolic multi-agent framework that generates IEC 61131-3 Structured Text (ST) code from natural-language specifications.

![](PLC_paper_picture/PLC%20Agent%20Framework.png)

RL-MAR uses a learned router to classify control domains, plan execution topologies, and dispatch specialized agent teams. The generated code is validated through ANTLR syntax checking and CODESYS compilation. Our experiments use mainstream LLMs accessible via OpenAI-compatible APIs (GPT-4o, DeepSeek-V3.2, Qwen3.5-9B, etc.); the framework works with any compatible provider.

**Pipeline**: Domain Classification → Topology Planning → Agent Role Dispatch → Multi-Agent DAG Execution → CODESYS Compile & Retry → Verified ST Code. Agents run in parallel within DAG layers, with cross-round temporal memory. The router is trained via policy gradient to balance validation success and inference cost.

The benchmark dataset contains 94 PLC programming tasks across 5 control domains: Sequential Logic, Process Control, Motion & Sorting, Data Handling, and Safety & Monitoring.

## Directory Structure

```
├── framework/                     # Core framework
│   ├── MAR/                       # Agent, Graph, Router, LLM, Roles, Tools
│   ├── Datasets/                  # Benchmark dataset
│   └── CODESYSCompileService/     # CODESYS HTTP compilation service
├── experiments/                   # Experiments and results
│   ├── run_plc.py                 # Main experiment entry point
│   ├── comparison/                # Baseline comparison results
│   └── results/ablation/          # Ablation study results
└── PLC_paper_picture/             # Paper figures
```

## Installation

We recommend running RL-MAR on Windows with Python 3.8+.

1. Install dependencies:

```bash
pip install -r framework/requirements.txt
pip install antlr4-python3-runtime==4.13.1
```

2. Environment setup. Copy the template and fill in your API key:

```bash
cp framework/template.env framework/.env
# Edit .env with your LLM provider URL and key
```

3. CODESYS Compilation Service (optional, for compilation validation):

RL-MAR uses a CODESYS-based HTTP compilation service to validate generated ST code. This requires CODESYS V3.5 SP20 with ScriptEngine on Windows. See [CODESYSCompileService](https://github.com/cangkui/CODESYSCompileService) for setup.

```bash
pip install -r framework/CODESYSCompileService/requirements.txt
cd framework/CODESYSCompileService
python HTTP_SERVER.py    # Listens on 0.0.0.0:9000
```

Set `CODESYS_HOST` and `CODESYS_PORT` in `.env` accordingly. ANTLR-based syntax checking works without CODESYS.

## Running RL-MAR

Main experiment on the 94-task benchmark:

```bash
cd framework
python ../experiments/run_plc.py \
  --data_path Datasets/plcdataset.json \
  --use_async --max_concurrent_agents 3 \
  --model deepseek-ai/DeepSeek-V3.2
```

Single-task debugging:

```bash
python ../experiments/run_plc.py --task_id hf_1 --use_async --log_level DEBUG
```


## Acknowledgments

We thank the authors of [LLM4PLC](https://github.com/fakih-/LLM4PLC) and [AutoPLC](https://github.com/cangkui/AutoPLC) for their open-source implementations. The CODESYS compilation service is based on [CODESYSCompileService](https://github.com/cangkui/CODESYSCompileService). Formal verification uses the benchmark and toolchain from [Agents4PLC](https://github.com/Luoji-zju/Agents4PLC_release).
