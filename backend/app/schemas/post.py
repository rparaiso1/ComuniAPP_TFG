from pydantic import BaseModel, Field, field_validator
from typing import Optional
from datetime import datetime
from uuid import UUID


class PostBase(BaseModel):
    title: str = Field(max_length=200)
    content: str = Field(max_length=5000)
    is_pinned: Optional[bool] = False

    @field_validator('title')
    @classmethod
    def title_not_empty(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError('El título no puede estar vacío')
        if len(v) > 255:
            raise ValueError('El título no puede superar los 255 caracteres')
        return v.strip()

    @field_validator('content')
    @classmethod
    def content_not_empty(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError('El contenido no puede estar vacío')
        return v.strip()


class PostCreate(PostBase):
    pass


class PostUpdate(BaseModel):
    title: Optional[str] = Field(default=None, max_length=200)
    content: Optional[str] = Field(default=None, max_length=5000)
    is_pinned: Optional[bool] = None


class PostCommentCreate(BaseModel):
    content: str = Field(max_length=2000)

    @field_validator('content')
    @classmethod
    def content_not_empty(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError('El comentario no puede estar vacío')
        return v.strip()


class PostCommentResponse(BaseModel):
    id: UUID
    post_id: UUID
    author_id: UUID
    author_name: Optional[str] = None
    content: str
    created_at: datetime

    class Config:
        from_attributes = True


class PostResponse(BaseModel):
    id: UUID
    title: str
    content: str
    is_pinned: bool
    author_id: UUID
    author_name: Optional[str] = None
    organization_id: Optional[UUID] = None
    comment_count: int = 0
    comments: list[PostCommentResponse] = []
    like_count: int = 0
    user_has_liked: bool = False
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
