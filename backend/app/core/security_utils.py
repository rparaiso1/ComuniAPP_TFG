"""
Middleware y utilidades de seguridad para el backend
"""
from fastapi import Request, HTTPException, status
from datetime import datetime, timedelta
from collections import defaultdict
import asyncio
import re
from typing import Optional
import html
import logging

logger = logging.getLogger(__name__)


class RateLimiter:
    """Rate limiter simple basado en memoria"""
    
    def __init__(
        self,
        max_requests: int = 60,
        window_seconds: int = 60,
        block_duration_seconds: int = 300
    ):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self.block_duration_seconds = block_duration_seconds
        self.requests: dict[str, list[datetime]] = defaultdict(list)
        self.blocked: dict[str, datetime] = {}
        self._cleanup_task: Optional[asyncio.Task] = None
    
    def start_cleanup(self):
        """Iniciar tarea de limpieza periódica"""
        if self._cleanup_task is None:
            self._cleanup_task = asyncio.create_task(self._cleanup_loop())
    
    async def _cleanup_loop(self):
        """Limpiar registros antiguos periódicamente"""
        while True:
            await asyncio.sleep(60)
            now = datetime.now()
            cutoff = now - timedelta(seconds=self.window_seconds)
            
            # Limpiar requests antiguos
            for ip in list(self.requests.keys()):
                self.requests[ip] = [t for t in self.requests[ip] if t > cutoff]
                if not self.requests[ip]:
                    del self.requests[ip]
            
            # Limpiar bloqueos expirados
            for ip in list(self.blocked.keys()):
                if self.blocked[ip] < now:
                    del self.blocked[ip]
    
    def is_allowed(self, client_ip: str) -> tuple[bool, Optional[int]]:
        """
        Verificar si una petición está permitida.
        Retorna (permitido, segundos_hasta_desbloqueo)
        """
        now = datetime.now()
        
        # Verificar si está bloqueado
        if client_ip in self.blocked:
            if self.blocked[client_ip] > now:
                remaining = int((self.blocked[client_ip] - now).total_seconds())
                return False, remaining
            else:
                del self.blocked[client_ip]
        
        # Limpiar requests antiguos para este IP
        cutoff = now - timedelta(seconds=self.window_seconds)
        self.requests[client_ip] = [t for t in self.requests[client_ip] if t > cutoff]
        
        # Verificar límite
        if len(self.requests[client_ip]) >= self.max_requests:
            # Bloquear temporalmente
            self.blocked[client_ip] = now + timedelta(seconds=self.block_duration_seconds)
            logger.warning("Rate limit exceeded for IP %s, blocked for %ds", client_ip, self.block_duration_seconds)
            return False, self.block_duration_seconds
        
        # Registrar request
        self.requests[client_ip].append(now)
        return True, None


# Rate limiters específicos para diferentes endpoints
general_limiter = RateLimiter(max_requests=100, window_seconds=60)
auth_limiter = RateLimiter(max_requests=30, window_seconds=60, block_duration_seconds=600)
sensitive_limiter = RateLimiter(max_requests=20, window_seconds=60, block_duration_seconds=300)


class InputSanitizer:
    """Sanitización de inputs para prevenir inyecciones"""
    
    # Patrones peligrosos
    SQL_INJECTION_PATTERNS = [
        r"(\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|ALTER|CREATE|TRUNCATE)\b)",
        r"(--|;|\/\*|\*\/)",
        r"(\bOR\b\s+\d+\s*=\s*\d+)",
        r"(\bAND\b\s+\d+\s*=\s*\d+)",
    ]
    
    XSS_PATTERNS = [
        r"<script[^>]*>.*?</script>",
        r"javascript:",
        r"on\w+\s*=",
        r"<iframe[^>]*>",
    ]
    
    @classmethod
    def sanitize_string(cls, value: str, max_length: int = 1000) -> str:
        """Sanitizar string de entrada"""
        if not value:
            return value
        
        # Limitar longitud
        value = value[:max_length]
        
        # Escapar HTML
        value = html.escape(value)
        
        return value.strip()
    
    @classmethod
    def check_sql_injection(cls, value: str) -> bool:
        """Verificar posibles intentos de SQL injection"""
        if not value:
            return False
        
        for pattern in cls.SQL_INJECTION_PATTERNS:
            if re.search(pattern, value, re.IGNORECASE):
                logger.warning("Possible SQL injection detected: %s", value[:100])
                return True
        return False
    
    @classmethod
    def check_xss(cls, value: str) -> bool:
        """Verificar posibles intentos de XSS"""
        if not value:
            return False
        
        for pattern in cls.XSS_PATTERNS:
            if re.search(pattern, value, re.IGNORECASE):
                logger.warning("Possible XSS detected: %s", value[:100])
                return True
        return False
    
    @classmethod
    def validate_email(cls, email: str) -> bool:
        """Validar formato de email"""
        pattern = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
        return bool(re.match(pattern, email)) and len(email) <= 255
    
    @classmethod
    def validate_uuid(cls, uuid_str: str) -> bool:
        """Validar formato UUID"""
        pattern = r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
        return bool(re.match(pattern, uuid_str, re.IGNORECASE))


def get_client_ip(request: Request) -> str:
    """Obtener IP real del cliente considerando proxies"""
    # Verificar headers de proxy
    forwarded = request.headers.get("X-Forwarded-For")
    if forwarded:
        return forwarded.split(",")[0].strip()
    
    real_ip = request.headers.get("X-Real-IP")
    if real_ip:
        return real_ip
    
    # Fallback al cliente directo
    return request.client.host if request.client else "unknown"


async def check_rate_limit(
    request: Request,
    limiter: RateLimiter = general_limiter
):
    """Dependency para verificar rate limit"""
    client_ip = get_client_ip(request)
    allowed, retry_after = limiter.is_allowed(client_ip)
    
    if not allowed:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=f"Too many requests. Please try again in {retry_after} seconds.",
            headers={"Retry-After": str(retry_after)}
        )


async def check_auth_rate_limit(request: Request):
    """Rate limit específico para endpoints de autenticación"""
    await check_rate_limit(request, auth_limiter)


async def check_sensitive_rate_limit(request: Request):
    """Rate limit para operaciones sensibles"""
    await check_rate_limit(request, sensitive_limiter)
