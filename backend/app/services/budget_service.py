"""
Servicio de Presupuestos — CRUD, importación CSV, estadísticas.
"""
import csv
import io
from decimal import Decimal, InvalidOperation
from datetime import date
from typing import List, Optional
from uuid import UUID

from sqlalchemy import func, extract
from sqlalchemy.orm import Session

from app.models.budget_entry import BudgetEntry
from app.schemas.budget import (
    BudgetEntryResponse, BudgetSummary, BudgetCategoryStats,
    MonthlyStats, BudgetUploadResult,
)
from app.core.exceptions import ServiceError, NotFoundError

MONTH_LABELS = ["Ene", "Feb", "Mar", "Abr", "May", "Jun",
                "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"]

# Alias mantenido por retrocompatibilidad con imports existentes
BudgetError = ServiceError


class BudgetService:

    def __init__(self, db: Session):
        self.db = db

    # ── Helpers ────────────────────────────────────────────────────────────────

    @staticmethod
    def to_response(entry: BudgetEntry) -> BudgetEntryResponse:
        return BudgetEntryResponse(
            id=entry.id,
            organization_id=entry.organization_id,
            entry_date=entry.entry_date,
            category=entry.category,
            concept=entry.concept,
            amount=entry.amount,
            entry_type=entry.entry_type,
            provider=entry.provider,
            detail=entry.detail,
            uploaded_by_name=(
                entry.uploaded_by.full_name if entry.uploaded_by else None
            ),
            created_at=entry.created_at,
        )

    # ── CSV Upload ──────────────────────────────────────────────────────────────

    def upload_csv(
        self, content: bytes, org_id: UUID, uploader_id: UUID,
    ) -> BudgetUploadResult:
        """
        Parsear CSV y crear BudgetEntry. Columnas esperadas:
        fecha, categoría/categoria, concepto, importe, tipo, proveedor
        """
        try:
            text = content.decode("utf-8-sig")
        except UnicodeDecodeError:
            text = content.decode("latin-1")

        reader = csv.DictReader(io.StringIO(text), delimiter=";")
        rows = list(reader)
        if rows and len(rows[0]) <= 1:
            reader = csv.DictReader(io.StringIO(text), delimiter=",")
            rows = list(reader)

        if not rows:
            raise ServiceError("El archivo está vacío o no tiene un formato reconocible")

        imported = 0
        errors: List[str] = []

        for i, row in enumerate(rows, start=2):
            norm = {k.lower().strip().replace("á", "a").replace("é", "e")
                    .replace("í", "i").replace("ó", "o").replace("ú", "u")
                    .replace("ñ", "n"): str(v).strip()
                    for k, v in row.items() if k}

            # fecha
            raw_date = norm.get("fecha", "")
            if not raw_date:
                errors.append(f"Fila {i}: campo 'fecha' vacío, omitida")
                continue
            try:
                entry_date = date.fromisoformat(raw_date)
            except ValueError:
                # Try dd/mm/yyyy
                try:
                    parts = raw_date.replace("-", "/").split("/")
                    if len(parts) == 3:
                        d, m, y = int(parts[0]), int(parts[1]), int(parts[2])
                        if y < 100:
                            y += 2000
                        entry_date = date(y, m, d)
                    else:
                        raise ValueError
                except (ValueError, TypeError):
                    errors.append(f"Fila {i}: fecha '{raw_date}' inválida (usa YYYY-MM-DD o DD/MM/YYYY)")
                    continue

            # categoría
            category = norm.get("categoria", norm.get("category", "")).strip()
            if not category:
                errors.append(f"Fila {i}: campo 'categoría' vacío, omitida")
                continue

            # concepto
            concept = norm.get("concepto", norm.get("concept", "")).strip()
            if not concept:
                errors.append(f"Fila {i}: campo 'concepto' vacío, omitida")
                continue

            # importe
            raw_amount = norm.get("importe", norm.get("amount", "")).replace(",", ".").replace("€", "").strip()
            try:
                amount = Decimal(raw_amount)
                if amount <= 0:
                    raise InvalidOperation
            except (InvalidOperation, ValueError):
                errors.append(f"Fila {i}: importe '{raw_amount}' inválido")
                continue

            # tipo
            raw_type = norm.get("tipo", norm.get("type", norm.get("entry_type", ""))).lower().strip()
            type_map = {
                "ingreso": "income", "income": "income", "entrada": "income",
                "gasto": "expense", "expense": "expense", "salida": "expense",
            }
            entry_type = type_map.get(raw_type)
            if not entry_type:
                errors.append(f"Fila {i}: tipo '{raw_type}' inválido (usa ingreso/gasto)")
                continue

            # proveedor (opcional)
            provider = norm.get("proveedor", norm.get("provider", "")).strip() or None

            # detalle (opcional)
            detail = norm.get("detalle", norm.get("detail", "")).strip() or None

            entry = BudgetEntry(
                organization_id=org_id,
                entry_date=entry_date,
                category=category,
                concept=concept,
                amount=amount,
                entry_type=entry_type,
                provider=provider,
                detail=detail,
                uploaded_by_id=uploader_id,
            )
            self.db.add(entry)
            imported += 1

        if imported > 0:
            self.db.commit()

        return BudgetUploadResult(
            total_rows=len(rows), imported=imported, errors=errors,
        )

    # ── CRUD ───────────────────────────────────────────────────────────────────

    def list(
        self,
        org_ids: List[UUID],
        year: Optional[int] = None,
        entry_type: Optional[str] = None,
        category: Optional[str] = None,
        skip: int = 0,
        limit: int = 100,
    ) -> List[BudgetEntry]:
        query = self.db.query(BudgetEntry).filter(
            BudgetEntry.organization_id.in_(org_ids),
        )
        if year:
            query = query.filter(extract("year", BudgetEntry.entry_date) == year)
        if entry_type:
            query = query.filter(BudgetEntry.entry_type == entry_type)
        if category:
            query = query.filter(BudgetEntry.category.ilike(f"%{category}%"))
        return (
            query.order_by(BudgetEntry.entry_date.desc())
            .offset(skip).limit(limit).all()
        )

    def delete(self, entry_id: UUID, org_ids: List[UUID]) -> None:
        entry = self.db.query(BudgetEntry).filter(
            BudgetEntry.id == entry_id,
            BudgetEntry.organization_id.in_(org_ids),
        ).first()
        if not entry:
            raise NotFoundError("Partida no encontrada")
        self.db.delete(entry)
        self.db.commit()

    def delete_all(self, org_id: UUID) -> int:
        count = self.db.query(BudgetEntry).filter(
            BudgetEntry.organization_id == org_id,
        ).count()
        self.db.query(BudgetEntry).filter(
            BudgetEntry.organization_id == org_id,
        ).delete()
        self.db.commit()
        return count

    # ── Summary / Stats ─────────────────────────────────────────────────────────

    def get_summary(self, org_ids: List[UUID], year: Optional[int] = None) -> BudgetSummary:
        from datetime import datetime

        # If no year specified, use the latest year with data, falling back to current year
        if year is None:
            latest_year_row = (
                self.db.query(extract("year", BudgetEntry.entry_date).label("y"))
                .filter(BudgetEntry.organization_id.in_(org_ids))
                .order_by(extract("year", BudgetEntry.entry_date).desc())
                .first()
            )
            year = int(latest_year_row.y) if latest_year_row else datetime.now().year

        base_q = self.db.query(BudgetEntry).filter(
            BudgetEntry.organization_id.in_(org_ids),
            extract("year", BudgetEntry.entry_date) == year,
        )

        # Totales
        income_q = base_q.filter(BudgetEntry.entry_type == "income")
        expense_q = base_q.filter(BudgetEntry.entry_type == "expense")

        total_income = income_q.with_entities(func.sum(BudgetEntry.amount)).scalar() or Decimal("0")
        total_expense = expense_q.with_entities(func.sum(BudgetEntry.amount)).scalar() or Decimal("0")
        entries_count = base_q.count()
        balance = total_income - total_expense

        # Por categoría — gastos
        by_cat_expense = self._category_stats(expense_q, total_expense)
        by_cat_income = self._category_stats(income_q, total_income)

        # Desglose mensual
        monthly = self._monthly_breakdown(org_ids, year)

        # Años disponibles
        available_years_rows = (
            self.db.query(extract("year", BudgetEntry.entry_date).label("y"))
            .filter(BudgetEntry.organization_id.in_(org_ids))
            .distinct()
            .order_by("y")
            .all()
        )
        available_years = [int(r.y) for r in available_years_rows]
        # Always include the requested year and the current year
        current_year = datetime.now().year
        for y_val in (year, current_year):
            if y_val not in available_years:
                available_years.append(y_val)
        available_years.sort()

        return BudgetSummary(
            year=year,
            total_income=total_income,
            total_expense=total_expense,
            balance=balance,
            entries_count=entries_count,
            by_category_expense=by_cat_expense,
            by_category_income=by_cat_income,
            monthly_breakdown=monthly,
            available_years=available_years,
        )

    def _category_stats(self, base_query, total: Decimal) -> List[BudgetCategoryStats]:
        rows = (
            base_query
            .with_entities(
                BudgetEntry.category,
                func.sum(BudgetEntry.amount).label("total"),
                func.count(BudgetEntry.id).label("count"),
            )
            .group_by(BudgetEntry.category)
            .order_by(func.sum(BudgetEntry.amount).desc())
            .all()
        )
        result = []
        for r in rows:
            cat_total = r.total or Decimal("0")
            pct = float(cat_total / total * 100) if total else 0.0
            result.append(BudgetCategoryStats(
                category=r.category,
                total=cat_total,
                count=r.count,
                percentage=round(pct, 1),
            ))
        return result

    def _monthly_breakdown(self, org_ids: List[UUID], year: int) -> List[MonthlyStats]:
        rows = (
            self.db.query(
                extract("month", BudgetEntry.entry_date).label("month"),
                BudgetEntry.entry_type,
                func.sum(BudgetEntry.amount).label("total"),
            )
            .filter(
                BudgetEntry.organization_id.in_(org_ids),
                extract("year", BudgetEntry.entry_date) == year,
            )
            .group_by("month", BudgetEntry.entry_type)
            .order_by("month")
            .all()
        )

        # Build monthly dict
        monthly: dict[int, dict] = {
            m: {"income": Decimal("0"), "expense": Decimal("0")}
            for m in range(1, 13)
        }
        for r in rows:
            m = int(r.month)
            monthly[m][r.entry_type] = r.total or Decimal("0")

        result = []
        for m in range(1, 13):
            inc = monthly[m]["income"]
            exp = monthly[m]["expense"]
            result.append(MonthlyStats(
                month=m,
                month_label=MONTH_LABELS[m - 1],
                income=inc,
                expense=exp,
                balance=inc - exp,
            ))
        return result
