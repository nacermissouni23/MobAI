"""
Application enumerations for the Warehouse Management System.
"""

from enum import Enum


class UserRole(str, Enum):
    """User role within the warehouse system."""
    ADMIN = "admin"
    SUPERVISOR = "supervisor"
    EMPLOYEE = "employee"


class OperationType(str, Enum):
    """Types of warehouse operations."""
    RECEIPT = "receipt"
    TRANSFER = "transfer"
    PICKING = "picking"
    DELIVERY = "delivery"


class OrderType(str, Enum):
    """Types of warehouse orders."""
    COMMAND = "command"
    PREPARATION = "preparation"
    PICKING = "picking"


class OperationStatus(str, Enum):
    """Lifecycle status of an operation."""
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    VALIDATED = "validated"


class OrderStatus(str, Enum):
    """Lifecycle status of an order."""
    PENDING = "pending"
    VALIDATED = "validated"
