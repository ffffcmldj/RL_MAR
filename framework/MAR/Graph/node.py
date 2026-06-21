import shortuuid
from typing import List, Any, Optional, Dict
from abc import ABC, abstractmethod
import warnings
import asyncio

class Node(ABC):
    """
    Abstract Engineering Module (Function Block) within the dynamic topology.
    
    This class represents a functional unit in the engineering workflow system. 
    It manages collaborative signal interfaces (inputs/outputs) and iterative memory states.
    
    Attributes:
        id (str): Unique module identifier.
        collaborative_sources (List[Node]): Upstream modules providing context in the current cycle.
        collaborative_targets (List[Node]): Downstream modules receiving signals from this module.
        memory_sources (List[Node]): Modules providing feedback from previous iterations.
        memory_targets (List[Node]): Modules receiving state feedback for next iterations.
        inputs (List[Any]): Design specification inputs.
        outputs (List[Any]): Generated artifacts/signals.
    """

    def __init__(self, 
                 id: Optional[str],
                 agent_name:str="",
                 domain:str="", 
                 llm_name:str = "",
                 ):
        self.id:str = id if id is not None else shortuuid.ShortUUID().random(length=4)
        self.agent_name:str = agent_name
        self.domain:str = domain
        self.llm_name:str = llm_name
        
        # --- R&D Style Renaming ---
        # 原 spatial_predecessors -> collaborative_sources (协作源)
        self.collaborative_sources: List[Node] = []
        # 原 spatial_successors -> collaborative_targets (协作目标)
        self.collaborative_targets: List[Node] = []
        # 原 temporal_predecessors -> memory_sources (记忆源/反馈源)
        self.memory_sources: List[Node] = []
        # 原 temporal_successors -> memory_targets (记忆目标/反馈目标)
        self.memory_targets: List[Node] = []
        
        self.inputs: List[Any] = []
        self.outputs: List[Any] = []
        self.raw_inputs: List[Any] = []
        self.role = ""
        self.last_memory: Dict[str,List[Any]] = {'inputs':[],'outputs':[],'raw_inputs':[]}        

    @property
    def node_name(self):
        return self.__class__.__name__
    
    def add_predecessor(self, operation: 'Node', st='spatial'):
        """Link an upstream module (Signal Input)."""
        if st == 'spatial' and operation not in self.collaborative_sources:
            self.collaborative_sources.append(operation)
            operation.collaborative_targets.append(self)
        elif st == 'temporal' and operation not in self.memory_sources:
            self.memory_sources.append(operation)
            operation.memory_targets.append(self)

    def add_successor(self, operation: 'Node', st='spatial'):
        """Link a downstream module (Signal Output)."""
        if st =='spatial' and operation not in self.collaborative_targets:
            self.collaborative_targets.append(operation)
            operation.collaborative_sources.append(self)
        elif st == 'temporal' and operation not in self.memory_targets:
            self.memory_targets.append(operation)
            operation.memory_sources.append(self)

    def remove_predecessor(self, operation: 'Node', st='spatial'):
        if st =='spatial' and operation in self.collaborative_sources:
            self.collaborative_sources.remove(operation)
            operation.collaborative_targets.remove(self)
        elif st =='temporal' and operation in self.memory_sources:
            self.memory_sources.remove(operation)
            operation.memory_targets.remove(self)

    def remove_successor(self, operation: 'Node', st='spatial'):
        if st =='spatial' and operation in self.collaborative_targets:
            self.collaborative_targets.remove(operation)
            operation.collaborative_sources.remove(self)
        elif st =='temporal' and operation in self.memory_targets:
            self.memory_targets.remove(operation)
            operation.memory_sources.remove(self)

    def clear_connections(self):
        self.collaborative_sources: List[Node] = []
        self.collaborative_targets: List[Node] = []
        self.memory_sources: List[Node] = []
        self.memory_targets: List[Node] = []        
    
    def update_memory(self):
        """Latch internal states for the next iteration cycle."""
        self.last_memory['inputs'] = self.inputs
        self.last_memory['outputs'] = self.outputs
        self.last_memory['raw_inputs'] = self.raw_inputs

    def aggregate_collaborative_context(self) -> Dict[str, Dict]:
        """
        Aggregate signals from upstream collaborative modules.
        (Renamed from get_spatial_info)
        """
        context_info = {}
        if self.collaborative_sources is not None:
            for source in self.collaborative_sources:
                source_outputs = source.outputs
                if isinstance(source_outputs, list) and len(source_outputs):
                    final_output = source_outputs[-1]
                elif isinstance(source_outputs, list) and len(source_outputs)==0:
                    continue
                else:
                    final_output = source_outputs
                context_info[source.id] = {"role": source.role, "output": final_output}

        return context_info

    def retrieve_iteration_history(self) -> Dict[str, Any]:
        """
        Retrieve state feedback from previous iterations.
        (Renamed from get_temporal_info)
        """
        history_info = {}
        if self.memory_sources is not None:
            for source in self.memory_sources:
                prev_outputs = source.last_memory['outputs']
                if isinstance(prev_outputs, list) and len(prev_outputs):
                    final_output = prev_outputs[-1]
                elif isinstance(prev_outputs, list) and len(prev_outputs)==0:
                    continue
                else:
                    final_output = prev_outputs
                history_info[source.id] = {"role": source.role, "output": final_output}
        
        return history_info
    
    def execute(self, input:Any, **kwargs):
        """Execute the module logic for the current cycle."""
        self.outputs = []
        # Update: Use new method names
        spatial_info = self.aggregate_collaborative_context()
        temporal_info = self.retrieve_iteration_history()
        
        # Pass to internal implementation (Agent logic)
        results = [self._execute(input, spatial_info, temporal_info, **kwargs)]

        for result in results:
            if not isinstance(result, list):
                result = [result]
            self.outputs.extend(result)
        return self.outputs

    async def async_execute(self, input:Any, **kwargs):
        self.outputs = []
        spatial_info = self.aggregate_collaborative_context()
        temporal_info = self.retrieve_iteration_history()

        loop = asyncio.get_event_loop()
        result = await loop.run_in_executor(None, self._execute, input, spatial_info, temporal_info)

        if not isinstance(result, list):
            result = [result]
        self.outputs.extend(result)
        return self.outputs
               
    @abstractmethod
    def _execute(self, input:List[Any], spatial_info:Dict[str,Any], temporal_info:Dict[str,Any], **kwargs):
        """ To be overriden by the descendant class (Agent Logic) """

    @abstractmethod
    async def _async_execute(self, input:List[Any], spatial_info:Dict[str,Any], temporal_info:Dict[str,Any], **kwargs):
        """ To be overriden by the descendant class (Agent Logic) """

    @abstractmethod
    def _process_inputs(self, raw_inputs:List[Any], spatial_info:Dict[str,Any], temporal_info:Dict[str,Any], **kwargs)->List[Any]:
        """ To be overriden by the descendant class """