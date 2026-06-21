from sentence_transformers import SentenceTransformer
import torch
import os

LOCAL_MODEL_FALLBACK = os.getenv("LOCAL_MODEL_PATH", "")


def _resolve_model_path():
    """Resolve model path: env var -> local fallback -> None (caller decides default)."""
    path = os.environ.get('LOCAL_MODEL_PATH', '')
    if path and os.path.exists(path):
        return path
    if os.path.exists(LOCAL_MODEL_FALLBACK):
        return LOCAL_MODEL_FALLBACK
    return None


def get_sentence_embedding(sentence):
    path = _resolve_model_path() or 'sentence-transformers/all-MiniLM-L6-v2'
    model = SentenceTransformer(path)
    embeddings = model.encode(sentence)
    return torch.tensor(embeddings)


class SentenceEncoder(torch.nn.Module):
    def __init__(self, device=None):
        super().__init__()
        self.device = device if device else 'cuda' if torch.cuda.is_available() else 'cpu'

        path = _resolve_model_path() or 'sentence-transformers/all-MiniLM-L6-v2'
        if os.path.exists(path):
            print(f"Loading local model from: {path}")
        self.model = SentenceTransformer(path, device=self.device)
        
    def forward(self, sentence):
        if len(sentence) == 0:
            return torch.tensor([]).to(self.device)
        embeddings = self.model.encode(sentence,convert_to_tensor=True,device=self.device)
        return embeddings