"""
Helper utilities: distance calculators, formatting, etc.
"""

import math
from typing import Tuple


def euclidean_distance(
    p1: Tuple[int, int, int, int],
    p2: Tuple[int, int, int, int],
) -> float:
    """
    Calculate Euclidean distance between two 4D points (x, y, z, floor).

    Args:
        p1: Tuple of (x, y, z, floor).
        p2: Tuple of (x, y, z, floor).

    Returns:
        Euclidean distance.
    """
    return math.sqrt(
        (p1[0] - p2[0]) ** 2
        + (p1[1] - p2[1]) ** 2
        + (p1[2] - p2[2]) ** 2
        + (p1[3] - p2[3]) ** 2 * 100  # Floor changes are expensive
    )


def manhattan_distance(
    p1: Tuple[int, int, int, int],
    p2: Tuple[int, int, int, int],
) -> int:
    """
    Calculate Manhattan distance between two 4D points (x, y, z, floor).

    Args:
        p1: Tuple of (x, y, z, floor).
        p2: Tuple of (x, y, z, floor).

    Returns:
        Manhattan distance (floor changes weighted).
    """
    return (
        abs(p1[0] - p2[0])
        + abs(p1[1] - p2[1])
        + abs(p1[2] - p2[2])
        + abs(p1[3] - p2[3]) * 10  # Floor changes are expensive
    )


def generate_location_code(floor: int, row: int, col: int, level: int = 0) -> str:
    """
    Generate a human-readable location code.

    Format: F-RR-CC-L (Floor-Row-Col-Level)

    Args:
        floor: Floor number.
        row: Row number (Y coordinate).
        col: Column number (X coordinate).
        level: Shelf level (Z coordinate).

    Returns:
        Location code string (e.g., "A-01-02-1").
    """
    floor_letter = chr(65 + floor)  # A=0, B=1, C=2, ...
    return f"{floor_letter}-{row:02d}-{col:02d}-{level}"


def parse_location_code(code: str) -> Tuple[int, int, int, int]:
    """
    Parse a location code into (floor, row, col, level).

    Args:
        code: Location code string (e.g., "A-01-02-1").

    Returns:
        Tuple of (floor, row, col, level).
    """
    parts = code.split("-")
    floor = ord(parts[0]) - 65
    row = int(parts[1])
    col = int(parts[2])
    level = int(parts[3])
    return floor, row, col, level


def format_datetime(dt) -> str:
    """Format a datetime to ISO string, handling None."""
    if dt is None:
        return ""
    if isinstance(dt, str):
        return dt
    return dt.isoformat()
