from MAR.Graph.node import Node
# 修改：导入新的类名 DynamicEngineeringTopology，并为了兼容性将其别名为 Graph（可选，但推荐保留别名以防其他脚本引用）
from MAR.Graph.graph import DynamicEngineeringTopology

# 更新导出列表
__all__ = ["Node",
           "DynamicEngineeringTopology"]