"""
Logging configuration for the application.
"""

import logging
import sys


def setup_logger(name: str = "warehouse_ai", level: int = logging.INFO) -> logging.Logger:
    """
    Configure and return the application logger.

    Args:
        name: Logger name.
        level: Logging level.

    Returns:
        Configured Logger instance.
    """
    _logger = logging.getLogger(name)
    _logger.setLevel(level)

    if not _logger.handlers:
        handler = logging.StreamHandler(sys.stdout)
        handler.setLevel(level)
        formatter = logging.Formatter(
            "%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S",
        )
        handler.setFormatter(formatter)
        _logger.addHandler(handler)

    return _logger


logger = setup_logger()
