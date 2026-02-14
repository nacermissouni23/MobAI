"""
Order log routes: read-only access to order lifecycle logs.
"""

from typing import Dict, Any, List, Optional

from fastapi import APIRouter, Depends, Query

from app.repositories.order_log_repository import OrderLogRepository
from app.schemas.order_log import OrderLogResponse
from app.utils.dependencies import get_current_user, get_supervisor_user

router = APIRouter()
order_log_repo = OrderLogRepository()


@router.get("/", response_model=List[OrderLogResponse])
async def list_order_logs(
    _user: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Get all order logs. Supervisor/Admin only."""
    logs = await order_log_repo.get_all()
    return [OrderLogResponse(**log) for log in logs]


@router.get("/order/{order_id}", response_model=List[OrderLogResponse])
async def get_order_logs(
    order_id: str,
    _user: Dict[str, Any] = Depends(get_current_user),
):
    """Get all logs for a specific order."""
    logs = await order_log_repo.get_by_order(order_id)
    return [OrderLogResponse(**log) for log in logs]
