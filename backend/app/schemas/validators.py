"""
Validadores compartidos para schemas Pydantic.

Centraliza reglas de validación reutilizadas en múltiples schemas
para evitar duplicación y facilitar el mantenimiento.
"""


def validate_password_strength(password: str) -> str:
    """Valida que una contraseña cumpla los requisitos mínimos de seguridad.

    Reglas:
      - Mínimo 8 caracteres
      - Al menos una letra mayúscula
      - Al menos una letra minúscula
      - Al menos un dígito

    Raises:
        ValueError: si la contraseña no cumple alguna regla.
    Returns:
        La contraseña sin modificar.
    """
    if len(password) < 8:
        raise ValueError("La contraseña debe tener al menos 8 caracteres")
    if not any(c.isupper() for c in password):
        raise ValueError("La contraseña debe contener al menos una letra mayúscula")
    if not any(c.islower() for c in password):
        raise ValueError("La contraseña debe contener al menos una letra minúscula")
    if not any(c.isdigit() for c in password):
        raise ValueError("La contraseña debe contener al menos un dígito")
    return password
