"""
CODESYS Compilation Client for RL_MAR Pipeline.

Provides ST code validation via the CODESYS compilation service.
Assumes session and project are already initialized by example_client.py (start.bat).
Usage:
    client = CodesysClient()
    result = client.compile_code(st_code)
    # result = {"success": True, "errors": []}
"""

import os
import re
import time
import socket
import logging
import requests
from typing import Dict, List, Optional
from loguru import logger


def _get_local_ip() -> str:
    """Auto-detect LAN IPv4 address (same logic as HTTP_SERVER.py)."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('8.8.8.8', 80))
        return s.getsockname()[0]
    except Exception:
        return '127.0.0.1'
    finally:
        s.close()


class CodesysClient:
    """HTTP client for CODESYS compilation service.

    Session and project lifecycle is managed externally by example_client.py.
    This client only calls /pou/workflow to compile code snippets.
    """

    def __init__(self, host: Optional[str] = None, port: Optional[int] = None, api_key: str = "admin"):
        default_host = _get_local_ip()
        self.host = host or os.getenv("CODESYS_HOST", default_host)
        self.port = port or int(os.getenv("CODESYS_PORT", "9000"))
        self.api_key = api_key
        self.base_url = f"http://{self.host}:{self.port}/api/v1"
        logger.info(f"CODESYS client initialized: {self.base_url}")
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'ApiKey {self.api_key}',
            'Content-Type': 'application/json'
        })

    def compile_code(self, st_code: str) -> Dict:
        """
        Send ST code to CODESYS for compilation validation.

        Returns:
            {"success": bool, "errors": [{"ErrorDesc": str, ...}], "api_success": bool}
        """
        if not st_code or not st_code.strip():
            return {"success": False, "api_success": False, "errors": [{"ErrorDesc": "Empty code"}], "validation_time": 0.0}

        url = f"{self.base_url}/pou/workflow"
        payload = {"Code": st_code}

        try:
            start = time.time()
            response = self.session.post(url, json=payload, timeout=120)
            duration = time.time() - start

            if response.status_code != 200:
                return {
                    "success": False,
                    "api_success": False,
                    "errors": [{"ErrorDesc": f"API error: {response.status_code}"}],
                    "validation_time": duration
                }

            result = response.json()
            # Default Success=False to prevent false positives (same as CODESYSValidator)
            api_ok = result.get("Success", False)
            errors = result.get("Errors", [])
            compilation_ok = api_ok and not errors

            return {
                "success": compilation_ok,
                "api_success": api_ok,
                "errors": errors,
                "validation_time": duration
            }

        except requests.exceptions.ConnectionError:
            logger.warning(f"CODESYS server not reachable at {self.host}:{self.port}")
            return {"success": False, "api_success": False, "errors": [{"ErrorDesc": f"CODESYS unreachable at {self.host}:{self.port}"}], "validation_time": 0.0}
        except requests.exceptions.Timeout:
            return {"success": False, "api_success": False, "errors": [{"ErrorDesc": "CODESYS timeout"}], "validation_time": 120.0}
        except Exception as e:
            return {"success": False, "api_success": False, "errors": [{"ErrorDesc": str(e)}], "validation_time": 0.0}


# Global singleton for reuse across the pipeline
_codesys_client: Optional[CodesysClient] = None


def get_codesys_client() -> CodesysClient:
    """Get or create the global CODESYS client singleton."""
    global _codesys_client
    if _codesys_client is None:
        _codesys_client = CodesysClient()
    return _codesys_client
