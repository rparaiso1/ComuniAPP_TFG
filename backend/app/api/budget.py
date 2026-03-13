"""
Router de Presupuestos — gestión de ingresos y gastos de la comunidad.

Endpoints:
  GET  /budget          — listar partidas (todos los usuarios)
  GET  /budget/summary  — resumen/estadísticas (todos los usuarios)
  POST /budget/upload   — importar CSV (admin/presidente)
  DELETE /budget/{id}   — eliminar partida (admin/presidente)
  DELETE /budget        — eliminar todas las partidas del org (admin/presidente)
"""
from fastapi import APIRouter, Depends, HTTPException, Query, Request, UploadFile, File, status
from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID

from app.core.database import get_db
from app.core.deps import (
    get_current_user, get_filtered_org_ids, get_active_org_id,
    is_admin_or_president_in_org, get_current_admin_or_president,
)
from app.models.user import User
from app.schemas.budget import BudgetEntryResponse, BudgetSummary, BudgetUploadResult
from app.services.budget_service import BudgetService

router = APIRouter()


@router.get("/summary", response_model=BudgetSummary)
def get_budget_summary(
    request: Request,
    year: Optional[int] = Query(default=None, description="Año fiscal (por defecto, el actual)"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Obtener resumen estadístico del presupuesto (accesible para todos los vecinos)."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    return BudgetService(db).get_summary(org_ids, year)


@router.get("", response_model=List[BudgetEntryResponse])
def list_budget_entries(
    request: Request,
    year: Optional[int] = None,
    entry_type: Optional[str] = Query(default=None, pattern=r"^(income|expense)$"),
    category: Optional[str] = None,
    skip: int = 0,
    limit: int = Query(default=50, le=500),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Listar partidas presupuestarias (accesible para todos los vecinos)."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    entries = BudgetService(db).list(
        org_ids, year=year, entry_type=entry_type, category=category,
        skip=skip, limit=limit,
    )
    return [BudgetService.to_response(e) for e in entries]


@router.post("/upload", response_model=BudgetUploadResult, status_code=status.HTTP_201_CREATED)
async def upload_budget_csv(
    request: Request,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_admin_or_president),
    db: Session = Depends(get_db),
):
    """
    Importar partidas presupuestarias desde CSV (solo admin/presidente).

    Columnas del CSV:
      fecha      — fecha de la partida (YYYY-MM-DD o DD/MM/YYYY)
      categoría  — categoría (p.ej. "Mantenimiento", "Electricidad")
      concepto   — descripción de la partida
      importe    — importe en euros (ej: 1500.00)
      tipo       — "ingreso" o "gasto"
      proveedor  — nombre del proveedor/pagador (opcional)
    """
    if not file.filename or not (
        file.filename.endswith(".csv")
        or file.filename.endswith(".txt")
    ):
        raise HTTPException(
            status_code=400,
            detail="Solo se aceptan archivos CSV (.csv o .txt)",
        )
    org_id = get_active_org_id(request, db, current_user)
    content = await file.read()
    result = BudgetService(db).upload_csv(content, org_id, current_user.id)
    return result


@router.delete("/{entry_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_budget_entry(
    request: Request,
    entry_id: UUID,
    current_user: User = Depends(get_current_admin_or_president),
    db: Session = Depends(get_db),
):
    """Eliminar una partida presupuestaria (solo admin/presidente)."""
    org_ids = get_filtered_org_ids(request, db, current_user)
    BudgetService(db).delete(entry_id, org_ids)


@router.delete("", status_code=status.HTTP_200_OK)
def delete_all_budget_entries(
    request: Request,
    current_user: User = Depends(get_current_admin_or_president),
    db: Session = Depends(get_db),
):
    """Eliminar todas las partidas del año/organización (solo admin/presidente)."""
    org_id = get_active_org_id(request, db, current_user)
    count = BudgetService(db).delete_all(org_id)
    return {"deleted": count, "message": f"Se eliminaron {count} partidas"}
