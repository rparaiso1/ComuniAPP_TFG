"""
Router de reservas — delega la lógica de negocio a BookingService.
"""
from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import date
from uuid import UUID

from app.core.database import get_db
from app.core.deps import get_current_user, get_filtered_org_ids, is_admin_or_president_in_org
from app.models.user import User
from app.models.notification import NotificationType
from app.schemas.booking import BookingCreate, BookingUpdate, BookingResponse, BookingCancelRequest
from app.services.booking_service import BookingService
from app.services.notification_service import NotificationService

router = APIRouter()


@router.post("", response_model=BookingResponse, status_code=status.HTTP_201_CREATED)
def create_booking(
    request: Request,
    booking_data: BookingCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Crear una nueva reserva con validación de reglas."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    booking = BookingService(db).create(booking_data, current_user.id, org_ids)
    zone_name = booking.zone.name if booking.zone else "zona"
    msg = f"Tu reserva en {zone_name} ha sido {'registrada (pendiente de aprobación)' if booking.status == 'pending' else 'confirmada'}"
    NotificationService(db).create(
        user_id=current_user.id, title="Reserva creada", message=msg,
        notification_type=NotificationType.BOOKING, link=f"/bookings/{booking.id}",
    )
    # Notify leaders when booking needs approval
    if str(getattr(booking.status, 'value', booking.status)) == 'pending':
        NotificationService(db).broadcast_to_leaders(
            organization_id=booking.organization_id,
            title="Reserva pendiente de aprobación",
            message=f"{current_user.full_name} solicitó una reserva en {zone_name} que requiere aprobación",
            notification_type=NotificationType.BOOKING,
            link=f"/bookings/{booking.id}",
            exclude_user_id=current_user.id,
        )
    return BookingService.to_response(booking)


@router.get("", response_model=List[BookingResponse])
def get_bookings(
    request: Request,
    zone_id: Optional[UUID] = None,
    date_from: Optional[date] = None,
    date_to: Optional[date] = None,
    my_only: bool = False,
    skip: int = 0,
    limit: int = Query(default=100, le=500),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Obtener reservas con filtros."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    bookings = BookingService(db).list(
        org_ids, current_user.id if my_only else None,
        zone_id=zone_id, date_from=date_from, date_to=date_to,
        skip=skip, limit=limit,
    )
    is_elevated = is_admin_or_president_in_org(db, current_user, org_ids)
    result = []
    for b in bookings:
        resp = BookingService.to_response(b)
        # Mask other users' names for regular neighbors (privacy)
        if not is_elevated and b.user_id != current_user.id:
            resp = resp.model_copy(update={"user_name": None})
        result.append(resp)
    return result


@router.get("/{booking_id}", response_model=BookingResponse)
def get_booking(
    request: Request,
    booking_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Obtener detalle de una reserva."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    booking = BookingService(db).get(booking_id, org_ids)
    return BookingService.to_response(booking)


@router.put("/{booking_id}", response_model=BookingResponse)
def update_booking(
    request: Request,
    booking_id: UUID,
    booking_data: BookingUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Actualizar una reserva (propietario o admin/presidente)."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    booking = BookingService(db).update(
        booking_id, booking_data, current_user.id,
        org_ids, is_admin_or_president_in_org(db, current_user, org_ids),
    )
    return BookingService.to_response(booking)


@router.post("/{booking_id}/cancel", response_model=BookingResponse)
def cancel_booking(
    request: Request,
    booking_id: UUID,
    cancel_data: BookingCancelRequest = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Cancelar una reserva."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    reason = cancel_data.reason if cancel_data else None
    booking = BookingService(db).cancel(
        booking_id, current_user.id,
        org_ids, is_admin_or_president_in_org(db, current_user, org_ids), reason,
    )
    if booking.user_id != current_user.id:
        NotificationService(db).create(
            user_id=booking.user_id, title="Reserva cancelada",
            message=f"Tu reserva ha sido cancelada{' por: ' + reason if reason else ''}",
            notification_type=NotificationType.BOOKING, link=f"/bookings/{booking.id}",
        )
    return BookingService.to_response(booking)


@router.post("/{booking_id}/approve", response_model=BookingResponse)
def approve_booking(
    request: Request,
    booking_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Aprobar una reserva pendiente (admin/presidente)."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    if not is_admin_or_president_in_org(db, current_user, org_ids):
        raise HTTPException(status_code=403, detail="Solo admin/presidente pueden aprobar")
    booking = BookingService(db).approve(booking_id, org_ids)
    NotificationService(db).create(
        user_id=booking.user_id, title="Reserva aprobada",
        message="Tu reserva ha sido aprobada y confirmada",
        notification_type=NotificationType.BOOKING, link=f"/bookings/{booking.id}",
    )
    return BookingService.to_response(booking)
