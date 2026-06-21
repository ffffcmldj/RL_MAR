_ABLATION_MODE = None


def set_ablation_mode(mode):
    global _ABLATION_MODE
    _ABLATION_MODE = mode


def get_ablation_mode():
    return _ABLATION_MODE


def get_ablation_temperature():
    return None


def get_ablation_frequency_penalty():
    return None
