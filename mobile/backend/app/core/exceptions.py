"""
Custom exception classes for the Warehouse Management System.
"""

from typing import Any, Optional


class AppBaseException(Exception):
    """Base exception for the application."""

    def __init__(self, message: str, status_code: int = 500, details: Optional[Any] = None):
        self.message = message
        self.status_code = status_code
        self.details = details
        super().__init__(self.message)


class NotFoundError(AppBaseException):
    """Raised when a requested resource is not found."""

    def __init__(self, resource: str, identifier: Any = None):
        message = f"{resource} not found"
        if identifier:
            message = f"{resource} with id '{identifier}' not found"
        super().__init__(message=message, status_code=404)


class ValidationError(AppBaseException):
    """Raised when input validation fails."""

    def __init__(self, message: str = "Validation error", details: Optional[Any] = None):
        super().__init__(message=message, status_code=422, details=details)


class StockError(AppBaseException):
    """Raised when a stock operation fails (insufficient stock, etc.)."""

    def __init__(self, message: str = "Stock error", details: Optional[Any] = None):
        super().__init__(message=message, status_code=400, details=details)


class ConflictError(AppBaseException):
    """Raised when there is a data conflict (duplicate, etc.)."""

    def __init__(self, message: str = "Conflict error", details: Optional[Any] = None):
        super().__init__(message=message, status_code=409, details=details)


class AuthenticationError(AppBaseException):
    """Raised when authentication fails."""

    def __init__(self, message: str = "Authentication failed"):
        super().__init__(message=message, status_code=401)


class AuthorizationError(AppBaseException):
    """Raised when the user lacks required permissions."""

    def __init__(self, message: str = "Insufficient permissions"):
        super().__init__(message=message, status_code=403)
