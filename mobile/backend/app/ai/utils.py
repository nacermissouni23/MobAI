"""
AI utility functions shared across optimization modules.
"""

import math
from typing import Dict, List, Tuple, Any


def normalize(values: List[float]) -> List[float]:
    """
    Min-max normalize a list of values to [0, 1].

    Args:
        values: List of numeric values.

    Returns:
        Normalized list. If min==max, returns all 0.5.
    """
    if not values:
        return []
    min_val = min(values)
    max_val = max(values)
    if max_val == min_val:
        return [0.5] * len(values)
    return [(v - min_val) / (max_val - min_val) for v in values]


def weighted_score(factors: Dict[str, float], weights: Dict[str, float]) -> float:
    """
    Calculate a weighted score from factor values and their weights.

    Args:
        factors: Dict of factor_name -> value (should be normalized 0-1).
        weights: Dict of factor_name -> weight.

    Returns:
        Weighted sum.
    """
    total = 0.0
    for name, value in factors.items():
        w = weights.get(name, 0.0)
        total += value * w
    return total


def euclidean_distance_3d(p1: Tuple[float, ...], p2: Tuple[float, ...]) -> float:
    """Calculate Euclidean distance between two points (any dimension)."""
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(p1, p2)))


def manhattan_distance_3d(p1: Tuple[int, ...], p2: Tuple[int, ...]) -> int:
    """Calculate Manhattan distance between two points (any dimension)."""
    return sum(abs(a - b) for a, b in zip(p1, p2))


def calculate_demand_score(demand_frequency: float, max_frequency: float) -> float:
    """
    Calculate a normalized demand score.

    Higher demand = higher score = should be placed closer to expedition.

    Args:
        demand_frequency: Product demand frequency.
        max_frequency: Maximum demand frequency across all products.

    Returns:
        Score between 0 and 1.
    """
    if max_frequency <= 0:
        return 0.0
    return min(demand_frequency / max_frequency, 1.0)


def calculate_weight_score(weight: float, max_weight: float) -> float:
    """
    Calculate a normalized weight score.

    Heavier items should be stored at lower levels.

    Args:
        weight: Product weight (kg).
        max_weight: Maximum weight across all products.

    Returns:
        Score between 0 and 1 (higher = heavier).
    """
    if max_weight <= 0:
        return 0.0
    return min(weight / max_weight, 1.0)
