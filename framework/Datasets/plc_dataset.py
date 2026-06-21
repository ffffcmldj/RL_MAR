import json
import os
from torch.utils.data import Dataset

class PLCDataset(Dataset):
    def __init__(self, data_path):
        self.data = []
        self.load_data(data_path)

    def load_data(self, data_path):
        # 自动处理路径，如果只给了文件名，尝试在默认路径寻找
        if not os.path.exists(data_path):
            potential_path = os.path.join("Datasets/PLC/data", data_path)
            if os.path.exists(potential_path):
                data_path = potential_path
            else:
                raise FileNotFoundError(f"Data file not found at {data_path} or {potential_path}")

        with open(data_path, 'r', encoding='utf-8') as f:
            for line in f:
                if line.strip():
                    self.data.append(json.loads(line))
        print(f"Loaded {len(self.data)} tasks from {data_path}")

    def __len__(self):
        return len(self.data)

    def __getitem__(self, idx):
        return self.data[idx]

    def get_batch(self, indices):
        return [self.data[i] for i in indices]