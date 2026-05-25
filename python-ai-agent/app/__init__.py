"""`app` package initializer for python-ai-agent.

This file was missing (only `_init_.py` existed), causing import errors when
uvicorn tried to import `app.main`. Adding a minimal initializer to expose
subpackages used by the application.
"""
from .api import seckill  # re-export routers for convenience

__all__ = ["seckill", "multimodal"]
