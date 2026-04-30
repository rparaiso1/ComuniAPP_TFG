from fastapi import APIRouter
from app.api import auth, posts, bookings, incidents, invitations, organizations, documents, stats, calendar, notifications, zones, admin, budget

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(organizations.router, prefix="/organizations", tags=["organizations"])
api_router.include_router(zones.router, prefix="/zones", tags=["zones"])
api_router.include_router(posts.router, prefix="/posts", tags=["posts"])
api_router.include_router(bookings.router, prefix="/bookings", tags=["bookings"])
api_router.include_router(incidents.router, prefix="/incidents", tags=["incidents"])
api_router.include_router(invitations.router, prefix="/invitations", tags=["invitations"])
api_router.include_router(documents.router, prefix="/documents", tags=["documents"])
api_router.include_router(stats.router, prefix="/stats", tags=["stats"])
api_router.include_router(calendar.router, prefix="/calendar", tags=["calendar"])
api_router.include_router(notifications.router, prefix="/notifications", tags=["notifications"])
api_router.include_router(admin.router, prefix="/admin", tags=["admin"])
api_router.include_router(budget.router, prefix="/budget", tags=["budget"])
