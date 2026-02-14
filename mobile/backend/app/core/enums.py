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
    """Status of a warehouse operation."""
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    FAILED = "failed"


class OrderStatus(str, Enum):
    """Status of a warehouse order."""
    PENDING = "pending"
    AI_GENERATED = "ai_generated"
    VALIDATED = "validated"
    OVERRIDDEN = "overridden"
    COMPLETED = "completed"


class DeliveryStatus(str, Enum):
    """Status of a delivery."""
    VALIDATED = "validated"
    FAILED = "failed"
