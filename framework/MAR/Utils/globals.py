import threading

class Singleton:
    _instance = None

    @classmethod
    def instance(cls):
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    def reset(self):
        self.value = 0.0

class Cost(Singleton):
    def __init__(self):
        self.value = 0.0
        self._lock = threading.Lock()

    def add(self, amount: float):
        with self._lock:
            self.value += amount

class PromptTokens(Singleton):
    def __init__(self):
        self.value = 0
        self._lock = threading.Lock()

    def add(self, amount: int):
        with self._lock:
            self.value += amount

class CompletionTokens(Singleton):
    def __init__(self):
        self.value = 0
        self._lock = threading.Lock()

    def add(self, amount: int):
        with self._lock:
            self.value += amount

