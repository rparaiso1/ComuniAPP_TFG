"""
Router de tablón de anuncios — delega la lógica a PostService.
"""
from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.orm import Session
from typing import List
from uuid import UUID

from app.core.database import get_db
from app.core.deps import get_current_user, get_active_org_id, get_filtered_org_ids, is_admin_or_president_in_org
from app.models.user import User
from app.models.notification import NotificationType
from app.schemas.post import PostCreate, PostUpdate, PostResponse, PostCommentCreate, PostCommentResponse
from app.services.post_service import PostService
from app.services.notification_service import NotificationService

router = APIRouter()


@router.post("", response_model=PostResponse, status_code=status.HTTP_201_CREATED)
def create_post(
    request: Request,
    post_data: PostCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Crear un nuevo anuncio."""
    org_id = get_active_org_id(request, db, current_user)
    is_leader = is_admin_or_president_in_org(db, current_user, [org_id])
    post = PostService(db).create(
        post_data, current_user.id, org_id, is_leader,
    )
    if is_leader:
        # Admin/president posts broadcast to everyone
        NotificationService(db).broadcast(
            organization_id=org_id, title="Nuevo anuncio",
            message=f"{current_user.full_name} publicó: {post.title}",
            notification_type=NotificationType.ANNOUNCEMENT,
            link=f"/posts/{post.id}",
        )
    else:
        # Neighbor posts only notify admin/president
        NotificationService(db).broadcast_to_leaders(
            organization_id=org_id, title="Nuevo anuncio de vecino",
            message=f"{current_user.full_name} publicó: {post.title}",
            notification_type=NotificationType.ANNOUNCEMENT,
            link=f"/posts/{post.id}",
            exclude_user_id=current_user.id,
        )
    return PostService.to_response(post, current_user.id)


@router.get("", response_model=List[PostResponse])
def get_posts(
    request: Request,
    skip: int = 0, limit: int = Query(default=50, le=500),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Obtener anuncios del tablón."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    posts = PostService(db).list(org_ids, skip=skip, limit=limit)
    return [PostService.to_response(p, current_user.id) for p in posts]


@router.get("/{post_id}", response_model=PostResponse)
def get_post(
    request: Request,
    post_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Obtener un anuncio específico."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    post = PostService(db).get(post_id, org_ids)
    return PostService.to_response(post, current_user.id)


@router.put("/{post_id}", response_model=PostResponse)
def update_post(
    request: Request,
    post_id: UUID,
    post_data: PostUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Actualizar un anuncio (autor o admin/presidente)."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    post = PostService(db).update(
        post_id, post_data, current_user.id,
        org_ids, is_admin_or_president_in_org(db, current_user, org_ids),
    )
    return PostService.to_response(post, current_user.id)


@router.delete("/{post_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_post(
    request: Request,
    post_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Eliminar un anuncio (autor o admin/presidente)."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    PostService(db).delete(post_id, current_user.id, org_ids, is_admin_or_president_in_org(db, current_user, org_ids))


@router.post("/{post_id}/comments", response_model=PostCommentResponse, status_code=status.HTTP_201_CREATED)
def add_comment(
    request: Request,
    post_id: UUID,
    comment_data: PostCommentCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Añadir un comentario a un post."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    comment = PostService(db).add_comment(post_id, comment_data, current_user.id, org_ids)
    return PostCommentResponse(
        id=comment.id, post_id=comment.post_id, author_id=comment.author_id,
        author_name=comment.author.full_name if comment.author else None,
        content=comment.content, created_at=comment.created_at,
    )


@router.delete("/comments/{comment_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_comment(
    request: Request,
    comment_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Eliminar un comentario."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    PostService(db).delete_comment(
        comment_id, current_user.id,
        is_admin_or_president_in_org(db, current_user, org_ids),
        org_ids=org_ids,
    )


@router.post("/{post_id}/like")
def toggle_like(
    request: Request,
    post_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Toggle like en un post. Devuelve {liked: true/false}."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    liked = PostService(db).toggle_like(post_id, current_user.id, org_ids)
    return {"liked": liked}
