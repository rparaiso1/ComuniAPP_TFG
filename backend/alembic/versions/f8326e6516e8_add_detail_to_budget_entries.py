"""add_detail_to_budget_entries

Revision ID: f8326e6516e8
Revises: a1b2c3d4e5f6
Create Date: 2026-03-01 13:49:25.777231

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = 'f8326e6516e8'
down_revision: Union[str, None] = 'a1b2c3d4e5f6'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('budget_entries', sa.Column('detail', sa.String(length=500), nullable=True))


def downgrade() -> None:
    op.drop_column('budget_entries', 'detail')
