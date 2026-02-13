"""
Input validators for warehouse operations.
"""

import re
from typing import Optional

from app.core.exceptions import ValidationError


def validate_positive_quantity(quantity: int, field_name: str = "quantity") -> None:
    """Ensure quantity is positive."""
    if quantity <= 0:
        raise ValidationError(f"{field_name} must be greater than 0")


def validate_non_negative_quantity(quantity: int, field_name: str = "quantity") -> None:
    """Ensure quantity is non-negative."""
    if quantity < 0:
        raise ValidationError(f"{field_name} must be non-negative")


def validate_stock_sufficient(available: int, requested: int, product_id: str = "") -> None:
    """
    Validate that available stock is sufficient for the requested quantity.

    Raises:
        ValidationError if insufficient stock.
    """
    if available < requested:
        msg = f"Insufficient stock: available={available}, requested={requested}"
        if product_id:
            msg += f" for product '{product_id}'"
        raise ValidationError(msg)


def validate_coordinates(
    x: int,
    y: int,
    z: int = 0,
    floor: int = 0,
    max_x: int = 1000,
    max_y: int = 1000,
    max_z: int = 50,
    max_floor: int = 10,
) -> None:
    """
    Validate that coordinates are within acceptable bounds.

    Raises:
        ValidationError if coordinates are out of range.
    """
    if not (0 <= x <= max_x):
        raise ValidationError(f"X coordinate must be between 0 and {max_x}, got {x}")
    if not (0 <= y <= max_y):
        raise ValidationError(f"Y coordinate must be between 0 and {max_y}, got {y}")
    if not (0 <= z <= max_z):
        raise ValidationError(f"Z coordinate must be between 0 and {max_z}, got {z}")
    if not (0 <= floor <= max_floor):
        raise ValidationError(f"Floor must be between 0 and {max_floor}, got {floor}")


def validate_location_code(code: str) -> None:
    """
    Validate a location code format (e.g., A-01-02-1).

    Raises:
        ValidationError if format is invalid.
    """
    pattern = r"^[A-Z]-\d{2}-\d{2}-\d+$"
    if not re.match(pattern, code):
        raise ValidationError(
            f"Invalid location code format: '{code}'. Expected format: A-01-02-1"
        )


def validate_email(email: str) -> None:
    """Basic email format validation."""
    pattern = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
    if not re.match(pattern, email):
        raise ValidationError(f"Invalid email format: '{email}'")
