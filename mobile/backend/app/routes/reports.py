"""
Report routes: CRUD for operation anomaly reports and statistics.
"""

from typing import Dict, Any, List, Optional

from fastapi import APIRouter, Depends, Query

from app.repositories.report_repository import ReportRepository
from app.schemas.report import ReportCreate, ReportResponse
from app.utils.dependencies import get_supervisor_user, get_current_user

router = APIRouter()
report_repo = ReportRepository()


@router.get("/", response_model=List[ReportResponse])
async def list_reports(
    operation_id: Optional[str] = Query(default=None, description="Filter by operation"),
    damage_only: bool = Query(default=False, description="Only reports with physical damage"),
    _supervisor: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Get all reports with optional filters. Supervisor/Admin only."""
    reports = await report_repo.get_filtered(
        operation_id=operation_id,
        damage_only=damage_only,
    )
    return [ReportResponse(**r) for r in reports]


@router.get("/{report_id}", response_model=ReportResponse)
async def get_report(
    report_id: str,
    _supervisor: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Get a single report by ID. Supervisor/Admin only."""
    report = await report_repo.get_by_id_or_raise(report_id)
    return ReportResponse(**report)


@router.post("/", response_model=ReportResponse, status_code=201)
async def create_report(
    data: ReportCreate,
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """Create a new anomaly report. Any authenticated user (including employees)."""
    report_data = data.model_dump()
    report_data["reported_by"] = current_user["id"]
    created = await report_repo.create(report_data)
    return ReportResponse(**created)


@router.delete("/{report_id}", status_code=204)
async def delete_report(
    report_id: str,
    _supervisor: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Delete a report. Supervisor/Admin only."""
    await report_repo.delete(report_id)


@router.get("/operation/{operation_id}/reports", response_model=List[ReportResponse])
async def get_operation_reports(
    operation_id: str,
    _supervisor: Dict[str, Any] = Depends(get_supervisor_user),
):
    """Get all reports for a specific operation. Supervisor/Admin only."""
    reports = await report_repo.get_by_operation(operation_id)
    return [ReportResponse(**r) for r in reports]


@router.get("/statistics/summary", response_model=dict)
async def get_report_statistics(
    _supervisor: Dict[str, Any] = Depends(get_supervisor_user),
):
    """
    Get summary statistics for all reports. Supervisor/Admin only.

    Returns counts of total reports, damage reports, missing quantities, etc.
    """
    all_reports = await report_repo.get_all()

    total = len(all_reports)
    damage_count = sum(1 for r in all_reports if r.get("physical_damage", False))
    total_missing = sum(r.get("missing_quantity", 0) for r in all_reports)
    total_extra = sum(r.get("extra_quality", 0) for r in all_reports)
    with_missing = sum(1 for r in all_reports if r.get("missing_quantity", 0) > 0)
    with_extra = sum(1 for r in all_reports if r.get("extra_quality", 0) > 0)

    return {
        "total_reports": total,
        "damage_reports": damage_count,
        "reports_with_missing": with_missing,
        "reports_with_extra": with_extra,
        "total_missing_quantity": total_missing,
        "total_extra_quality": total_extra,
    }
