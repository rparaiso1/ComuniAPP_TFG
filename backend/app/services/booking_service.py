"""
Servicio de reservas — validación de reglas y operaciones CRUD.
"""
from sqlalchemy.orm import Session, joinedload, contains_eager
from sqlalchemy import func
from datetime import datetime, date, timedelta, timezone
from uuid import UUID
from typing import List, Optional

from app.models.booking import Booking, BookingStatus
from app.models.zone import Zone
from app.schemas.booking import BookingCreate, BookingUpdate, BookingResponse
from app.core.exceptions import ServiceError, NotFoundError, ForbiddenError, ConflictError


class BookingService:

    def __init__(self, db: Session):
        self.db = db

    # ---- Helpers ----

    @staticmethod
    def to_response(booking: Booking) -> BookingResponse:
        return BookingResponse(
            id=booking.id,
            zone_id=booking.zone_id,
            zone_name=booking.zone.name if booking.zone else None,
            zone_type=booking.zone.zone_type if booking.zone else None,
            user_id=booking.user_id,
            user_name=booking.user.full_name if booking.user else None,
            organization_id=booking.organization_id,
            start_time=booking.start_time,
            end_time=booking.end_time,
            status=booking.status,
            notes=booking.notes,
            cancellation_reason=booking.cancellation_reason,
            cancelled_at=booking.cancelled_at,
            created_at=booking.created_at,
            updated_at=booking.updated_at,
        )

    def _validate_rules(
        self, zone: Zone, user_id: UUID,
        start_time: datetime, end_time: datetime,
        exclude_id: UUID = None,
    ):
        now = datetime.now(timezone.utc)
        # Normalize timezone for comparison
        st = start_time if start_time.tzinfo else start_time.replace(tzinfo=timezone.utc)
        et = end_time if end_time.tzinfo else end_time.replace(tzinfo=timezone.utc)
        if st < now:
            raise ServiceError("No se puede reservar en el pasado")
        duration_hours = (et - st).total_seconds() / 3600
        if duration_hours > zone.max_booking_hours:
            raise ServiceError(f"Duración máxima: {zone.max_booking_hours}h. Solicitado: {duration_hours:.1f}h")
        if zone.available_from and st.time() < zone.available_from:
            raise ServiceError(f"La zona abre a las {zone.available_from.strftime('%H:%M')}")
        if zone.available_until and et.time() > zone.available_until:
            raise ServiceError(f"La zona cierra a las {zone.available_until.strftime('%H:%M')}")
        days_ahead = (st.date() - now.date()).days
        if days_ahead > zone.advance_booking_days:
            raise ServiceError(f"Solo se puede reservar con {zone.advance_booking_days} días de antelación")

        # Solapamiento (con lock FOR UPDATE para evitar race conditions)
        overlap = self.db.query(Booking).filter(
            Booking.zone_id == zone.id,
            Booking.status.in_([BookingStatus.CONFIRMED, BookingStatus.PENDING]),
            Booking.start_time < end_time,
            Booking.end_time > start_time,
        ).with_for_update()
        if exclude_id:
            overlap = overlap.filter(Booking.id != exclude_id)
        if overlap.first():
            raise ConflictError("Ya existe una reserva en esa zona para ese horario")

        # Límite diario
        booking_date = start_time.date()
        day_start = datetime.combine(booking_date, datetime.min.time()).replace(tzinfo=timezone.utc)
        day_end = day_start + timedelta(days=1)
        user_day = self.db.query(func.count(Booking.id)).filter(
            Booking.zone_id == zone.id,
            Booking.user_id == user_id,
            Booking.status.in_([BookingStatus.CONFIRMED, BookingStatus.PENDING]),
            Booking.start_time >= day_start,
            Booking.start_time < day_end,
        )
        if exclude_id:
            user_day = user_day.filter(Booking.id != exclude_id)
        if (user_day.scalar() or 0) >= zone.max_bookings_per_user_day:
            raise ServiceError(f"Máximo {zone.max_bookings_per_user_day} reserva(s) por día en esta zona")

    # ---- CRUD ----

    def create(self, data: BookingCreate, user_id: UUID, org_ids: List[UUID]) -> Booking:
        zone = self.db.query(Zone).filter(
            Zone.id == data.zone_id, Zone.organization_id.in_(org_ids), Zone.is_active == True,
        ).first()
        if not zone:
            raise NotFoundError("Zona no encontrada o no disponible")
        self._validate_rules(zone, user_id, data.start_time, data.end_time)
        booking = Booking(
            zone_id=zone.id, user_id=user_id, organization_id=zone.organization_id,
            start_time=data.start_time, end_time=data.end_time, notes=data.notes,
            status=BookingStatus.PENDING if zone.requires_approval else BookingStatus.CONFIRMED,
        )
        self.db.add(booking)
        self.db.commit()
        self.db.refresh(booking)
        return booking

    def list(
        self, org_ids: List[UUID], user_id: UUID = None,
        zone_id: UUID = None, date_from: date = None, date_to: date = None,
        skip: int = 0, limit: int = 100,
    ) -> List[Booking]:
        query = self.db.query(Booking).filter(Booking.organization_id.in_(org_ids))
        if zone_id:
            query = query.filter(Booking.zone_id == zone_id)
        if date_from:
            query = query.filter(Booking.start_time >= datetime.combine(date_from, datetime.min.time()))
        if date_to:
            query = query.filter(Booking.start_time <= datetime.combine(date_to, datetime.max.time()))
        if user_id:
            query = query.filter(Booking.user_id == user_id)
        return (
            query.options(joinedload(Booking.user))
            .join(Zone, Booking.zone_id == Zone.id)
            .options(contains_eager(Booking.zone))
            .order_by(Zone.zone_type, Booking.start_time.asc()).offset(skip).limit(limit).all()
        )

    def get(self, booking_id: UUID, org_ids: List[UUID]) -> Booking:
        booking = (
            self.db.query(Booking)
            .options(joinedload(Booking.zone), joinedload(Booking.user))
            .filter(
                Booking.id == booking_id, Booking.organization_id.in_(org_ids),
            ).first()
        )
        if not booking:
            raise NotFoundError("Reserva no encontrada")
        return booking

    def update(self, booking_id: UUID, data: BookingUpdate, user_id: UUID, org_ids: List[UUID], is_admin: bool) -> Booking:
        booking = self.get(booking_id, org_ids)
        if booking.user_id != user_id and not is_admin:
            raise ForbiddenError("No tienes permisos")
        if booking.status == BookingStatus.CANCELLED:
            raise ServiceError("No se puede modificar una reserva cancelada")
        if data.start_time or data.end_time:
            self._validate_rules(
                booking.zone, user_id,
                data.start_time or booking.start_time,
                data.end_time or booking.end_time,
                exclude_id=booking.id,
            )
        for field, value in data.model_dump(exclude_unset=True).items():
            setattr(booking, field, value)
        self.db.commit()
        self.db.refresh(booking)
        return booking

    def cancel(self, booking_id: UUID, user_id: UUID, org_ids: List[UUID], is_admin: bool, reason: str = None) -> Booking:
        booking = self.get(booking_id, org_ids)
        if booking.user_id != user_id and not is_admin:
            raise ForbiddenError("No tienes permisos")
        if booking.status == BookingStatus.CANCELLED:
            raise ServiceError("La reserva ya está cancelada")
        booking.cancel(reason)
        self.db.commit()
        self.db.refresh(booking)
        return booking

    def approve(self, booking_id: UUID, org_ids: List[UUID]) -> Booking:
        booking = self.get(booking_id, org_ids)
        if booking.status != BookingStatus.PENDING:
            raise ServiceError("Solo se pueden aprobar reservas pendientes")
        booking.status = BookingStatus.CONFIRMED
        self.db.commit()
        self.db.refresh(booking)
        return booking
