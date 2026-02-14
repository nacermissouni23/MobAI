"""
Global exception handler middleware for the FastAPI application.
"""

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from app.core.exceptions import (
    AppBaseException,
    NotFoundError,
    ValidationError,
    StockError,
    ConflictError,
    AuthenticationError,
    AuthorizationError,
)
from app.utils.logger import logger


def register_exception_handlers(app: FastAPI) -> None:
    """Register global exception handlers on the FastAPI app."""

    @app.exception_handler(AppBaseException)
    async def app_exception_handler(request: Request, exc: AppBaseException):
        """Handle all custom application exceptions."""
        logger.warning(f"{exc.__class__.__name__}: {exc.message} | Path: {request.url.path}")
        return JSONResponse(
            status_code=exc.status_code,
            content={
                "error": exc.__class__.__name__,
                "message": exc.message,
                "details": exc.details,
            },
        )

    @app.exception_handler(NotFoundError)
    async def not_found_handler(request: Request, exc: NotFoundError):
        logger.info(f"NotFoundError: {exc.message} | Path: {request.url.path}")
        return JSONResponse(
            status_code=404,
            content={"error": "NotFoundError", "message": exc.message},
        )

    @app.exception_handler(ValidationError)
    async def validation_handler(request: Request, exc: ValidationError):
        logger.warning(f"ValidationError: {exc.message} | Path: {request.url.path}")
        return JSONResponse(
            status_code=422,
            content={"error": "ValidationError", "message": exc.message, "details": exc.details},
        )

    @app.exception_handler(StockError)
    async def stock_handler(request: Request, exc: StockError):
        logger.warning(f"StockError: {exc.message} | Path: {request.url.path}")
        return JSONResponse(
            status_code=400,
            content={"error": "StockError", "message": exc.message, "details": exc.details},
        )

    @app.exception_handler(ConflictError)
    async def conflict_handler(request: Request, exc: ConflictError):
        logger.warning(f"ConflictError: {exc.message} | Path: {request.url.path}")
        return JSONResponse(
            status_code=409,
            content={"error": "ConflictError", "message": exc.message},
        )

    @app.exception_handler(AuthenticationError)
    async def auth_handler(request: Request, exc: AuthenticationError):
        logger.warning(f"AuthenticationError: {exc.message} | Path: {request.url.path}")
        return JSONResponse(
            status_code=401,
            content={"error": "AuthenticationError", "message": exc.message},
        )

    @app.exception_handler(AuthorizationError)
    async def authz_handler(request: Request, exc: AuthorizationError):
        logger.warning(f"AuthorizationError: {exc.message} | Path: {request.url.path}")
        return JSONResponse(
            status_code=403,
            content={"error": "AuthorizationError", "message": exc.message},
        )

    @app.exception_handler(Exception)
    async def general_exception_handler(request: Request, exc: Exception):
        """Catch-all for unhandled exceptions."""
        logger.error(f"Unhandled exception: {str(exc)} | Path: {request.url.path}", exc_info=True)
        return JSONResponse(
            status_code=500,
            content={
                "error": "InternalServerError",
                "message": "An unexpected error occurred. Please try again later.",
            },
        )
