"""add device_tokens table for FCM

Revision ID: g1h2i3j4k5l6
Revises: f8326e6516e8
Create Date: 2025-06-01 12:00:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = 'g1h2i3j4k5l6'
down_revision: Union[str, None] = 'f8326e6516e8'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'device_tokens',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('user_id', postgresql.UUID(as_uuid=True),
                   sa.ForeignKey('users.id', ondelete='CASCADE'),
                   nullable=False, index=True),
        sa.Column('token', sa.String(), nullable=False, index=True),
        sa.Column('platform', sa.String(), nullable=False, server_default='web'),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.UniqueConstraint('user_id', 'token', name='uq_user_device_token'),
    )


def downgrade() -> None:
    op.drop_table('device_tokens')
