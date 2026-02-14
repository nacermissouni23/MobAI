"""
Warehouse Management System - FastAPI Backend
Main application entry point.
"""

import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config.settings import settings
from app.config.firebase import initialize_firebase
from app.middleware.error_handler import register_exception_handlers
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
from app.utils.logger import logger


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    app = FastAPI(
        title=settings.APP_NAME,
        version=settings.APP_VERSION,
        description="Warehouse Management System with AI Optimization",
        docs_url="/docs",
        redoc_url="/redoc",
    )

    # CORS middleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Initialize Firebase
    initialize_firebase()

    # Register exception handlers
    register_exception_handlers(app)

    # Include routers
    app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
    app.include_router(users.router, prefix="/api/users", tags=["Users"])
    app.include_router(products.router, prefix="/api/products", tags=["Products"])
    app.include_router(emplacement.router, prefix="/api/emplacements", tags=["Emplacements"])
    app.include_router(chariots.router, prefix="/api/chariots", tags=["Chariots"])
    app.include_router(orders.router, prefix="/api/orders", tags=["Orders"])
    app.include_router(order_logs.router, prefix="/api/order-logs", tags=["Order Logs"])
    app.include_router(operations.router, prefix="/api/operations", tags=["Operations"])
    app.include_router(inventory.router, prefix="/api/inventory", tags=["Inventory"])
    app.include_router(reports.router, prefix="/api/reports", tags=["Reports"])
    app.include_router(sync.router, prefix="/api/sync", tags=["Sync"])
    app.include_router(ai_agent.router, prefix="/api/ai", tags=["AI Agent"])

    @app.get("/", tags=["Health"])
    async def root():
        """Health check endpoint."""
        from app.config.firebase import is_firebase_enabled
        
        firebase_status = "connected" if is_firebase_enabled() else "disabled (development mode)"
        
        return {
            "status": "healthy", 
            "app": settings.APP_NAME, 
            "version": settings.APP_VERSION,
            "firebase": firebase_status,
            "mode": "production" if is_firebase_enabled() else "development"
        }

    logger.info(f"Application '{settings.APP_NAME}' v{settings.APP_VERSION} initialized.")
    return app


app = create_app()


if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG,
    )
