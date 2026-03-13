"""
Servicio de calendario — eventos, vista mensual, hoy, próximos.
"""
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import and_, or_
from datetime import date, timedelta
from uuid import UUID
from typing import List, Optional

from app.models.booking import Booking, BookingStatus
from app.models.zone import Zone


class CalendarService:

    def __init__(self, db: Session):
        self.db = db

    def get_events(
        self,
        org_ids: List[UUID],
        start_date: Optional[date] = None,
        end_date: Optional[date] = None,
        event_type: Optional[str] = None,
    ) -> list:
        if not start_date:
            today = date.today()
            start_date = today.replace(day=1)
        if not end_date:
            next_month = start_date.replace(day=28) + timedelta(days=4)
            end_date = next_month - timedelta(days=next_month.day)

        events = []

        bookings = (
            self.db.query(Booking)
            .options(joinedload(Booking.zone), joinedload(Booking.user))
            .filter(
                Booking.organization_id.in_(org_ids),
                Booking.status.in_([BookingStatus.CONFIRMED, BookingStatus.PENDING]),
                or_(
                    and_(Booking.start_time >= start_date, Booking.start_time <= end_date),
                    and_(Booking.end_time >= start_date, Booking.end_time <= end_date),
                ),
            )
            .all()
        )

        for booking in bookings:
            color = "#22C55E" if booking.status == BookingStatus.CONFIRMED else "#FBBF24"
            zone_name = booking.zone.name if booking.zone else "Instalación"
            events.append({
                "id": booking.id,
                "title": f"Reserva: {zone_name}",
                "description": booking.notes,
                "start_date": booking.start_time,
                "end_date": booking.end_time,
                "event_type": "booking",
                "color": color,
                "all_day": False,
                "location": zone_name,
                "created_by": booking.user.full_name if booking.user else None,
            })

        if event_type:
            events = [e for e in events if e["event_type"] == event_type]

        events.sort(key=lambda x: x["start_date"])
        return events

    def get_month(self, org_ids: List[UUID], year: int, month: int) -> dict:
        if month < 1 or month > 12:
            raise ValueError("Mes inválido")

        start_date = date(year, month, 1)
        if month == 12:
            end_date = date(year + 1, 1, 1) - timedelta(days=1)
        else:
            end_date = date(year, month + 1, 1) - timedelta(days=1)

        events = self.get_events(org_ids, start_date, end_date)
        bookings_count = len([e for e in events if e["event_type"] == "booking"])
        community_count = len([e for e in events if e["event_type"] == "community"])

        return {
            "year": year,
            "month": month,
            "events": events,
            "bookings_count": bookings_count,
            "community_events_count": community_count,
        }

    def get_today(self, org_ids: List[UUID]) -> list:
        today = date.today()
        return self.get_events(org_ids, today, today)

    def get_upcoming(self, org_ids: List[UUID], days: int = 7, limit: int = 10) -> list:
        today = date.today()
        end = today + timedelta(days=days)
        events = self.get_events(org_ids, today, end)
        return events[:limit]
