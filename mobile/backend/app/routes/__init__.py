"""Routes package."""

from app.routes import (
    auth,
    users,
    products,
    emplacement,
    chariots,
    orders,
    order_logs,
    operations,
    inventory,
    reports,
    sync,
    ai_agent,
)

__all__ = [
    "auth",
    "users",
    "products",
    "emplacement",
    "chariots",
    "orders",
    "order_logs",
    "operations",
    "inventory",
    "reports",
    "sync",
    "ai_agent",
]
