"""
Servicio de posts (tablón de anuncios).
"""
from sqlalchemy.orm import Session, joinedload, subqueryload
from sqlalchemy import func
from uuid import UUID
from typing import List, Optional

from app.models.post import Post
from app.models.post_comment import PostComment
from app.models.post_like import PostLike
from app.schemas.post import PostCreate, PostUpdate, PostResponse, PostCommentCreate, PostCommentResponse
from app.core.exceptions import ServiceError, NotFoundError, ForbiddenError

# Alias mantenido por retrocompatibilidad con imports existentes
PostError = ServiceError


class PostService:

    def __init__(self, db: Session):
        self.db = db

    @staticmethod
    def to_response(p: Post, current_user_id: Optional[UUID] = None) -> PostResponse:
        comments = [
            PostCommentResponse(
                id=c.id, post_id=c.post_id, author_id=c.author_id,
                author_name=c.author.full_name if c.author else None,
                content=c.content, created_at=c.created_at,
            )
            for c in (p.comments or [])
        ]
        likes_list = p.likes or []
        like_count = len(likes_list)
        user_has_liked = any(lk.user_id == current_user_id for lk in likes_list) if current_user_id else False
        return PostResponse(
            id=p.id, title=p.title, content=p.content, is_pinned=p.is_pinned,
            author_id=p.author_id,
            author_name=p.author.full_name if p.author else None,
            organization_id=p.organization_id,
            comment_count=len(comments),
            comments=comments,
            like_count=like_count,
            user_has_liked=user_has_liked,
            created_at=p.created_at, updated_at=p.updated_at,
        )

    def create(self, data: PostCreate, user_id: UUID, org_id: UUID, is_admin: bool) -> Post:
        post = Post(
            title=data.title, content=data.content,
            is_pinned=data.is_pinned if is_admin else False,
            author_id=user_id, organization_id=org_id,
        )
        self.db.add(post)
        self.db.commit()
        self.db.refresh(post)
        return post

    def list(self, org_ids: List[UUID], skip: int = 0, limit: int = 50) -> List[Post]:
        return (
            self.db.query(Post)
            .options(
                joinedload(Post.author),
                subqueryload(Post.comments).joinedload(PostComment.author),
                subqueryload(Post.likes),
            )
            .filter(Post.organization_id.in_(org_ids))
            .order_by(Post.is_pinned.desc(), Post.created_at.desc())
            .offset(skip).limit(limit).all()
        )

    def get(self, post_id: UUID, org_ids: List[UUID]) -> Post:
        post = (
            self.db.query(Post)
            .options(
                joinedload(Post.author),
                subqueryload(Post.comments).joinedload(PostComment.author),
                subqueryload(Post.likes),
            )
            .filter(Post.id == post_id, Post.organization_id.in_(org_ids))
            .first()
        )
        if not post:
            raise NotFoundError("Post no encontrado")
        return post

    def update(self, post_id: UUID, data: PostUpdate, user_id: UUID, org_ids: List[UUID], is_admin: bool) -> Post:
        post = self.get(post_id, org_ids)
        if post.author_id != user_id and not is_admin:
            raise ForbiddenError("No tienes permisos")
        if data.title is not None:
            post.title = data.title
        if data.content is not None:
            post.content = data.content
        if data.is_pinned is not None and is_admin:
            post.is_pinned = data.is_pinned
        self.db.commit()
        self.db.refresh(post)
        return post

    def delete(self, post_id: UUID, user_id: UUID, org_ids: List[UUID], is_admin: bool) -> None:
        post = self.get(post_id, org_ids)
        if post.author_id != user_id and not is_admin:
            raise ForbiddenError("No tienes permisos")
        self.db.delete(post)
        self.db.commit()

    # ---- Comentarios ----

    def add_comment(self, post_id: UUID, data: PostCommentCreate, user_id: UUID, org_ids: List[UUID]) -> PostComment:
        post = self.get(post_id, org_ids)
        comment = PostComment(
            post_id=post.id, author_id=user_id,
            content=data.content,
        )
        self.db.add(comment)
        self.db.commit()
        self.db.refresh(comment)
        return comment

    def delete_comment(self, comment_id: UUID, user_id: UUID, is_admin: bool, org_ids: List[UUID] = None) -> None:
        comment = self.db.query(PostComment).filter(PostComment.id == comment_id).first()
        if not comment:
            raise NotFoundError("Comentario no encontrado")
        # Verify the comment belongs to an org the user has access to
        if org_ids:
            post = self.db.query(Post).filter(
                Post.id == comment.post_id,
                Post.organization_id.in_(org_ids),
            ).first()
            if not post:
                raise NotFoundError("Comentario no encontrado")
        if comment.author_id != user_id and not is_admin:
            raise ForbiddenError("No tienes permisos")
        self.db.delete(comment)
        self.db.commit()

    # ---- Likes ----

    def toggle_like(self, post_id: UUID, user_id: UUID, org_ids: List[UUID]) -> bool:
        """Toggle like on a post. Returns True if liked, False if unliked."""
        # Ensure post exists and user has access
        self.get(post_id, org_ids)
        existing = (
            self.db.query(PostLike)
            .filter(PostLike.post_id == post_id, PostLike.user_id == user_id)
            .first()
        )
        if existing:
            self.db.delete(existing)
            self.db.commit()
            return False
        else:
            self.db.add(PostLike(post_id=post_id, user_id=user_id))
            self.db.commit()
            return True
