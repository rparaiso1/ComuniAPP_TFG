from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from app.core.config import settings
from app.core.exceptions import (
    ServiceError, NotFoundError, ForbiddenError,
    ConflictError, UnauthorizedError,
)
from app.core.security_utils import auth_limiter, sensitive_limiter, general_limiter
from app.api import api_router
import logging
import os

logger = logging.getLogger(__name__)

# Note: Database tables creation moved to a separate script (create_tables.py)
# to avoid encoding issues on Windows with special characters in path


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Iniciar tareas de limpieza periódica de los rate limiters."""
    for limiter in (auth_limiter, sensitive_limiter, general_limiter):
        limiter.start_cleanup()
    yield


app = FastAPI(
    title=settings.APP_NAME,
    debug=settings.DEBUG,
    lifespan=lifespan,
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type", "X-Organization-ID"],
)


# ── Service-layer exception handlers ────────────────────────────────
# Los servicios lanzan excepciones semánticas; aquí se mapean a HTTP.

@app.exception_handler(NotFoundError)
async def not_found_handler(request: Request, exc: NotFoundError):
    return JSONResponse(status_code=404, content={"detail": exc.message})


@app.exception_handler(ForbiddenError)
async def forbidden_handler(request: Request, exc: ForbiddenError):
    return JSONResponse(status_code=403, content={"detail": exc.message})


@app.exception_handler(ConflictError)
async def conflict_handler(request: Request, exc: ConflictError):
    return JSONResponse(status_code=409, content={"detail": exc.message})


@app.exception_handler(UnauthorizedError)
async def unauthorized_handler(request: Request, exc: UnauthorizedError):
    return JSONResponse(
        status_code=401, content={"detail": exc.message},
        headers={"WWW-Authenticate": "Bearer"},
    )


@app.exception_handler(ServiceError)
async def service_error_handler(request: Request, exc: ServiceError):
    """Catch-all para ServiceError genéricos → 400."""
    return JSONResponse(status_code=400, content={"detail": exc.message})


# Global exception handler (unhandled errors)
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Catch unhandled exceptions to return a clean JSON response."""
    logger.error("Unhandled exception on %s %s: %s", request.method, request.url, exc, exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error"},
    )


# Include API routes
app.include_router(api_router, prefix="/api")

# Ensure uploads directory exists (files served only via authenticated endpoint)
uploads_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "uploads")
os.makedirs(uploads_dir, exist_ok=True)


@app.get("/")
def root():
    """Root endpoint"""
    return {
        "message": "TFG Backend API",
        "version": "1.0.0",
        "docs": "/docs"
    }


@app.get("/health")
def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}
