"""
Servicio FCM (Firebase Cloud Messaging) para enviar push notifications.

Degradación elegante: si firebase-admin no está instalado o configurado,
las notificaciones push se omiten silenciosamente y solo se guardan en DB.

Configuración:
  1. Instalar: pip install firebase-admin
  2. Descargar la clave de servicio desde Firebase Console:
     Project Settings → Service Accounts → Generate New Private Key
  3. Definir la variable de entorno:
     FIREBASE_CREDENTIALS_PATH=/path/to/serviceAccountKey.json
     (o bien FIREBASE_CREDENTIALS_JSON con el JSON inline)
"""
import logging
from typing import Optional, List
from uuid import UUID

from sqlalchemy.orm import Session

logger = logging.getLogger(__name__)

# Lazy-loaded Firebase App
_firebase_app = None
_firebase_available = False


def _init_firebase():
    """Initialize Firebase Admin SDK lazily. Returns True if successful."""
    global _firebase_app, _firebase_available
    if _firebase_app is not None:
        return _firebase_available

    try:
        import firebase_admin
        from firebase_admin import credentials
        import os

        cred_path = os.environ.get("FIREBASE_CREDENTIALS_PATH")
        cred_json = os.environ.get("FIREBASE_CREDENTIALS_JSON")

        if cred_path and os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
        elif cred_json:
            import json
            cred = credentials.Certificate(json.loads(cred_json))
        else:
            logger.info("FCM: No Firebase credentials configured. Push notifications disabled.")
            _firebase_app = False
            _firebase_available = False
            return False

        _firebase_app = firebase_admin.initialize_app(cred)
        _firebase_available = True
        logger.info("FCM: Firebase initialized successfully. Push notifications enabled.")
        return True

    except ImportError:
        logger.info("FCM: firebase-admin not installed. Push notifications disabled.")
        _firebase_app = False
        _firebase_available = False
        return False
    except Exception as e:
        logger.warning(f"FCM: Error initializing Firebase: {e}. Push notifications disabled.")
        _firebase_app = False
        _firebase_available = False
        return False


class FCMService:
    """Servicio para enviar push notifications via Firebase Cloud Messaging."""

    def __init__(self, db: Session):
        self.db = db

    def register_token(self, user_id: UUID, token: str, platform: str = "web") -> dict:
        """Register or update a device token for a user."""
        from app.models.device_token import DeviceToken

        # Check if token already exists for this user
        existing = self.db.query(DeviceToken).filter(
            DeviceToken.user_id == user_id,
            DeviceToken.token == token,
        ).first()

        if existing:
            existing.platform = platform
            self.db.commit()
            return {"status": "updated", "id": str(existing.id)}

        device_token = DeviceToken(
            user_id=user_id, token=token, platform=platform,
        )
        self.db.add(device_token)
        self.db.commit()
        return {"status": "registered", "id": str(device_token.id)}

    def unregister_token(self, user_id: UUID, token: str) -> bool:
        """Remove a device token."""
        from app.models.device_token import DeviceToken

        deleted = self.db.query(DeviceToken).filter(
            DeviceToken.user_id == user_id,
            DeviceToken.token == token,
        ).delete()
        self.db.commit()
        return deleted > 0

    def unregister_all(self, user_id: UUID) -> int:
        """Remove all device tokens for a user (e.g., on logout)."""
        from app.models.device_token import DeviceToken

        deleted = self.db.query(DeviceToken).filter(
            DeviceToken.user_id == user_id,
        ).delete()
        self.db.commit()
        return deleted

    def get_user_tokens(self, user_id: UUID) -> List[str]:
        """Get all FCM tokens for a user."""
        from app.models.device_token import DeviceToken

        tokens = self.db.query(DeviceToken.token).filter(
            DeviceToken.user_id == user_id,
        ).all()
        return [t[0] for t in tokens]

    def send_to_user(
        self,
        user_id: UUID,
        title: str,
        body: str,
        data: Optional[dict] = None,
    ) -> int:
        """
        Send a push notification to all devices of a user.
        Returns the number of successfully sent messages.
        """
        if not _init_firebase():
            return 0

        tokens = self.get_user_tokens(user_id)
        if not tokens:
            return 0

        return self._send_to_tokens(tokens, title, body, data)

    def send_to_users(
        self,
        user_ids: List[UUID],
        title: str,
        body: str,
        data: Optional[dict] = None,
    ) -> int:
        """Send a push notification to multiple users."""
        if not _init_firebase():
            return 0

        from app.models.device_token import DeviceToken

        tokens = self.db.query(DeviceToken.token).filter(
            DeviceToken.user_id.in_(user_ids),
        ).all()
        token_list = [t[0] for t in tokens]

        if not token_list:
            return 0

        return self._send_to_tokens(token_list, title, body, data)

    def _send_to_tokens(
        self,
        tokens: List[str],
        title: str,
        body: str,
        data: Optional[dict] = None,
    ) -> int:
        """Internal: send FCM messages to a list of tokens."""
        try:
            from firebase_admin import messaging

            # Convert data values to strings (required by FCM)
            str_data = {k: str(v) for k, v in (data or {}).items()}

            messages = [
                messaging.Message(
                    notification=messaging.Notification(title=title, body=body),
                    data=str_data,
                    token=token,
                )
                for token in tokens
            ]

            # Send in batches of 500 (FCM limit)
            sent = 0
            for i in range(0, len(messages), 500):
                batch = messages[i:i + 500]
                response = messaging.send_each(batch)
                sent += response.success_count

                # Clean up invalid tokens
                for j, send_response in enumerate(response.responses):
                    if send_response.exception:
                        error_code = getattr(send_response.exception, 'code', '')
                        if error_code in ('NOT_FOUND', 'INVALID_ARGUMENT', 'UNREGISTERED'):
                            self._remove_invalid_token(tokens[i + j])

            return sent

        except Exception as e:
            logger.error(f"FCM: Error sending push notifications: {e}")
            return 0

    def _remove_invalid_token(self, token: str):
        """Remove an invalid/expired FCM token from the database."""
        from app.models.device_token import DeviceToken

        try:
            self.db.query(DeviceToken).filter(DeviceToken.token == token).delete()
            self.db.commit()
        except Exception:
            self.db.rollback()
