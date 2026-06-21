from typing import List, Dict, Optional
import os
import json
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.special import gammaln
import math

from MAR.LLM.llm_embedding import SentenceEncoder
from MAR.Graph.graph import DynamicEngineeringTopology as Graph
from MAR.Utils.ablation_config import set_ablation_mode
from MAR.Utils.utils import get_kwargs
from MAR.Utils.globals import Cost, PromptTokens, CompletionTokens
from loguru import logger
from sentence_transformers import SentenceTransformer

# ==============================================================================
# 模块名称：SpecContextAligner (原 GFusion)
# 工业定义：规范-上下文对齐器。通过注意力机制将技术规范信号与生成上下文信号进行相位对齐。
# ==============================================================================
class SpecContextAligner(nn.Module):
    def __init__(self, d_model:int=384):
        """
        Constraint-Context Alignment Mechanism.
        Uses multi-head attention to align technical specifications (Query) with 
        generation context, ensuring IEC 61131-3 compliance.
        Input: x (Spec Signal), y (Context Signal)
        Output: z (Aligned Signal)
        """
        super().__init__()
        self.query_proj = nn.Linear(d_model, d_model)
        self.key_proj = nn.Linear(d_model, d_model)
        self.value_proj = nn.Linear(d_model, d_model)
        self.out_proj = nn.Linear(d_model, d_model)

    def forward(self, x, y):
        Q = self.query_proj(x)      # [xx, d]
        K = self.key_proj(y)        # [yy, d]
        V = self.value_proj(y)      # [yy, d]

        # 计算信号相关性 (Signal Correlation)
        attn_scores = torch.matmul(Q, K.transpose(0, 1)) / (Q.size(-1) ** 0.5)
        attn_weights = F.softmax(attn_scores, dim=-1)  # [xx, yy]
        
        # 上下文注入
        context = torch.matmul(attn_weights, V)  # context: [xx, d]
        context = F.normalize(context, p=2, dim=1)
        
        # 混合输出
        z = self.out_proj(x + context)  # [xx, d]
        return z

# 定义系统噪声参数，用于逻辑流形采样
std2 = 0.1
var2 = std2 * std2
log_var2 = math.log(var2)

# ==============================================================================
# 模块名称：LogicFeatureExtractor (原 VAE)
# 工业定义：逻辑特征提取器。学习离散控制逻辑的潜在流形表示 (Latent Logic Manifold)。
# ==============================================================================
class LogicFeatureExtractor(nn.Module):
    def __init__(self, input_dim=384, hidden_dim=64, latent_dim=64):
        """
        Latent Logic Representation Learner.
        Compresses discrete PLC logic patterns into a continuous manifold.
        """
        super(LogicFeatureExtractor, self).__init__()
        # Feature Extraction (Encoder)
        self.fc1 = nn.Linear(input_dim, hidden_dim)
        self.fc21 = nn.Linear(hidden_dim, latent_dim) # Mean
        self.fc22 = nn.Linear(hidden_dim, latent_dim) # Uncertainty (LogVar)
        # Reconstruction (Decoder)
        self.fc3 = nn.Linear(latent_dim, hidden_dim)
        self.fc4 = nn.Linear(hidden_dim, input_dim)

    def encode(self, x):
        h = F.relu(self.fc1(x))
        return self.fc21(h), self.fc22(h)  # feature_mean, uncertainty_log_var

    def reparameterize(self, mu, log_var):
        # Logic Manifold Sampling (逻辑流形采样)
        std = torch.exp(0.5 * log_var)*std2
        eps = torch.randn_like(std)
        return mu + eps * std

    def decode(self, z):
        h = F.relu(self.fc3(z))
        return self.fc4(h) # x_hat

    def forward(self, x):
        mu, log_var = self.encode(x)
        z = self.reparameterize(mu, log_var)
        x_hat = self.decode(z)
        return x_hat, z, mu, log_var

def compliance_metric_function(x_hat, x, mu, log_var):
    """
    Compliance Metric (原 Loss Function).
    Measures Reconstruction Fidelity (MSE) and Distribution Regularization (KLD).
    """
    MSE = F.mse_loss(x_hat, x, reduction='mean')
    KLD = -0.5 * torch.mean(1 - log_var2 + log_var - (mu.pow(2) + log_var.exp())/var2)
    return MSE + KLD

# ==============================================================================
# 主类名称：IntelligentPLCRouter (RL_MAR)
# 工业定义：智能 PLC 路由器。基于神经符号架构的自动化工程调度引擎。
# ==============================================================================
class IntelligentPLCRouter(nn.Module):
    """
    Intelligent PLC Router for IEC 61131-3 Code Generation.
    
    Modules:
    1. ControlDomainClassifier: Identifies if the task is Motion, Safety, or Process Control.
    2. WorkflowTopologyPlanner: Determines the engineering workflow (Chain, Star, Debate).
    3. ResourceScaleEstimator: Estimates the number of functional modules required.
    4. EngineeringRoleDispatcher: Assigns specific engineering roles (Architect, Coder, Validator).
    5. ModelInferenceScheduler: Routes tasks to the optimal Inference Engine.
    """
    def __init__(self, in_dim:int = 384, hidden_dim:int = 64, max_agent:int = 6, temp:float=0.5, device=None,
                 use_cache: bool = True, training_mode: bool = False):
        super().__init__()
        self.device = device if device is not None else torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        self.use_cache = use_cache
        self.training_mode = training_mode  # 是否为训练模式

        # 核心组件初始化 (改名后)
        self.spec_encoder = SentenceEncoder(device=self.device)
        self.domain_classifier = ControlDomainClassifier(input_dim = in_dim, hidden_dim=hidden_dim, device=self.device,temp=temp)
        self.topology_planner = WorkflowTopologyPlanner(input_dim = in_dim, context_input_dim = in_dim , hidden_dim = hidden_dim,device=self.device,temp=0.8)
        self.scale_estimator = ResourceScaleEstimator(input_dim = in_dim, hidden_dim=hidden_dim,max_agent=max_agent, device=self.device)
        self.role_dispatcher = EngineeringRoleDispatcher(input_dim = in_dim, context_input_dim = 2* hidden_dim, hidden_dim=hidden_dim,device=self.device,temp=temp)
        self.model_scheduler = ModelInferenceScheduler(device=self.device,max_agent=max_agent,temp=1.0)

        # 新增：静态 Embedding 缓存
        self._cached_embeddings = {}
        self._role_cache = None
        if use_cache:
            self._cache_initialized = False

    def forward(self, design_specs:List[str], domain_definitions:List[Dict[str, str]],
                engine_profiles: List[Dict[str, str]], workflow_topologies:List[Dict[str, str]],
                fixed_domain_idx: Optional[List[int]] = None,
                prompt_file:str='MAR/Roles/FinalNode/plc.json',
                use_async_graph: bool = False,
                max_concurrent_agents: int = 3,
                ablation: Optional[str] = None):
        """
        Arg Names Updated for Industrial Context:
        - queries -> design_specs (设计规范)
        - tasks -> domain_definitions (控制域定义)
        - llms -> engine_profiles (引擎配置)
        - collabs -> workflow_topologies (工作流拓扑)

        Args:
            use_async_graph: 是否使用异步并行执行图
            max_concurrent_agents: 最大并发 Agent 数量
        """
        # 推理模式下使用 no_grad 来避免梯度问题
        if not self.training_mode:
            return self._forward_inference(
                design_specs, domain_definitions, engine_profiles, workflow_topologies,
                fixed_domain_idx, prompt_file, use_async_graph, max_concurrent_agents, ablation
            )
        else:
            return self._forward_training(
                design_specs, domain_definitions, engine_profiles, workflow_topologies,
                fixed_domain_idx, prompt_file, use_async_graph, max_concurrent_agents, ablation
            )

    def _forward_inference(self, design_specs, domain_definitions, engine_profiles, workflow_topologies,
                          fixed_domain_idx, prompt_file, use_async_graph, max_concurrent_agents, ablation):
        """推理模式下的前向传播（使用 no_grad）"""
        with torch.no_grad():
            return self._forward_impl(
                design_specs, domain_definitions, engine_profiles, workflow_topologies,
                fixed_domain_idx, prompt_file, use_async_graph, max_concurrent_agents, ablation
            )

    def _forward_training(self, design_specs, domain_definitions, engine_profiles, workflow_topologies,
                         fixed_domain_idx, prompt_file, use_async_graph, max_concurrent_agents, ablation):
        """训练模式下的前向传播（保留梯度）"""
        return self._forward_impl(
            design_specs, domain_definitions, engine_profiles, workflow_topologies,
            fixed_domain_idx, prompt_file, use_async_graph, max_concurrent_agents, ablation
        )

    def _forward_impl(self, design_specs, domain_definitions, engine_profiles, workflow_topologies,
                     fixed_domain_idx, prompt_file, use_async_graph, max_concurrent_agents, ablation):
        """实际的前向传播实现"""
        # 初始化缓存 (首次调用时)
        if self.use_cache and not getattr(self, '_cache_initialized', False):
            self._initialize_caches(domain_definitions, engine_profiles, workflow_topologies)

        # Preprocess data
        domains_list = self._preprocess_data(domain_definitions)
        engines_list = self._preprocess_data(engine_profiles)
        topologies_list = self._preprocess_data(workflow_topologies)
        role_db, role_emb = self.encoder_roles()

        # Signal Embedding - 使用缓存的静态 Embedding
        spec_emb = self.spec_encoder(design_specs)  # 只编码动态输入，不需要 clone

        if self.use_cache and '_cache_initialized' in self.__dict__ and self._cache_initialized:
            # 使用缓存的 Embedding
            domain_emb = self._cached_embeddings['domains']
            engine_emb = self._cached_embeddings['engines']
            topology_emb = self._cached_embeddings['topologies']
        else:
            # 首次编码 (非缓存模式或缓存未初始化)
            domain_emb = self.spec_encoder(domains_list)
            engine_emb = self.spec_encoder(engines_list)
            topology_emb = self.spec_encoder(topologies_list) 
        
        # 1. Control Domain Classification (控制域分类)
        # 传入 domain_emb 启用 MLP + 相似度加权集成
        selected_domain_idx, domain_probs, spec_context = self.domain_classifier(design_specs, domain_emb)
        #selected_domain_idx, domain_probs, spec_context = self.domain_classifier(spec_emb, domain_emb)

        # === 消融注入点: 域分类覆盖 ===
        if ablation == 'static_pipeline':
            pass  # V2: 域分类正常运行，仅固定拓扑和 agent 数

        selected_domains = [domain_definitions[idx] for idx in selected_domain_idx] if fixed_domain_idx is None else [domain_definitions[idx] for idx in fixed_domain_idx]

        # Retrieve role embeddings for the selected domain
        # 注意：这里要用 selected_domains 的 Name 去查库
        domain_role_configs = [role_db[d['Name']] for d in selected_domains]
        domain_role_embs = [role_emb[d['Name']] for d in selected_domains]

        # 2. Workflow Topology Planning (工作流拓扑规划)
        selected_topo_idx, topo_log_probs, topo_context, topo_loss = self.topology_planner(topology_emb, spec_emb)

        # === 消融注入点: 拓扑选择覆盖 ===
        if ablation == 'single_agent':
            io_idx = next((i for i, t in enumerate(workflow_topologies) if t['Name'] == 'IO'), 0)
            selected_topo_idx = torch.full_like(selected_topo_idx, io_idx)
            topo_log_probs = torch.zeros_like(topo_log_probs)
            logger.info(f"[Ablation:single_agent] Topology fixed to IO (idx={io_idx})")
        elif ablation == 'random_topo':
            n_topos = len(workflow_topologies)
            rand_idx = torch.randint(0, n_topos, selected_topo_idx.shape, device=self.device)
            selected_topo_idx = rand_idx
            topo_log_probs = torch.zeros_like(topo_log_probs)
            logger.info(f"[Ablation:random_topo] Topology → random: {[workflow_topologies[i.item()]['Name'] for i in rand_idx]}")
        elif ablation == 'static_pipeline':
            chain_idx = next((i for i, t in enumerate(workflow_topologies) if t['Name'] == 'Chain'), 0)
            selected_topo_idx = torch.full_like(selected_topo_idx, chain_idx)
            topo_log_probs = torch.zeros_like(topo_log_probs)
            logger.info(f"[Ablation:static_pipeline] Topology fixed to Chain (idx={chain_idx})")

        selected_topologies = [workflow_topologies[idx] for idx in selected_topo_idx]

        # 3. Resource Scale Estimation (资源规模评估)
        engineer_count_int, engineer_count_float, scale_loss = self.scale_estimator(spec_emb)

        # === 消融注入点: Agent 数量覆盖 ===
        if ablation == 'single_agent':
            batch_size = engineer_count_int.shape[0]
            fixed_counts = torch.ones((batch_size, 1), device=engineer_count_int.device, dtype=engineer_count_int.dtype)
            engineer_count_int = fixed_counts
            engineer_count_float = fixed_counts.float()
            logger.info(f"[Ablation:single_agent] Scale estimator → fixed to 1 agent")
        elif ablation == 'static_pipeline':
            batch_size = engineer_count_int.shape[0]
            fixed_counts = torch.full((batch_size, 1), 3, device=engineer_count_int.device, dtype=engineer_count_int.dtype)
            engineer_count_int = fixed_counts
            engineer_count_float = fixed_counts.float()
            logger.info(f"[Ablation:static_pipeline] Scale estimator → fixed to 3 agents")

        # 4. Engineering Role Dispatch (工程角色调度)
        selected_role_idx, role_log_probs, role_context, role_loss = self.role_dispatcher(domain_role_embs, torch.concat([spec_context, topo_context],dim=-1), engineer_count_int)
        selected_roles = [[roles[idx.item()] for idx in idx_list] for roles, idx_list in zip(domain_role_configs, selected_role_idx)]

        # === 消融注入点: 角色调度覆盖 ===
        if ablation == 'single_agent':
            selected_roles = []
            for configs in domain_role_configs:
                coder_role = next(
                    (r for r in configs if any(kw in r.get('Name', '')
                     for kw in ('STCodeGenerator', 'Coder', 'Generator', 'Programmer'))),
                    configs[-1]
                )
                selected_roles.append([coder_role])
            role_log_probs = torch.zeros_like(role_log_probs)
            logger.info(f"[Ablation:single_agent] Role → primary coder: {[r[0].get('Name') for r in selected_roles]}")

        # 5. Model Inference Scheduling (模型推理调度)
        selected_engine_idx, engine_log_probs, engine_loss = self.model_scheduler(engine_emb, torch.concat([spec_context, topo_context, role_context],dim=-1), engineer_count_int, engineer_count_float)
        selected_engines = [[engine_profiles[idx] for idx in selected_engine_id_list] for selected_engine_id_list in selected_engine_idx]
        
        # Aggregating Optimization Feedback (Policy Gradients)
        policy_log_probs = engine_log_probs + role_log_probs + topo_log_probs 

        # Aggregating Compliance Metrics (Reconstruction Loss)
        total_compliance_loss = topo_loss + scale_loss + role_loss + engine_loss

        final_result = []
        costs = []
        prompt_tokens_list = []
        completion_tokens_list = []
        retry_counts = []
        first_pass_codes = []
        # Execution Loop
        for spec, domain, engines, topology, roles in zip(design_specs, selected_domains, selected_engines, selected_topologies, selected_roles):
            previous_cost = Cost.instance().value
            previous_prompt = PromptTokens.instance().value
            previous_completion = CompletionTokens.instance().value
            kwargs = get_kwargs(topology['Name'], len(engines))
            engine_names = [e['Name'] for e in engines]
            role_names = [r['Name'] for r in roles]

            logger.info(f'Design Spec: {spec}')
            logger.info(f'Control Domain: {domain["Name"]}')
            logger.info(f'Inference Engines: {engine_names}')
            logger.info(f'Workflow Topology: {topology["Name"]}')
            logger.info(f'Engineering Team: {role_names}')
            logger.info(f'Ablation Mode: {ablation}')
            logger.info('-----------------------------------')

            # 设置消融模式 (供 FinalNode 读取)
            set_ablation_mode(ablation)

            # Graph Execution
            g = Graph(domain = domain['Name'], llm_names = engine_names, agent_names = role_names,
                      decision_method = "FinalRefer", prompt_file = prompt_file, reasoning_name=topology["Name"], **kwargs)
            self.g = g
            # Use 'query' key for compatibility with Agent logic
            # 支持异步并行执行
            final_result.append(g.run(inputs={"query":spec}, num_rounds=kwargs["num_rounds"],
                                     use_async=use_async_graph, max_concurrent=max_concurrent_agents)[0][0])
            costs.append(Cost.instance().value - previous_cost)
            prompt_tokens_list.append(PromptTokens.instance().value - previous_prompt)
            completion_tokens_list.append(CompletionTokens.instance().value - previous_completion)

            # 收集消融指标 (从 FinalNode)
            retry_counts.append(getattr(g.decision_node, 'retry_count', 0))
            first_pass_codes.append(getattr(g.decision_node, 'first_pass_code', None))

        topology_names = [t['Name'] for t in selected_topologies]
        return final_result, costs, policy_log_probs, domain_probs, total_compliance_loss, engineer_count_float, prompt_tokens_list, completion_tokens_list, topology_names, retry_counts, first_pass_codes
    
    def _preprocess_data(self, raw_data:List[Dict[str, str]]):
        get_name_description = lambda x: x['Name'] + ' : ' + x['Description']
        return [get_name_description(data) for data in raw_data]

    def _initialize_caches(self, domain_definitions, engine_profiles, workflow_topologies):
        """
        初始化静态配置的 Embedding 缓存 (性能优化)
        """
        logger.info("Initializing static embedding caches...")

        # 预处理并缓存
        domains_list = self._preprocess_data(domain_definitions)
        engines_list = self._preprocess_data(engine_profiles)
        topologies_list = self._preprocess_data(workflow_topologies)

        with torch.no_grad():
            self._cached_embeddings['domains'] = self.spec_encoder(domains_list).detach().clone().to(self.device)
            self._cached_embeddings['engines'] = self.spec_encoder(engines_list).detach().clone().to(self.device)
            self._cached_embeddings['topologies'] = self.spec_encoder(topologies_list).detach().clone().to(self.device)

        self._cache_initialized = True
        logger.info(f"Static embeddings cached: domains={self._cached_embeddings['domains'].shape}, "
                   f"engines={self._cached_embeddings['engines'].shape}, "
                   f"topologies={self._cached_embeddings['topologies'].shape}")
    
    def encoder_roles(self):
        """
        Loads the Industrial Role Knowledge Base.
        """
        logger.info('Loading Engineering Role Knowledge Base...')
        role_db = {}
        role_emb = {}
        path = 'MAR/Roles'
        for domain in os.listdir(path):
            domain_path = os.path.join(path, domain)
            if os.path.isdir(domain_path):
                role_db[domain] = []
                roles_list = []
                for role_file in os.listdir(domain_path):
                    if role_file.endswith('.json'):
                        full_path = os.path.join(domain_path, role_file)
                        role_profile = json.load(open(full_path, 'r', encoding='utf-8'))
                        role_db[domain].append(role_profile)
                        roles_list.append(json.dumps(role_profile))
                if len(roles_list):
                    role_emb[domain] = self.spec_encoder(roles_list).detach().clone().to(self.device)
        logger.info('Role Knowledge Base Loaded.')
        return role_db, role_emb

# ==============================================================================
# 子模块：ControlDomainClassifier (原 TaskClassifier)
# 工业定义：控制域分类器。识别设计规范属于哪个 IEC 61131-3 控制子域。
# ==============================================================================
class ControlDomainClassifier(nn.Module):
    def __init__(self, input_dim:int=384, hidden_dim:int=64, temp:float = 1.0, device=None,
                 alpha: float = 0.5, sim_temp: float = 0.5):
        """
        Args:
            alpha: MLP 分支权重 (0=纯相似度, 1=纯MLP)
            sim_temp: 相似度 softmax 温度 (越小越挑, 越大越平滑)
        """
        super().__init__()
        self.device = device if device is not None else torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        self.alpha = alpha
        self.sim_temp = sim_temp
        
        # Ensure this matches train_router.py's StandaloneClassifier structure EXACTLY
        # Structure: Linear(384->128) -> ReLU -> Dropout -> Linear(128->64) -> ReLU -> Linear(64->5)
        self.classifier = nn.Sequential(
            nn.Linear(input_dim, 128),      # Layer 0
            nn.ReLU(),                      # Layer 1
            nn.Dropout(0.2),                # Layer 2 (Must be here to match keys, even if not used in eval)
            nn.Linear(128, 64),             # Layer 3
            nn.ReLU(),                      # Layer 4
            nn.Linear(64, 5)                # Layer 5
        ).to(self.device)
        
        # 2. 尝试加载训练好的权重
        self.weights_path = "MAR/RL_MAR/trained_classifier.pth"
        self.load_weights()

        # 3. 标签映射：训练标签顺序→tasks_profile 顺序
        #    train_router.py LABEL_MAP: Motion=0, Process=1, Sequential=2, Data=3, Safety=4
        #    tasks_profile 索引:   SequentialLogicControl=0, ProcessControl=1, MotionAndSortingControl=2, Data=3, Safety=4
        #    映射: [Motion→2, Process→1, Sequential→0, Data→3, Safety→4]
        self.register_buffer('_label_to_profile', torch.tensor([2, 1, 0, 3, 4]))

        # 4. 初始化 Embedding 模型 (用于实时转换输入文本)
        # 注意：这里我们直接用 sentence-transformer，而不是原来的 self.spec_encoder
        # 这样能保证输入特征与训练时完全一致
        try:
            # 支持本地模型路径（优先环境变量，其次硬编码本地路径）
            local_model_path = os.environ.get('LOCAL_MODEL_PATH', '')
            if not local_model_path or not os.path.exists(local_model_path):
                local_model_path = "D:/研一/PLC/plc code generation/all-MiniLM-L6-v2"
            if os.path.exists(local_model_path):
                logger.info(f"Loading local SentenceTransformer from: {local_model_path}")
                self.embedder = SentenceTransformer(local_model_path, device=self.device)
            else:
                self.embedder = SentenceTransformer('all-MiniLM-L6-v2', device=self.device)
        except Exception as e:
            logger.warning(f"Failed to load SentenceTransformer: {e}")
            self.embedder = None

    def load_weights(self):
        if os.path.exists(self.weights_path):
            try:
                state_dict = torch.load(self.weights_path, map_location=self.device, weights_only=True)
                
                new_state_dict = {}
                for k, v in state_dict.items():
                    # Remove "layers." prefix if it exists (from StandaloneClassifier)
                    # Remove "classifier." prefix if it exists (potential other saving format)
                    new_key = k.replace("layers.", "").replace("classifier.", "")
                    new_state_dict[new_key] = v
                
                # Strict=False allows ignoring non-matching keys (like dropout params which have no weights)
                # But we want to ensure weights load, so check return value
                keys = self.classifier.load_state_dict(new_state_dict, strict=False)
                
                if len(keys.missing_keys) > 0 and not all("dropout" in k for k in keys.missing_keys):
                     logger.warning(f"⚠️ Missing keys: {keys.missing_keys}")
                
                self.classifier.eval()
                logger.info(f"✅ Successfully loaded trained Router weights from {self.weights_path}")
            except Exception as e:
                logger.error(f"❌ Error loading weights: {e}")
        else:
            logger.warning(f"⚠️ Weights file not found at {self.weights_path}. Using random init.")
    
    def forward(self, specs, domains=None):
        """
        specs: 可以是已经 Embedding 好的 Tensor，也可以是原始文本 List[str]
        domains: [5, 384] tensor, 5个域定义的 SentenceTransformer embedding。
                 传入时启用 MLP + 相似度加权集成; None 时退化为纯 MLP。
        """
        # 如果输入是文本列表，先转向量
        if isinstance(specs, list) and isinstance(specs[0], str):
            # 使用 SentenceTransformer 的 modules 来获取有梯度的 embedding
            # 这样可以支持训练模式的反向传播
            from sentence_transformers.util import batch_to_device
            from torch.utils.data import DataLoader
            from sentence_transformers import InputExample

            # Tokenize 输入
            features = self.embedder.tokenize(specs)
            features = batch_to_device(features, self.device)

            # 通过模型获取 embedding（保留梯度）
            spec_embedding = self.embedder.forward(features)['sentence_embedding']
        else:
            spec_embedding = specs # 假设已经是 Tensor [Batch, 384]

        # ---- MLP 分支 ----
        logits = self.classifier(spec_embedding) # [Batch, 5]
        mlp_scores = F.softmax(logits, dim=1)
        # 标签映射：训练标签顺序 → tasks_profile 顺序
        mlp_scores = mlp_scores[:, self._label_to_profile]

        # ---- 相似度分支 (加权集成) ----
        if domains is not None:
            # spec_embedding 和 domain_emb 都是 all-MiniLM-L6-v2 编码, 空间一致
            spec_norm = F.normalize(spec_embedding, p=2, dim=1)
            domain_norm = F.normalize(domains, p=2, dim=1)
            sim_logits = torch.matmul(spec_norm, domain_norm.T) / self.sim_temp
            sim_scores = F.softmax(sim_logits, dim=1)
            # 加权融合: α * MLP + (1-α) * 相似度
            scores = self.alpha * mlp_scores + (1 - self.alpha) * sim_scores
        else:
            scores = mlp_scores

        selected_id = torch.argmax(scores, dim=1)

        # 生成 spec_context: 使用简单的线性投影将 384 维映射到 64 维
        # 这与 WorkflowTopologyPlanner 返回的 topo_context 维度一致
        if not hasattr(self, 'context_proj'):
            self.context_proj = nn.Linear(384, 64).to(self.device)
        spec_context = F.normalize(self.context_proj(spec_embedding), p=2, dim=1)

        # 返回格式保持与原接口一致：(selected_idx, probs, context)
        return selected_id, scores, spec_context

# ==============================================================================
# 子模块：WorkflowTopologyPlanner (原 CollabDeterminer)
# 工业定义：工作流拓扑规划器。在逻辑流形中规划最佳的工程协作结构。
# ==============================================================================
class WorkflowTopologyPlanner(nn.Module):
    def __init__(self, input_dim=384, context_input_dim=384, hidden_dim=64, temp=1.0, device=None):
        super().__init__()
        self.topo_encoder = LogicFeatureExtractor(input_dim, hidden_dim, hidden_dim)
        self.context_encoder = LogicFeatureExtractor(context_input_dim, hidden_dim, hidden_dim)
        self.temp = temp
        self.device = device if device is not None else torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    
    def forward(self, topologies:torch.Tensor, contexts:torch.Tensor):
        topo_hat, topo_z, topo_mu, topo_logvar = self.topo_encoder(topologies)  
        topo_z = F.normalize(topo_z, p=2, dim=1) 

        context_hat, context_z, context_mu, context_logvar = self.context_encoder(contexts)  
        context_z = F.normalize(context_z, p=2, dim=1) 

        scores = torch.matmul(context_z, topo_z.T) 
        scores = torch.softmax(scores / self.temp, dim=1)

        loss1 = compliance_metric_function(topo_hat, topologies, topo_mu, topo_logvar)
        loss2 = compliance_metric_function(context_hat, contexts, context_mu, context_logvar)
        total_loss = loss1 + loss2

        scores_cumsum = torch.cumsum(scores, dim=1)
        random_num = torch.rand([scores.size(0),1], device=self.device)
        selected_index = (scores_cumsum > random_num).float().argmax(dim=1)
        
        log_probs = torch.log(scores[torch.arange(scores.size(0)), selected_index]).unsqueeze(1)
        topo_embedding = topo_z[selected_index]

        return selected_index, log_probs, topo_embedding, total_loss


# ==============================================================================
# 子模块：ResourceScaleEstimator (原 NumDeterminer)
# 工业定义：资源规模评估器。评估完成设计规范所需的工程模块/人员数量。
# ==============================================================================
class ResourceScaleEstimator(nn.Module):
    def __init__(self, input_dim:int=384, hidden_dim:int = 64, max_agent:int = 6, device=None):
        super().__init__()
        self.device = device if device is not None else torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        self.logic_analyzer = LogicFeatureExtractor(input_dim, hidden_dim, hidden_dim)
        self.fc = nn.Linear(hidden_dim, 1) 
        self.max_modules = max_agent
        
    def forward(self, specs:torch.Tensor):
        x_hat, z, mu, log_var = self.logic_analyzer(specs)
        z = F.normalize(z, p=2, dim=1) 

        difficulty = self.fc(z) 
        difficulty = torch.sigmoid(difficulty) 

        count_float = difficulty * self.max_modules 
        count_int = torch.clamp(torch.round(count_float), 1, self.max_modules).int() 
        loss = compliance_metric_function(x_hat, specs, mu, log_var)

        return count_int, count_float, loss


# ==============================================================================
# 子模块：EngineeringRoleDispatcher (原 RoleAllocation)
# 工业定义：工程角色调度器。基于序列决策过程分配具体的工程角色（如架构师、校验员）。
# ==============================================================================
class EngineeringRoleDispatcher(torch.nn.Module):
    def __init__(self, input_dim:int=384, context_input_dim:int = 128, hidden_dim:int=64, temp=1.0, device=None):
        super().__init__()
        self.device = device if device is not None else torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        self.init_role_state = torch.zeros([1, hidden_dim],device=self.device,requires_grad=True) 
        self.role_encoder = LogicFeatureExtractor(input_dim, hidden_dim, hidden_dim)
        self.context_updater = nn.Linear(context_input_dim + hidden_dim, hidden_dim) 
        self.temp = temp
        
    def forward(self, roles_list:List[torch.Tensor], contexts:torch.Tensor, count_int:torch.Tensor):
        selected_roles_idx = [] 
        log_probs = torch.zeros([contexts.size(0),1], device=self.device) 
        summary_states = []

        for i, roles in enumerate(roles_list): # for each spec in batch
            selected_roles_idx.append([])
            role_hat, role_z, role_mu, role_log_var = self.role_encoder(roles) 
            role_embedding = F.normalize(role_z, p=2, dim=1)

            if i == 0:
                loss = compliance_metric_function(role_hat, roles, role_mu, role_log_var)
            else:
                loss = compliance_metric_function(role_hat, roles, role_mu, role_log_var) + loss
            
            current_state = self.init_role_state 
            history_state = self.init_role_state 

            for j in range(count_int[i]): # Iterative Dispatch
                history_state = history_state + current_state
                history_state = F.layer_norm(history_state, history_state.shape[1:])

                state_input = torch.cat([contexts[i].unsqueeze(0), history_state], dim=1)
                query_vec = self.context_updater(state_input) 
                query_vec = F.normalize(query_vec, p=2, dim=1) 

                scores = torch.matmul(query_vec, role_embedding.T) 
                scores = torch.softmax(scores/self.temp, dim=1) 
                
                scores_cumsum = torch.cumsum(scores, dim=1) 
                random_num = torch.rand([scores.size(0),1], device=self.device) 
                selected_index = (scores_cumsum > random_num).float().argmax(dim=1) 
                
                log_probs[i][0] = log_probs[i][0] + torch.log(scores[torch.arange(scores.size(0)), selected_index]).unsqueeze(1)

                current_state = role_embedding[selected_index] 
                selected_roles_idx[-1].append(selected_index)
            
            summary_states.append(history_state)
        
        summary_tensor = torch.cat(summary_states, dim=0) 
        return selected_roles_idx, log_probs, summary_tensor, loss/len(roles_list)

# ==============================================================================
# 子模块：ModelInferenceScheduler (原 LLMRouter)
# 工业定义：模型推理调度器。根据任务复杂度调度不同算力的推理引擎。
# ==============================================================================
class ModelInferenceScheduler(torch.nn.Module):
    def __init__(self, input_dim:int=384, context_input_dim:int = 192, hidden_dim:int=64, temp:float=1.0, max_agent:int=6, device=None):
        super().__init__()
        self.device = device if device is not None else torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        self.engine_encoder = LogicFeatureExtractor(input_dim, hidden_dim, hidden_dim)
        self.context_proj = nn.Linear(context_input_dim, hidden_dim) 
        self.temp = temp
        self.max_modules = max_agent

    def forward(self, engines:torch.Tensor, contexts:torch.Tensor, count_int:torch.Tensor, count_float:torch.Tensor):
        e_hat, e_z, e_mu, e_log_var = self.engine_encoder(engines) 
        e_embedding = F.normalize(e_z, p=2, dim=1) 
        
        c_embedding = self.context_proj(contexts) 
        c_embedding = F.normalize(c_embedding, p=2, dim=1) 
        
        loss = compliance_metric_function(e_hat, engines, e_mu, e_log_var)

        scores = torch.matmul(c_embedding, e_embedding.T) 
        scores = torch.softmax(scores/self.temp, dim=1) 
        scores_cumsum = torch.cumsum(scores, dim=1)
        
        selected_mask = torch.zeros([contexts.size(0), engines.size(0)], device=self.device) 
        selected_indices:List[List[int]] = [[] for i in range(contexts.size(0))] 
        
        for i in range(1, self.max_modules+1):
            mask = (count_int >= i).squeeze(1).float() 
            random_num = torch.rand_like(count_float, device=self.device) 
            selected_index = (scores_cumsum > random_num).float().argmax(dim=1) 
            selected_mask[torch.arange(selected_mask.size(0)), selected_index] += mask 

            for j in range(contexts.size(0)):
                if mask[j] > 0:
                    selected_indices[j].append(int(selected_index[j].item()))
        
        # Policy Optimization Feedback
        log_probs = gammaln(count_float + 1) - gammaln(selected_mask + 1).sum(dim=1).unsqueeze(1) + (selected_mask * torch.log(scores)).sum(dim=1).unsqueeze(1) 
        
        return selected_indices, log_probs, loss