"""
Excepciones de servicio — jerarquía semántica desacoplada de HTTP.

Los servicios lanzan estas excepciones con un ``code`` semántico.
Los exception handlers globales en ``main.py`` las mapean a HTTP status codes:

    ServiceError        → 400
    NotFoundError       → 404
    ForbiddenError      → 403
    ConflictError       → 409
    UnauthorizedError   → 401

De esta forma los servicios NO conocen el protocolo HTTP.
"""


class ServiceError(Exception):
    """Base para todos los errores controlados de la capa de servicios."""

    def __init__(self, message: str, code: str = "service_error"):
        self.message = message
        self.code = code
        super().__init__(message)


class NotFoundError(ServiceError):
    """El recurso solicitado no existe."""

    def __init__(self, message: str, code: str = "not_found"):
        super().__init__(message, code)


class ForbiddenError(ServiceError):
    """El usuario no tiene permisos para esta acción."""

    def __init__(self, message: str, code: str = "forbidden"):
        super().__init__(message, code)


class ConflictError(ServiceError):
    """Conflicto de datos (duplicados, solapamientos, etc.)."""

    def __init__(self, message: str, code: str = "conflict"):
        super().__init__(message, code)


class UnauthorizedError(ServiceError):
    """Credenciales inválidas o sesión expirada."""

    def __init__(self, message: str, code: str = "unauthorized"):
        super().__init__(message, code)
