# RL-MAR: 基于强化学习的多 Agent 路由可验证 PLC 代码生成

本仓库包含 RL-MAR 的源代码与实验结果。RL-MAR 是一个神经符号多 Agent 框架，可根据自然语言需求自动生成符合 IEC 61131-3 标准的 Structured Text (ST) 代码。

![](PLC_paper_picture/PLC%20Agent%20Framework.png)

RL-MAR 通过可学习路由器进行控制域分类、执行拓扑规划与专家 Agent 团队调度。生成的代码经过 ANTLR 语法检查与 CODESYS 编译验证。实验选用了 GPT-4o、DeepSeek-V3.2、Qwen3.5-9B 等主流 LLM，框架兼容任意 OpenAI 兼容 API。

**执行流程**：域分类 → 拓扑规划 → Agent 角色分配 → 多 Agent DAG 并行执行 → CODESYS 编译与重试修正 → 输出验证后的 ST 代码。同层 Agent 线程池并行执行，跨轮次通过 temporal memory 传递上下文。路由器通过策略梯度训练，平衡验证成功率与推理成本。

基准数据集包含 94 个 PLC 编程任务，覆盖 5 个控制域：顺序逻辑控制、过程控制、运动与分拣控制、数据处理与通信、安全与监控。

## 目录结构

```
├── framework/                     # 核心框架
│   ├── MAR/                       # Agent、Graph、Router、LLM、Roles、Tools
│   ├── Datasets/                  # 基准数据集
│   └── CODESYSCompileService/     # CODESYS HTTP 编译服务
├── experiments/                   # 实验与结果
│   ├── run_plc.py                 # 主实验入口
│   ├── comparison/                # 对比实验结果
│   └── results/ablation/          # 消融实验结果
└── PLC_paper_picture/             # 论文图表
```

## 环境安装

推荐在 Windows 系统上运行，Python 3.8 及以上版本。

1. 安装依赖：

```bash
pip install -r framework/requirements.txt
pip install antlr4-python3-runtime==4.13.1
```

2. 配置环境变量。复制模板文件并填入你的 API 密钥：

```bash
cp framework/template.env framework/.env
# 编辑 .env，填入 LLM 服务商的 URL 和 Key
```

3. CODESYS 编译服务（可选，仅编译验证需要）：

RL-MAR 使用基于 CODESYS 的 HTTP 编译服务来验证生成的 ST 代码。需要 Windows 系统上安装 CODESYS V3.5 SP20 及 ScriptEngine。详见 [CODESYSCompileService](https://github.com/cangkui/CODESYSCompileService)。

```bash
pip install -r framework/CODESYSCompileService/requirements.txt
cd framework/CODESYSCompileService
python HTTP_SERVER.py    # 默认监听 0.0.0.0:9000
```

在 `.env` 中配置 `CODESYS_HOST` 和 `CODESYS_PORT`。不使用 CODESYS 时，框架仍可通过 ANTLR 进行语法检查。

## 运行 RL-MAR

在 94 任务基准上运行主实验：

```bash
cd framework
python ../experiments/run_plc.py \
  --data_path Datasets/plcdataset.json \
  --use_async --max_concurrent_agents 3 \
  --model deepseek-ai/DeepSeek-V3.2
```

单任务调试：

```bash
python ../experiments/run_plc.py --task_id hf_1 --use_async --log_level DEBUG
```


## 致谢

感谢 [LLM4PLC](https://github.com/fakih-/LLM4PLC) 和 [AutoPLC](https://github.com/cangkui/AutoPLC) 作者的开源实现。CODESYS 编译服务基于 [CODESYSCompileService](https://github.com/cangkui/CODESYSCompileService)。形式化验证使用了 [Agents4PLC](https://github.com/Luoji-zju/Agents4PLC_release) 的基准数据集与工具链。
