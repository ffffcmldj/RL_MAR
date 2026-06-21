# MAR/Roles/role_cache.py

import os
import json
from typing import Dict, List
from loguru import logger


class RoleConfigCache:
    """
    角色配置缓存 (性能优化)

    避免每次初始化 Router 时都从磁盘读取 JSON 文件。
    """

    _instance = None
    _role_db: Dict[str, List[Dict]] = {}
    _initialized = False

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def load_once(self, path: str = 'MAR/Roles') -> Dict[str, List[Dict]]:
        """
        只加载一次角色配置

        Args:
            path: 角色配置目录路径

        Returns:
            Dict[str, List[Dict]]: 角色数据库 {domain: [role_configs]}
        """
        if self._initialized:
            return self._role_db

        logger.info("Loading Role configurations (cached)...")
        for domain in os.listdir(path):
            domain_path = os.path.join(path, domain)
            if os.path.isdir(domain_path):
                self._role_db[domain] = []
                for role_file in os.listdir(domain_path):
                    if role_file.endswith('.json'):
                        full_path = os.path.join(domain_path, role_file)
                        try:
                            with open(full_path, 'r', encoding='utf-8') as f:
                                role_profile = json.load(f)
                            self._role_db[domain].append(role_profile)
                        except Exception as e:
                            logger.warning(f"Failed to load role config {full_path}: {e}")

        self._initialized = True
        total_roles = sum(len(roles) for roles in self._role_db.values())
        logger.info(f"Role configurations loaded: {total_roles} roles across {len(self._role_db)} domains")
        return self._role_db

    def get_role_db(self) -> Dict[str, List[Dict]]:
        """获取角色数据库 (如果未初始化则自动加载)"""
        if not self._initialized:
            return self.load_once()
        return self._role_db

    def clear(self):
        """清空缓存 (用于测试)"""
        self._role_db.clear()
        self._initialized = False
        logger.info("Role config cache cleared")


# 全局单例
role_cache = RoleConfigCache()
