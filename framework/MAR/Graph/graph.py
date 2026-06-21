import shortuuid
from typing import Any, List, Optional, Dict, Tuple
from abc import ABC
import numpy as np
import torch
import asyncio

from MAR.Graph.node import Node
from MAR.Utils.utils import find_mode
from MAR.Agent.agent_registry import AgentRegistry

class DynamicEngineeringTopology(ABC):
    """
    Dynamic Engineering Topology Management System.
    (原 Graph 类)

    Manages the lifecycle and connectivity of functional modules (Agents) within the
    PLC code generation pipeline. It optimizes the workflow topology based on
    task complexity and inter-module dependencies.

    Attributes:
        active_modules (dict): Registry of all instantiated engineering modules.
        connectivity_weights (Parameter): Learnable weights for module interconnectivity.
    """

    def __init__(self, 
                domain: str,
                llm_names: List[str],
                agent_names: List[str],
                decision_method: str,
                reasoning_name: str,
                prompt_file: str,
                optimized_spatial:bool = False,
                initial_spatial_probability: float = 0.5,
                fixed_spatial_masks:List[List[int]] = None,
                optimized_temporal:bool = False,
                initial_temporal_probability: float = 0.5,
                fixed_temporal_masks:List[List[int]] = None,
                node_kwargs:List[Dict] = None,
                **kwargs,
                ):
        
        if fixed_spatial_masks is None:
            fixed_spatial_masks = [[1 if i!=j else 0 for j in range(len(agent_names))] for i in range(len(agent_names))]
        if fixed_temporal_masks is None:
            fixed_temporal_masks = [[1 for j in range(len(agent_names))] for i in range(len(agent_names))]
        fixed_spatial_masks = torch.tensor(fixed_spatial_masks).view(-1)
        fixed_temporal_masks = torch.tensor(fixed_temporal_masks).view(-1)
        
        self.id:str = shortuuid.ShortUUID().random(length=4)
        self.domain:str = domain
        self.llm_names:List[str] = llm_names
        self.final_llm_name:str = find_mode(llm_names)
        self.agent_names:List[str] = agent_names
        
        # Optimization Flags
        self.optimized_spatial = optimized_spatial
        self.optimized_temporal = optimized_temporal
        
        self.decision_node:Node = AgentRegistry.get(decision_method, **{"domain":self.domain,"llm_name":self.final_llm_name, "prompt_file":prompt_file})
        
        # Renamed: nodes -> active_modules
        self.active_modules:Dict[str,Node] = {}
        
        self.potential_spatial_edges:List[List[str, str]] = []
        self.potential_temporal_edges:List[List[str,str]] = []
        self.node_kwargs = node_kwargs if node_kwargs is not None else [{} for _ in agent_names]
        self.reasoning_name = reasoning_name

        self.init_nodes() 
        self.init_potential_edges() 
        
        # Renamed: spatial_logits -> connectivity_weights
        init_spatial_logit = torch.log(torch.tensor(initial_spatial_probability / (1 - initial_spatial_probability))) if optimized_spatial else 10.0
        self.connectivity_weights = torch.nn.Parameter(torch.ones(len(self.potential_spatial_edges), requires_grad=optimized_spatial) * init_spatial_logit,
                                                 requires_grad=optimized_spatial) 
        # Renamed: spatial_masks -> topology_constraints
        self.topology_constraints = torch.nn.Parameter(fixed_spatial_masks,requires_grad=False)  

        # Renamed: temporal_logits -> memory_gate_weights
        init_temporal_logit = torch.log(torch.tensor(initial_temporal_probability / (1 - initial_temporal_probability))) if optimized_temporal else 10.0
        self.memory_gate_weights = torch.nn.Parameter(torch.ones(len(self.potential_temporal_edges), requires_grad=optimized_temporal) * init_temporal_logit,
                                                 requires_grad=optimized_temporal) 
        # Renamed: temporal_masks -> memory_constraints
        self.memory_constraints = torch.nn.Parameter(fixed_temporal_masks,requires_grad=False)  
        
    @property
    def interaction_matrix(self):
        """Adj Matrix for module interactions."""
        matrix = np.zeros((len(self.active_modules), len(self.active_modules)))
        for i, node1_id in enumerate(self.active_modules):
            for j, node2_id in enumerate(self.active_modules):
                # Using new attribute: collaborative_successors
                if self.active_modules[node2_id] in self.active_modules[node1_id].collaborative_targets: 
                    matrix[i, j] = 1
        return matrix

    @property
    def feedback_matrix(self):
        """Adj Matrix for memory feedback loops."""
        matrix = np.zeros((len(self.active_modules), len(self.active_modules)))
        for i, node1_id in enumerate(self.active_modules):
            for j, node2_id in enumerate(self.active_modules):
                # Using new attribute: memory_targets
                if self.active_modules[node2_id] in self.active_modules[node1_id].memory_targets: 
                    matrix[i, j] = 1
        return matrix

    @property
    def num_links(self):
        num_links = 0
        for node in self.active_modules.values():
            num_links += len(node.collaborative_targets)
        return num_links
    
    @property
    def num_modules(self):
        return len(self.active_modules)

    def find_node(self, id: str):
        if id in self.active_modules.keys():
            return self.active_modules[id]
        raise Exception(f"Module not found: {id}")
        
    def add_node(self, node: Node):
        node_id = node.id if node.id is not None else shortuuid.ShortUUID().random(length=4)
        while node_id in self.active_modules:
            node_id = shortuuid.ShortUUID().random(length=4)
        node.id = node_id
        self.active_modules[node_id] = node
        return node
    
    def init_nodes(self):
        for agent_name, llm_name, kwargs in zip(self.agent_names, self.llm_names, self.node_kwargs):
            if "Agent" in AgentRegistry.registry:
                kwargs["domain"] = self.domain
                kwargs["llm_name"] = llm_name
                kwargs["reason_name"] = self.reasoning_name
                kwargs["role"] = agent_name
                agent_instance = AgentRegistry.get("Agent", **kwargs)
                self.add_node(agent_instance)
    
    def init_potential_edges(self):
        for node1_id in self.active_modules.keys():
            for node2_id in self.active_modules.keys():
                self.potential_spatial_edges.append([node1_id,node2_id])
                self.potential_temporal_edges.append([node1_id,node2_id])

    def clear_spatial_connection(self):
        for node_id in self.active_modules.keys():
            self.active_modules[node_id].collaborative_sources = []
            self.active_modules[node_id].collaborative_targets = []
        self.decision_node.collaborative_sources = []
        self.decision_node.collaborative_targets = []
    
    def clear_temporal_connection(self):
        for node_id in self.active_modules.keys():
            self.active_modules[node_id].memory_sources = []
            self.active_modules[node_id].memory_targets = []

    def connect_decision_node(self):
        for node_id in self.active_modules.keys():
            self.active_modules[node_id].add_successor(self.decision_node)

    def optimize_workflow_connectivity(self, temperature: float = 1.0, threshold: float = None,): 
        """
        Dynamically optimizes the signal flow between modules.
        (Renamed from construct_spatial_connection)
        """
        self.clear_spatial_connection()
        log_probs = [torch.tensor(0.0, requires_grad=self.optimized_spatial)]
        
        # Iterate over potential edges and weights
        for potential_connection, edge_logit, edge_mask in zip(self.potential_spatial_edges, self.connectivity_weights, self.topology_constraints):
            out_node:Node = self.find_node(potential_connection[0])
            in_node:Node = self.find_node(potential_connection[1])
            if edge_mask == 0.0:
                continue
            elif edge_mask == 1.0 and self.optimized_spatial==False:
                if not self.check_algebraic_loop(in_node, {out_node}):
                    out_node.add_successor(in_node,'spatial')
                continue
            if not self.check_algebraic_loop(in_node, {out_node}):
                edge_prob = torch.sigmoid(edge_logit / temperature)
                if threshold:
                    edge_prob = torch.tensor(1 if edge_prob > threshold else 0)
                if torch.rand(1) < edge_prob:
                    out_node.add_successor(in_node,'spatial')
                    log_probs.append(torch.log(edge_prob))
                else:
                    log_probs.append(torch.log(1 - edge_prob))
                    
        return torch.sum(torch.stack(log_probs))
    
    def update_memory_mechanisms(self, round:int = 0, temperature: float = 1.0, threshold: float = None,): 
        """
        Updates the memory feedback loops for iterative refinement.
        (Renamed from construct_temporal_connection)
        """
        self.clear_temporal_connection()
        log_probs = [torch.tensor(0.0, requires_grad=self.optimized_temporal)]
        if round == 0:
            return torch.sum(torch.stack(log_probs))  
        
        for potential_connection, edge_logit, edge_mask in zip(self.potential_temporal_edges, self.memory_gate_weights, self.memory_constraints):
            out_node:Node = self.find_node(potential_connection[0])
            in_node:Node = self.find_node(potential_connection[1])
            if edge_mask == 0.0:
                continue
            elif edge_mask == 1.0 and self.optimized_temporal==False:
                if not self.check_algebraic_loop(in_node, {out_node}):
                    out_node.add_successor(in_node,'temporal')
                continue
            
            edge_prob = torch.sigmoid(edge_logit / temperature)
            if threshold:
                edge_prob = torch.tensor(1 if edge_prob > threshold else 0)
            if torch.rand(1) < edge_prob:
                out_node.add_successor(in_node,'temporal')
                log_probs.append(torch.log(edge_prob))
            else:
                log_probs.append(torch.log(1 - edge_prob))
                    
        return torch.sum(torch.stack(log_probs))


    def execute_generation_pipeline(self, inputs: Dict[str,str],
                  num_rounds:int = 2,
                  max_tries: int = 3,
                  max_time: int = 100,
                  use_async: bool = False,
                  max_concurrent: int = 3,) -> List[Any]:
        """
        Executes the PLC code generation pipeline simulation.
        (Renamed from run)

        Args:
            use_async: 是否使用异步并行执行 (性能优化)
            max_concurrent: 最大并发 Agent 数量
        """
        if use_async:
            # 使用异步并行执行
            return asyncio.run(self._execute_pipeline_async(
                inputs, num_rounds, max_tries, max_time, max_concurrent
            ))
        else:
            # 使用原有的串行执行逻辑
            return self._execute_pipeline_sync(
                inputs, num_rounds, max_tries, max_time
            )

    async def _execute_pipeline_async(
        self, inputs: Dict[str,str],
        num_rounds: int = 2,
        max_tries: int = 3,
        max_time: int = 100,
        max_concurrent: int = 3,
    ) -> List[Any]:
        """
        异步并行执行生成管线 (性能优化版本)
        """
        log_probs = 0

        for round in range(num_rounds):
            log_probs += self.optimize_workflow_connectivity()
            log_probs += self.update_memory_mechanisms(round)

            # 构建执行层级 (无依赖的 Agent 可以并行)
            execution_layers = self._build_execution_layers()

            # 按层级执行，每层内并行
            for layer in execution_layers:
                if len(layer) == 1:
                    # 单个 Agent，直接执行
                    node = layer[0]
                    node.execute(inputs)
                else:
                    # 多个无依赖 Agent，并行执行
                    await self._execute_layer_async(layer, inputs, max_concurrent)

            self.update_system_states()

        # 决策节点执行
        self.connect_decision_node()
        self.decision_node.execute(inputs)
        final_answers = self.decision_node.outputs
        if len(final_answers) == 0:
            final_answers.append("No answer of the decision node")

        return final_answers, log_probs

    def _execute_pipeline_sync(
        self, inputs: Dict[str,str],
        num_rounds: int = 2,
        max_tries: int = 3,
        max_time: int = 100,
    ) -> List[Any]:
        """
        串行执行生成管线 (原有逻辑，保持兼容性)
        """
        log_probs = 0
        for round in range(num_rounds):
            log_probs += self.optimize_workflow_connectivity()
            log_probs += self.update_memory_mechanisms(round)

            # Topological Sort Logic using new attribute names
            in_degree = {node_id: len(node.collaborative_sources) for node_id, node in self.active_modules.items()}
            ready_queue = [node_id for node_id, deg in in_degree.items() if deg == 0]

            while ready_queue:
                current_node_id = ready_queue.pop(0)
                tries = 0
                while tries < max_tries:
                    try:
                        self.active_modules[current_node_id].execute(inputs)
                        break
                    except Exception as e:
                        print(f"Error executing module {current_node_id}: {e}")
                    tries += 1
                for successor in self.active_modules[current_node_id].collaborative_targets:
                    if successor.id not in self.active_modules.keys():
                        continue
                    in_degree[successor.id] -= 1
                    if in_degree[successor.id] == 0:
                        ready_queue.append(successor.id)
            self.update_system_states()

        self.connect_decision_node()
        self.decision_node.execute(inputs)
        final_answers = self.decision_node.outputs
        if len(final_answers) == 0:
            final_answers.append("No answer of the decision node")

        return final_answers, log_probs

    def _build_execution_layers(self) -> List[List['Node']]:
        """
        构建执行层级：
        - Layer 0: 无入度的节点 (可并行)
        - Layer 1: 依赖 Layer 0 的节点 (可并行)
        - ...
        """
        layers = []
        remaining = set(self.active_modules.keys())

        while remaining:
            # 找出当前层可执行的节点
            current_layer = []
            for node_id in list(remaining):
                node = self.active_modules[node_id]
                # 检查所有依赖是否已完成
                sources_in_remaining = [
                    src for src in node.collaborative_sources
                    if src.id in remaining
                ]
                if not sources_in_remaining:
                    current_layer.append(node_id)

            if not current_layer:
                # 检测到环，强制添加一个节点
                current_layer = [next(iter(remaining))]

            layers.append([self.active_modules[nid] for nid in current_layer])
            remaining -= set(current_layer)

        return layers

    async def _execute_layer_async(
        self, layer: List['Node'], inputs: Dict[str, str], max_concurrent: int = 3
    ):
        """
        并行执行一层中的所有 Agent
        """
        semaphore = asyncio.Semaphore(max_concurrent)

        async def execute_with_limit(node):
            async with semaphore:
                return await node.async_execute(inputs)

        tasks = [execute_with_limit(node) for node in layer]
        await asyncio.gather(*tasks, return_exceptions=True)

    # Alias for compatibility
    run = execute_generation_pipeline

    def update_system_states(self):
        for id,node in self.active_modules.items():
            node.update_memory()
    
    def check_algebraic_loop(self, new_node, target_nodes):
        """Detects algebraic loops (cycles) in the signal flow."""
        if new_node in target_nodes:
            return True
        for successor in new_node.collaborative_targets:
            if self.check_algebraic_loop(successor, target_nodes):
                return True
        return False

    def optimize_topology_constraints(self, pruning_rate: float) -> torch.Tensor:
        """Prunes weak connections to optimize system efficiency."""
        if self.optimized_spatial:
            num_edges = (self.topology_constraints > 0).sum()
            num_masks = (self.topology_constraints == 0).sum()
            prune_num_edges = torch.round(num_edges*pruning_rate) if torch.round(num_edges*pruning_rate)>0 else 1
            _edge_logits = self.connectivity_weights.clone()
            min_edge_logit = _edge_logits.min()
            _edge_logits[self.topology_constraints == 0] = min_edge_logit - 1.0
            sorted_edges_idx = torch.argsort(_edge_logits)
            prune_idx = sorted_edges_idx[:int(prune_num_edges + num_masks)]
            self.topology_constraints[prune_idx] = 0
        
        if self.optimized_temporal:
            num_edges = (self.memory_constraints > 0).sum()
            num_masks = (self.memory_constraints == 0).sum()
            prune_num_edges = torch.round(num_edges*pruning_rate) if torch.round(num_edges*pruning_rate)>0 else 1
            _edge_logits = self.memory_gate_weights.clone()
            min_edge_logit = _edge_logits.min()
            _edge_logits[self.memory_constraints == 0] = min_edge_logit - 1.0
            sorted_edges_idx = torch.argsort(_edge_logits)
            prune_idx = sorted_edges_idx[:int(prune_num_edges + num_masks)]
            self.memory_constraints[prune_idx] = 0
        return self.topology_constraints, self.memory_constraints
    
    def list_nodes(self):
        profile = []
        for i, node_id in enumerate(self.active_modules):
            profile.append({'id': node_id, 'role': self.active_modules[node_id].role.role, 'llm_name': self.active_modules[node_id].llm.model_name})
        return profile