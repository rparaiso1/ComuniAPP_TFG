"""
Servicio de estadísticas — dashboard, booking stats, incident stats.
"""
from sqlalchemy.orm import Session
from sqlalchemy import func
from uuid import UUID
from typing import List

from app.models.booking import Booking, BookingStatus
from app.models.incident import Incident, IncidentStatus
from app.models.document import Document
from app.models.post import Post
from app.models.invitation import Invitation, InvitationStatus
from app.models.user import UserRole


class StatsService:

    def __init__(self, db: Session):
        self.db = db

    def dashboard(self, user_id: UUID, org_ids: List[UUID], user_role) -> dict:
        bookings_count = (
            self.db.query(func.count(Booking.id))
            .filter(Booking.user_id == user_id, Booking.organization_id.in_(org_ids))
            .scalar()
            or 0
        )

        incidents_count = 0
        documents_count = 0
        posts_count = 0
        pending_invitations = 0

        if org_ids:
            incidents_count = (
                self.db.query(func.count(Incident.id))
                .filter(
                    Incident.organization_id.in_(org_ids),
                    Incident.status.notin_([IncidentStatus.RESOLVED]),
                )
                .scalar()
                or 0
            )
            documents_count = (
                self.db.query(func.count(Document.id))
                .filter(Document.organization_id.in_(org_ids))
                .scalar()
                or 0
            )
            posts_count = (
                self.db.query(func.count(Post.id))
                .filter(Post.organization_id.in_(org_ids))
                .scalar()
                or 0
            )
            if user_role in (UserRole.ADMIN, UserRole.PRESIDENT):
                pending_invitations = (
                    self.db.query(func.count(Invitation.id))
                    .filter(
                        Invitation.organization_id.in_(org_ids),
                        Invitation.status == InvitationStatus.PENDING,
                    )
                    .scalar()
                    or 0
                )

        return {
            "bookings_count": bookings_count,
            "incidents_count": incidents_count,
            "documents_count": documents_count,
            "posts_count": posts_count,
            "pending_invitations": pending_invitations,
        }

    def bookings(self, user_id: UUID) -> dict:
        base = self.db.query(Booking).filter(Booking.user_id == user_id)
        return {
            "total": base.count(),
            "confirmed": base.filter(Booking.status == BookingStatus.CONFIRMED).count(),
            "pending": base.filter(Booking.status == BookingStatus.PENDING).count(),
            "cancelled": base.filter(Booking.status == BookingStatus.CANCELLED).count(),
        }

    def incidents(self, org_ids: List[UUID]) -> dict:
        if not org_ids:
            return {"total": 0, "open": 0, "in_progress": 0, "resolved": 0}

        total = (
            self.db.query(func.count(Incident.id))
            .filter(Incident.organization_id.in_(org_ids))
            .scalar()
            or 0
        )
        open_count = (
            self.db.query(func.count(Incident.id))
            .filter(
                Incident.organization_id.in_(org_ids),
                Incident.status == IncidentStatus.OPEN,
            )
            .scalar()
            or 0
        )
        in_progress = (
            self.db.query(func.count(Incident.id))
            .filter(
                Incident.organization_id.in_(org_ids),
                Incident.status == IncidentStatus.IN_PROGRESS,
            )
            .scalar()
            or 0
        )
        resolved = (
            self.db.query(func.count(Incident.id))
            .filter(
                Incident.organization_id.in_(org_ids),
                Incident.status.in_([IncidentStatus.RESOLVED]),
            )
            .scalar()
            or 0
        )
        return {
            "total": total,
            "open": open_count,
            "in_progress": in_progress,
            "resolved": resolved,
        }
