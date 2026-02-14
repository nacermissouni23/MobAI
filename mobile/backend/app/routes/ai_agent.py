"""
AI Agent API Routes - Firebase Optional Version
===============================================

Place in: app/routes/ai_agent.py

This version works WITH or WITHOUT Firebase
"""

from fastapi import APIRouter, HTTPException, status
from typing import Dict, Optional
from pydantic import BaseModel, Field

from app.services.warehouse_ai_agent_service import get_ai_agent
from app.utils.logger import get_logger
from app.config.firebase import is_firebase_enabled

router = APIRouter()
logger = get_logger(__name__)

# ============= REQUEST/RESPONSE MODELS =============

class ReceiptRequest(BaseModel):
    """Request for handling product receipt"""
    product_id: str = Field(..., description="Product identifier")
    quantity_palettes: int = Field(..., gt=0, description="Number of palettes")
    poids: Optional[float] = Field(10, description="Weight in kg")
    volume: Optional[float] = Field(0.01, description="Volume in m³")
    fragile: Optional[bool] = Field(False, description="Is fragile (cannot stack)")
    frequence: Optional[int] = Field(2, description="Frequency (1-3, 3=high)")
    
    class Config:
        json_schema_extra = {
            "example": {
                "product_id": "31798",
                "quantity_palettes": 5,
                "poids": 10,
                "volume": 0.01,
                "fragile": False,
                "frequence": 3
            }
        }

class ForecastRequest(BaseModel):
    """Request for demand forecasting"""
    target_date: Optional[str] = Field(None, description="Target date (YYYY-MM-DD)")
    
    class Config:
        json_schema_extra = {
            "example": {
                "target_date": "2026-02-15"
            }
        }

class OverrideRequest(BaseModel):
    """Request for overriding AI decision"""
    decision_id: str
    overridden_by: str
    override_reason: str
    new_decision: Dict
    
    class Config:
        json_schema_extra = {
            "example": {
                "decision_id": "STORAGE-20260214123456",
                "overridden_by": "supervisor@company.com",
                "override_reason": "Better location available",
                "new_decision": {"x": 15, "y": 10, "floor": 2}
            }
        }

# ============= ENDPOINTS =============

@router.get("/health")
async def ai_health_check():
    """
    Check AI agent health status
    
    **Returns**: AI agent status and configuration
    """
    try:
        agent = get_ai_agent()
        
        return {
            "success": True,
            "data": {
                "status": "healthy",
                "firebase": "enabled" if is_firebase_enabled() else "disabled",
                "grid_loaded": len(agent.combined_grid) > 0,
                "elevators": len(agent.elevators),
                "storage_optimizer": agent.storage_optimizer is not None,
                "decision_history_count": len(agent.decision_history)
            }
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }

@router.post("/receipt")
async def handle_receipt(request: ReceiptRequest):
    """
    Handle product receipt - AI recommends storage location
    
    **Workflow**: Product arrives at reception → AI analyzes → Recommends optimal storage
    
    **Used by**: Reception staff, Supervisors
    
    **Note**: Works with or without Firebase
    
    **Returns**: 
    - Recommended storage location
    - Path from elevator to slot
    - Alternative locations
    - AI reasoning
    """
    try:
        logger.info(f"Receipt request: {request.product_id} x{request.quantity_palettes}")
        
        agent = get_ai_agent()
        
        # Prepare product data for YOUR storage optimizer
        product_data = {
            'poids': request.poids,
            'volume': request.volume,
            'fragile': request.fragile,
            'frequence': request.frequence
        }
        
        # If Firebase is enabled, try to get product data from database
        if is_firebase_enabled():
            try:
                from app.repositories.product_repository import ProductRepository
                repo = ProductRepository()
                db_product = await repo.get_by_id(request.product_id)
                if db_product:
                    # Override with DB data if available
                    product_data['poids'] = db_product.get('weight_kg', request.poids)
                    product_data['volume'] = db_product.get('volume_m3', request.volume)
                    # frequence based on demand analysis
            except Exception as e:
                logger.warning(f"Could not fetch product from DB: {e}. Using request data.")
        
        result = await agent.handle_receipt(
            product_id=request.product_id,
            quantity_palettes=request.quantity_palettes,
            product_data=product_data
        )
        
        logger.info(f"Storage recommendation: {result['recommended_location']}")
        
        # If Firebase is enabled, log decision to database
        if is_firebase_enabled():
            try:
                from app.config.firebase import get_db
                db = get_db()
                db.collection('ai_decisions').add({
                    'type': 'storage',
                    'decision_id': result['decision_id'],
                    'product_id': request.product_id,
                    'recommendation': result['recommended_location'],
                    'timestamp': result['timestamp']
                })
            except Exception as e:
                logger.warning(f"Could not log to Firebase: {e}")
        
        return {
            "success": True,
            "data": result
        }
        
    except Exception as e:
        logger.error(f"Receipt handling failed: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Storage optimization failed: {str(e)}"
        )

@router.post("/forecast")
async def run_forecast(request: ForecastRequest):
    """
    Run demand forecasting - AI predicts tomorrow's needs
    
    **Workflow**: Daily (evening) → AI analyzes history → Predicts tomorrow's demand
    
    **Used by**: System (automated), Supervisors, Admins
    
    **Note**: Works with or without Firebase
    
    **Returns**:
    - List of predicted products
    - Quantities needed
    - Confidence scores
    """
    try:
        logger.info(f"Forecast request for: {request.target_date or 'tomorrow'}")
        
        agent = get_ai_agent()
        
        # If Firebase is enabled, prepare input from database
        if is_firebase_enabled():
            try:
                from app.repositories.order_repository import OrderRepository
                repo = OrderRepository()
                # Get historical delivery data from Firebase
                history = await repo.get_delivery_history(days=90)
                # TODO: Save to temp CSV for forecast script
                logger.info(f"Using {len(history)} historical records from Firebase")
            except Exception as e:
                logger.warning(f"Could not fetch history from Firebase: {e}. Using CSV file.")
        
        result = await agent.run_daily_forecast(target_date=request.target_date)
        
        logger.info(f"Forecast generated: {len(result['predictions'])} products")
        
        # If Firebase is enabled, save forecast to database
        if is_firebase_enabled():
            try:
                from app.config.firebase import get_db
                db = get_db()
                db.collection('ai_forecasts').add({
                    'forecast_id': result['forecast_id'],
                    'target_date': result['target_date'],
                    'predictions': result['predictions'],
                    'total_predicted': result['total_predicted_quantity'],
                    'timestamp': result['timestamp']
                })
            except Exception as e:
                logger.warning(f"Could not save forecast to Firebase: {e}")
        
        return {
            "success": True,
            "data": result
        }
        
    except Exception as e:
        logger.error(f"Forecasting failed: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Forecasting failed: {str(e)}"
        )

@router.post("/override")
async def handle_override(request: OverrideRequest):
    """
    Handle supervisor/admin override of AI decision
    
    **Workflow**: Supervisor disagrees with AI → Provides reasoning → System logs for improvement
    
    **Used by**: Supervisors, Admins
    
    **Note**: Logs to Firebase if enabled
    
    **Returns**: Override confirmation
    """
    try:
        logger.info(f"Override request: {request.decision_id}")
        
        agent = get_ai_agent()
        result = await agent.handle_override(
            decision_id=request.decision_id,
            overridden_by=request.overridden_by,
            override_reason=request.override_reason,
            new_decision=request.new_decision
        )
        
        logger.info(f"Override recorded: {result['override_id']}")
        
        # If Firebase is enabled, save override to database
        if is_firebase_enabled():
            try:
                from app.config.firebase import get_db
                db = get_db()
                db.collection('ai_overrides').add({
                    'override_id': result['override_id'],
                    'decision_id': request.decision_id,
                    'overridden_by': request.overridden_by,
                    'override_reason': request.override_reason,
                    'new_decision': request.new_decision,
                    'timestamp': result['timestamp']
                })
            except Exception as e:
                logger.warning(f"Could not save override to Firebase: {e}")
        
        return {
            "success": True,
            "data": result
        }
        
    except Exception as e:
        logger.error(f"Override handling failed: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Override handling failed: {str(e)}"
        )

@router.get("/decisions")
async def get_decision_history(limit: int = 10):
    """
    Get recent AI decisions
    
    **Used by**: Supervisors, Admins (for review)
    
    **Note**: If Firebase enabled, fetches from database; otherwise from memory
    
    **Returns**: List of recent AI decisions with timestamps
    """
    try:
        # Try Firebase first if enabled
        if is_firebase_enabled():
            try:
                from app.config.firebase import get_db
                db = get_db()
                
                # Get from Firebase
                decisions_ref = db.collection('ai_decisions').order_by('timestamp', direction='DESCENDING').limit(limit)
                decisions = [doc.to_dict() for doc in decisions_ref.stream()]
                
                return {
                    "success": True,
                    "data": {
                        "decisions": decisions,
                        "count": len(decisions),
                        "source": "firebase"
                    }
                }
            except Exception as e:
                logger.warning(f"Could not fetch from Firebase: {e}. Using memory.")
        
        # Fallback to memory
        agent = get_ai_agent()
        decisions = agent.get_decision_history(limit=limit)
        
        return {
            "success": True,
            "data": {
                "decisions": decisions,
                "count": len(decisions),
                "source": "memory"
            }
        }
        
    except Exception as e:
        logger.error(f"Decision history retrieval failed: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve decisions: {str(e)}"
        )
