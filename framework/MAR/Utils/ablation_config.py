"""消融实验全局配置模块。
避免在 RL_MAR.py 和 agent.py 之间产生循环导入。
"""

_ABLATION_MODE = None


def set_ablation_mode(mode):
    """设置消融模式，供 FinalNode 读取以控制重试次数"""
    global _ABLATION_MODE
    _ABLATION_MODE = mode


def get_ablation_mode():
    """获取当前消融模式"""
    return _ABLATION_MODE


def get_ablation_temperature():
    """获取消融实验的 LLM temperature 覆盖值。"""
    return None


def get_ablation_frequency_penalty():
    """获取消融实验的 LLM frequency_penalty 覆盖值。"""
    return None
