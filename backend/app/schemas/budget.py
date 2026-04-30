"""
Schemas Pydantic v2 para el módulo de Presupuestos.
"""
from pydantic import BaseModel, ConfigDict, Field, field_validator
from typing import List, Optional
from datetime import date, datetime
from uuid import UUID
from decimal import Decimal


# ── Request ─────────────────────────────────────────────────────────────────────

class BudgetEntryCreate(BaseModel):
    entry_date: date
    category: str = Field(min_length=1, max_length=100)
    concept: str = Field(min_length=1, max_length=300)
    amount: Decimal = Field(gt=0, decimal_places=2)
    entry_type: str = Field(pattern=r"^(income|expense)$")
    provider: Optional[str] = Field(default=None, max_length=200)
    detail: Optional[str] = Field(default=None, max_length=500)

    @field_validator("entry_type")
    @classmethod
    def normalize_type(cls, v: str) -> str:
        return v.lower()


# ── Response ─────────────────────────────────────────────────────────────────────

class BudgetEntryResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    organization_id: UUID
    entry_date: date
    category: str
    concept: str
    amount: Decimal
    entry_type: str
    provider: Optional[str]
    detail: Optional[str] = None
    uploaded_by_name: Optional[str] = None
    created_at: datetime


# ── Summary / Stats ───────────────────────────────────────────────────────────────

class BudgetCategoryStats(BaseModel):
    category: str
    total: Decimal
    count: int
    percentage: float


class MonthlyStats(BaseModel):
    month: int          # 1-12
    month_label: str    # "Ene", "Feb", ...
    income: Decimal
    expense: Decimal
    balance: Decimal


class BudgetSummary(BaseModel):
    year: int
    total_income: Decimal
    total_expense: Decimal
    balance: Decimal
    entries_count: int
    by_category_expense: List[BudgetCategoryStats]
    by_category_income: List[BudgetCategoryStats]
    monthly_breakdown: List[MonthlyStats]
    available_years: List[int]


# ── Upload result ──────────────────────────────────────────────────────────────────

class BudgetUploadResult(BaseModel):
    total_rows: int
    imported: int
    errors: List[str]
