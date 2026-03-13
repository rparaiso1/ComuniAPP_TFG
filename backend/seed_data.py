#!/usr/bin/env python3
"""
Seed completo de datos realistas para TFG Urbanizaciones.

Estructura:
  - 2 Admins (admin1 gestiona Org1+Org2, admin2 gestiona Org3+Org4)
  - 4 Urbanizaciones (organizaciones)
  - 1 Presidente por urbanización
  - 3 Vecinos propietarios por urbanización
  - 2 Inquilinos por urbanización (vecinos con contract_end)
  - Zonas comunes por urbanización
  - Datos de ejemplo: posts, incidencias, reservas, documentos, notificaciones
"""   
import sys, os
sys.path.insert(0, os.path.dirname(__file__))

from datetime import datetime, timedelta, timezone, time
from uuid import uuid4
from sqlalchemy.orm import Session

from app.core.database import engine, SessionLocal, Base
from app.core.security import get_password_hash
from app.models.user import User, UserRole
from app.models.organization import Organization
from app.models.user_organization import UserOrganization
from app.models.zone import Zone
from app.models.post import Post
from app.models.incident import Incident, IncidentPriority, IncidentStatus
from app.models.incident_comment import IncidentComment
from app.models.booking import Booking, BookingStatus
from app.models.document import Document
from app.models.notification import Notification
from app.models.invitation import Invitation
from app.models.budget_entry import BudgetEntry
from app.models.post_comment import PostComment
from app.models.post_like import PostLike

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
NOW = datetime.now(timezone.utc)
PASS_HASH = get_password_hash("Test1234")  # Contraseña común: Test1234


def make_user(email, full_name, role=UserRole.NEIGHBOR, phone=None, dwelling=None, contract_end=None):
    return User(
        id=uuid4(), email=email, full_name=full_name,
        hashed_password=PASS_HASH, role=role,
        phone=phone, dwelling=dwelling, contract_end=contract_end,
        is_active=True,
    )


def make_org(name, code, address, phone, email, color="#6366F1"):
    return Organization(
        id=uuid4(), name=name, code=code, address=address,
        phone=phone, email=email, primary_color=color, is_active=True,
    )


def link(user, org, role, dwelling=None):
    return UserOrganization(
        user_id=user.id, organization_id=org.id,
        role=role, dwelling=dwelling or user.dwelling, is_active=True,
    )


# ---------------------------------------------------------------------------
# Seed principal
# ---------------------------------------------------------------------------
def seed(db: Session):
    # ===== 1. ORGANIZACIONES =====
    org1 = make_org(
        "Residencial Los Jardines", "JARDINES",
        "Avda. de la Constitución 24, Sevilla", "954112233",
        "admin@losjardines.es", "#4CAF50",
    )
    org2 = make_org(
        "Urbanización Las Palmeras", "PALMERAS",
        "C/ Palmera 5, Sevilla", "954223344",
        "admin@laspalmeras.es", "#2196F3",
    )
    org3 = make_org(
        "Conjunto Residencial El Mirador", "MIRADOR",
        "C/ Mirador 12, Málaga", "952334455",
        "admin@elmirador.es", "#FF9800",
    )
    org4 = make_org(
        "Residencial Puerta del Sol", "PUERTASOL",
        "Plaza del Sol 1, Granada", "958445566",
        "admin@puertadelsol.es", "#9C27B0",
    )
    orgs = [org1, org2, org3, org4]
    db.add_all(orgs)
    db.flush()

    # ===== 2. ADMINS (globales) =====
    admin1 = make_user("admin1@tfg.com", "Carlos García López", UserRole.ADMIN, "600111001")
    admin2 = make_user("admin2@tfg.com", "María Fernández Ruiz", UserRole.ADMIN, "600111002")
    db.add_all([admin1, admin2])
    db.flush()

    # Admin1 → Org1, Org2  /  Admin2 → Org3, Org4
    db.add_all([
        link(admin1, org1, UserRole.ADMIN),
        link(admin1, org2, UserRole.ADMIN),
        link(admin2, org3, UserRole.ADMIN),
        link(admin2, org4, UserRole.ADMIN),
    ])

    # ===== 3. PRESIDENTES (1 por org) =====
    pres1 = make_user("presidente1@tfg.com", "Antonio Moreno Díaz", UserRole.PRESIDENT, "600222001", "Bloque A - Ático")
    pres2 = make_user("presidente2@tfg.com", "Laura Sánchez Gil", UserRole.PRESIDENT, "600222002", "Casa 1")
    pres3 = make_user("presidente3@tfg.com", "Francisco Martín López", UserRole.PRESIDENT, "600222003", "Torre 1 - 8ºA")
    pres4 = make_user("presidente4@tfg.com", "Carmen Ruiz Torres", UserRole.PRESIDENT, "600222004", "Bloque B - 1ºC")
    presidents = [pres1, pres2, pres3, pres4]
    db.add_all(presidents)
    db.flush()

    db.add_all([
        link(pres1, org1, UserRole.PRESIDENT, "Bloque A - Ático"),
        link(pres2, org2, UserRole.PRESIDENT, "Casa 1"),
        link(pres3, org3, UserRole.PRESIDENT, "Torre 1 - 8ºA"),
        link(pres4, org4, UserRole.PRESIDENT, "Bloque B - 1ºC"),
    ])

    # ===== 4. VECINOS PROPIETARIOS (3 por org) =====
    owners_data = [
        # Org1 – Los Jardines
        ("vecino1@tfg.com",  "José López Navarro",     "600330101", "Bloque A - 1ºA"),
        ("vecino2@tfg.com",  "Ana Pérez Romero",       "600330102", "Bloque A - 2ºB"),
        ("vecino3@tfg.com",  "Miguel Jiménez Vega",    "600330103", "Bloque B - 3ºC"),
        # Org2 – Las Palmeras
        ("vecino4@tfg.com",  "Raquel Díaz Santos",     "600330201", "Casa 3"),
        ("vecino5@tfg.com",  "David Muñoz Herrero",    "600330202", "Casa 5"),
        ("vecino6@tfg.com",  "Pilar Gómez Serrano",    "600330203", "Casa 7"),
        # Org3 – El Mirador
        ("vecino7@tfg.com",  "Fernando Alonso Rivas",  "600330301", "Torre 1 - 2ºB"),
        ("vecino8@tfg.com",  "Beatriz Hernández Cruz", "600330302", "Torre 2 - 4ºA"),
        ("vecino9@tfg.com",  "Javier Martínez Soto",   "600330303", "Torre 2 - 6ºC"),
        # Org4 – Puerta del Sol
        ("vecino10@tfg.com", "Elena Domínguez Lara",   "600330401", "Bloque A - 2ºA"),
        ("vecino11@tfg.com", "Roberto Iglesias Pardo",  "600330402", "Bloque A - 4ºB"),
        ("vecino12@tfg.com", "Sofía Vargas Nieto",      "600330403", "Bloque B - 3ºA"),
    ]
    owners = []
    for email, name, phone, dwelling in owners_data:
        u = make_user(email, name, UserRole.NEIGHBOR, phone, dwelling)
        owners.append(u)
    db.add_all(owners)
    db.flush()

    for i, u in enumerate(owners):
        org_idx = i // 3  # 0,1,2→org1 ; 3,4,5→org2 ; ...
        db.add(link(u, orgs[org_idx], UserRole.NEIGHBOR, u.dwelling))

    # ===== 5. INQUILINOS (2 por org, con contract_end) =====
    tenants_data = [
        # Org1
        ("inquilino1@tfg.com", "Pablo Ríos Cano",     "600440101", "Bloque B - 1ºA"),
        ("inquilino2@tfg.com", "Lucía Ortega Blanco",  "600440102", "Bloque B - 2ºB"),
        # Org2
        ("inquilino3@tfg.com", "Marcos Sáez Prieto",   "600440201", "Casa 9"),
        ("inquilino4@tfg.com", "Nuria Calvo Fuentes",  "600440202", "Casa 11"),
        # Org3
        ("inquilino5@tfg.com", "Adrián Peña Molina",   "600440301", "Torre 1 - 5ºA"),
        ("inquilino6@tfg.com", "Cristina León Ibáñez", "600440302", "Torre 2 - 1ºB"),
        # Org4
        ("inquilino7@tfg.com", "Sergio Campos Reyes",  "600440401", "Bloque A - 5ºC"),
        ("inquilino8@tfg.com", "Marta Navarro Rubio",  "600440402", "Bloque B - 2ºA"),
    ]
    tenants = []
    for email, name, phone, dwelling in tenants_data:
        contract_end = NOW + timedelta(days=180 + hash(email) % 365)
        u = make_user(email, name, UserRole.NEIGHBOR, phone, dwelling, contract_end=contract_end)
        tenants.append(u)
    db.add_all(tenants)
    db.flush()

    for i, u in enumerate(tenants):
        org_idx = i // 2
        db.add(link(u, orgs[org_idx], UserRole.NEIGHBOR, u.dwelling))

    db.flush()

    # ===== 6. ZONAS COMUNES =====
    zones_by_org = {}
    zone_templates = [
        ("Piscina",         "pool",  "Piscina comunitaria con horario de verano", 30, 3, 1, 15, False, time(10, 0), time(21, 0)),
        ("Pista de Pádel",  "court", "Pista de pádel con iluminación nocturna",    4, 2, 2, 30, False, time(8, 0), time(22, 0)),
        ("Gimnasio",        "gym",   "Gimnasio equipado con máquinas de cardio",   15, 2, 1, 7,  False, time(7, 0), time(23, 0)),
        ("Salón de Actos",  "room",  "Salón para reuniones y eventos",             50, 4, 1, 60, True,  time(9, 0), time(22, 0)),
        ("Zona Barbacoa",   "bbq",   "Área de barbacoa con mesas y sillas",        12, 3, 1, 14, True,  time(11, 0), time(22, 0)),
    ]
    for org in orgs:
        zones_by_org[org.id] = []
        for name, ztype, desc, cap, hours, max_per_day, advance, approval, avail_from, avail_until in zone_templates:
            z = Zone(
                id=uuid4(), name=name, zone_type=ztype, description=desc,
                organization_id=org.id, max_capacity=cap, max_booking_hours=hours,
                max_bookings_per_user_day=max_per_day, advance_booking_days=advance,
                requires_approval=approval, available_from=avail_from,
                available_until=avail_until, is_active=True,
            )
            zones_by_org[org.id].append(z)
            db.add(z)
    db.flush()

    # ===== 7. POSTS (tablón de anuncios) =====
    posts_data = [
        # Org1 — presidente y admin publican
        (pres1, org1, "Reunión de comunidad – Enero", "Se convoca reunión ordinaria el próximo 25 de enero a las 19:00 en el salón de actos. Orden del día: presupuestos 2025, obras pendientes y ruegos y preguntas.", True),
        (pres1, org1, "Horario de piscina verano", "La piscina abrirá del 15 de junio al 15 de septiembre. Horario: 10:00 a 21:00. Recuerden las normas de uso.", False),
        (admin1, org1, "Mantenimiento ascensores", "El día 5 de febrero se realizará la revisión anual de los ascensores del Bloque A y B. Disculpen las molestias.", False),
        # Org2
        (pres2, org2, "Normas de convivencia actualizadas", "Se han actualizado las normas de convivencia de la urbanización. Pueden consultarlas en la sección de documentos.", True),
        (admin1, org2, "Fumigación jardines", "El viernes 10 de febrero se procederá a la fumigación de los jardines comunes. Se recomienda no acceder a las zonas tratadas durante 24h.", False),
        # Org3
        (pres3, org3, "Obras en garaje subterráneo", "Comenzarán obras de impermeabilización del garaje el 1 de marzo. Duración estimada: 3 semanas.", True),
        (admin2, org3, "Nuevo sistema de videovigilancia", "Se ha instalado el nuevo sistema de cámaras en las zonas comunes. Cumple con la normativa RGPD.", False),
        # Org4
        (pres4, org4, "Fiesta de la urbanización", "El sábado 15 de abril celebramos la fiesta anual en la zona de barbacoa. ¡Todos invitados!", True),
        (admin2, org4, "Cambio empresa de limpieza", "A partir de mayo la limpieza de zonas comunes la realizará la empresa LimpiaHogar S.L.", False),
    ]
    posts = []
    for author, org, title, content, pinned in posts_data:
        p = Post(
            id=uuid4(), title=title, content=content,
            author_id=author.id, organization_id=org.id, is_pinned=pinned,
        )
        db.add(p)
        posts.append(p)
    db.flush()

    # ===== 7b. COMENTARIOS EN POSTS =====
    post_comments_data = [
        # Comentarios en post 0 (Reunión de comunidad — org1)
        (owners[0], posts[0], "¿Se puede asistir de forma telemática?"),
        (owners[1], posts[0], "Perfecto, allí estaremos. ¡Gracias por avisar!"),
        (tenants[0], posts[0], "¿Hay punto sobre el tema de las plazas de garaje?"),
        # Comentarios en post 1 (Horario piscina — org1)
        (owners[2], posts[1], "¿Los menores pueden ir sin acompañante?"),
        (tenants[1], posts[1], "Genial, estaba deseando que abriera."),
        # Comentarios en post 3 (Normas convivencia — org2)
        (owners[3], posts[3], "¿Dónde se pueden consultar exactamente?"),
        (owners[4], posts[3], "Gracias por la actualización."),
        # Comentarios en post 5 (Obras garaje — org3)
        (owners[6], posts[5], "¿Se puede seguir aparcando mientras duren las obras?"),
        (tenants[4], posts[5], "Tres semanas es mucho tiempo... ¿hay alternativa de parking?"),
        # Comentarios en post 7 (Fiesta urbanización — org4)
        (owners[9], posts[7], "¡Qué buena idea! ¿Hace falta llevar algo?"),
        (owners[10], posts[7], "Apuntados toda la familia 🎉"),
        (tenants[6], posts[7], "¿A qué hora empieza la fiesta?"),
    ]
    for author, post, content in post_comments_data:
        db.add(PostComment(
            id=uuid4(), post_id=post.id, author_id=author.id, content=content,
        ))

    # ===== 7c. LIKES EN POSTS =====
    post_likes_data = [
        # Likes en post 0 (Reunión — org1)
        (owners[0], posts[0]), (owners[1], posts[0]), (owners[2], posts[0]),
        (tenants[0], posts[0]), (pres1, posts[0]),
        # Likes en post 1 (Piscina — org1)
        (owners[0], posts[1]), (owners[2], posts[1]), (tenants[1], posts[1]),
        # Likes en post 3 (Normas — org2)
        (owners[3], posts[3]), (owners[4], posts[3]),
        # Likes en post 5 (Obras garaje — org3)
        (owners[6], posts[5]),
        # Likes en post 7 (Fiesta — org4)
        (owners[9], posts[7]), (owners[10], posts[7]), (owners[11], posts[7]),
        (tenants[6], posts[7]), (tenants[7], posts[7]), (pres4, posts[7]),
    ]
    for user, post in post_likes_data:
        db.add(PostLike(id=uuid4(), post_id=post.id, user_id=user.id))
    db.flush()
    db.flush()

    # ===== 8. INCIDENCIAS =====
    incidents = []
    incidents_data = [
        # Org1
        (owners[0], org1, "Fuga de agua en garaje", "Se ha detectado una fuga de agua en la plaza 15 del garaje. El charco crece cada día.", IncidentPriority.HIGH, IncidentStatus.OPEN, "Garaje - Plaza 15"),
        (owners[1], org1, "Farola fundida en jardín", "La farola del jardín trasero del bloque A lleva una semana sin funcionar.", IncidentPriority.LOW, IncidentStatus.IN_PROGRESS, "Jardín Bloque A"),
        (tenants[0], org1, "Puerta portal no cierra", "La puerta del portal del Bloque B no cierra correctamente. Problema de seguridad.", IncidentPriority.MEDIUM, IncidentStatus.OPEN, "Portal Bloque B"),
        # Org2
        (owners[3], org2, "Rotura en valla perimetral", "Hay una rotura en la valla de la zona norte, a la altura de la Casa 8.", IncidentPriority.MEDIUM, IncidentStatus.OPEN, "Valla norte"),
        (tenants[2], org2, "Piscina con agua turbia", "El agua de la piscina presenta un color verdoso desde hace dos días.", IncidentPriority.HIGH, IncidentStatus.IN_PROGRESS, "Piscina"),
        # Org3
        (owners[6], org3, "Ascensor averiado Torre 2", "El ascensor de la Torre 2 se ha quedado parado en la planta 3.", IncidentPriority.CRITICAL, IncidentStatus.OPEN, "Torre 2 - Ascensor"),
        (owners[7], org3, "Grafitis en fachada", "Han aparecido grafitis en la fachada trasera de la Torre 1.", IncidentPriority.LOW, IncidentStatus.RESOLVED, "Torre 1 - Fachada"),
        # Org4
        (owners[9],  org4, "Filtración en techo garaje", "Se observan manchas de humedad en el techo del garaje, zona bloque A.", IncidentPriority.HIGH, IncidentStatus.OPEN, "Garaje Bloque A"),
        (tenants[6], org4, "Ruido excesivo Bloque A 3ºB", "El vecino del 3ºB tiene ruidos excesivos por la noche de forma recurrente.", IncidentPriority.MEDIUM, IncidentStatus.OPEN, "Bloque A - 3ºB"),
    ]
    for reporter, org, title, desc, priority, status_val, location in incidents_data:
        inc = Incident(
            id=uuid4(), title=title, description=desc,
            priority=priority, status=status_val,
            reporter_id=reporter.id, organization_id=org.id,
            location=location,
        )
        incidents.append(inc)
        db.add(inc)
    db.flush()

    # Comentarios en incidencias
    comments_data = [
        (incidents[0], pres1,    "He contactado con el fontanero. Vendrá mañana a primera hora."),
        (incidents[0], owners[0], "Gracias, el charco ya llega a la plaza 14 también."),
        (incidents[1], admin1,   "Se ha solicitado la sustitución de la bombilla al servicio de mantenimiento."),
        (incidents[4], pres2,    "Se ha llamado a la empresa de mantenimiento de piscinas. Vendrán esta tarde."),
        (incidents[5], admin2,   "Se ha avisado al servicio técnico de ascensores. Prioridad urgente."),
        (incidents[5], owners[6], "Hay personas mayores que necesitan el ascensor con urgencia."),
        (incidents[6], pres3,    "La empresa de limpieza ha procedido a eliminar los grafitis."),
    ]
    for inc, author, content in comments_data:
        db.add(IncidentComment(
            id=uuid4(), incident_id=inc.id, author_id=author.id, content=content,
        ))

    # ===== 9. RESERVAS =====
    base_date = NOW + timedelta(days=1)
    base_date = base_date.replace(hour=0, minute=0, second=0, microsecond=0)
    bookings_data = [
        # Org1 — piscina (idx 0), pádel (idx 1), gimnasio (idx 2)
        (owners[0], org1, 0, 10, 13),  # Piscina 10-13
        (owners[1], org1, 1, 16, 18),  # Pádel 16-18
        (owners[2], org1, 2, 8,  10),  # Gimnasio 8-10
        (tenants[0], org1, 1, 10, 12), # Pádel 10-12
        # Org2
        (owners[3], org2, 0, 11, 14),  # Piscina 11-14
        (owners[4], org2, 4, 12, 15),  # Barbacoa 12-15 (requires approval → pending)
        (tenants[2], org2, 2, 17, 19), # Gimnasio 17-19
        # Org3
        (owners[6], org3, 1, 9, 11),   # Pádel 9-11
        (owners[7], org3, 3, 18, 22),  # Salón Actos 18-22 (requires approval → pending)
        (tenants[4], org3, 0, 10, 13), # Piscina 10-13
        # Org4
        (owners[9],  org4, 2, 7,  9),  # Gimnasio 7-9
        (owners[10], org4, 4, 13, 16), # Barbacoa 13-16 (requires approval → pending)
        (tenants[6], org4, 1, 14, 16), # Pádel 14-16
    ]
    for user, org, zone_idx, start_h, end_h in bookings_data:
        zone = zones_by_org[org.id][zone_idx]
        status_val = BookingStatus.PENDING if zone.requires_approval else BookingStatus.CONFIRMED
        db.add(Booking(
            id=uuid4(), zone_id=zone.id, user_id=user.id,
            organization_id=org.id,
            start_time=base_date.replace(hour=start_h),
            end_time=base_date.replace(hour=end_h),
            status=status_val,
        ))

    # ===== 10. DOCUMENTOS =====
    docs_data = [
        # Org1
        (pres1, org1, "Acta Junta Ordinaria Diciembre 2024", "actas/acta_dic_2024.pdf", "pdf", "acta", "approved", 15000),
        (pres1, org1, "Presupuesto 2025", "documentos/presupuesto_2025.pdf", "pdf", "documento", "approved", 8500),
        (admin1, org1, "Normas de uso piscina", "normas/normas_piscina.pdf", "pdf", "norma", "approved", 3200),
        # Org2
        (pres2, org2, "Acta Junta Extraordinaria Enero 2025", "actas/acta_ene_2025.pdf", "pdf", "acta", "pending_approval", 12000),
        (admin1, org2, "Reglamento de régimen interno", "normas/reglamento_interno.pdf", "pdf", "norma", "approved", 28000),
        # Org3
        (pres3, org3, "Acta Junta Ordinaria Noviembre 2024", "actas/acta_nov_2024.pdf", "pdf", "acta", "approved", 18000),
        (admin2, org3, "Planos garaje subterráneo", "documentos/planos_garaje.pdf", "pdf", "documento", "approved", 45000),
        # Org4
        (pres4, org4, "Normas zona barbacoa", "normas/normas_bbq.pdf", "pdf", "norma", "approved", 2100),
        (admin2, org4, "Acta constitución comunidad", "actas/acta_constitucion.pdf", "pdf", "acta", "approved", 22000),
    ]
    for uploader, org, title, file_url, ftype, cat, approval, size in docs_data:
        approved_by_id = None
        approved_at = None
        if approval == "approved":
            # El admin o presidente correspondiente aprobó
            approved_by_id = uploader.id
            approved_at = NOW - timedelta(days=5)
        db.add(Document(
            id=uuid4(), title=title, file_url=file_url, file_type=ftype,
            file_size=size, uploaded_by_id=uploader.id,
            organization_id=org.id, category=cat,
            approval_status=approval, approved_by_id=approved_by_id,
            approved_at=approved_at,
        ))

    # ===== 11. NOTIFICACIONES =====
    notif_data = [
        (owners[0], "Incidencia registrada",       "Tu incidencia 'Fuga de agua en garaje' ha sido registrada correctamente.", "incident"),
        (owners[1], "Incidencia en progreso",       "Tu incidencia 'Farola fundida en jardín' está siendo atendida.",              "incident"),
        (pres1,     "Nueva incidencia en tu comunidad", "Se ha reportado una nueva incidencia: 'Puerta portal no cierra'.",         "incident"),
        (owners[3], "Reserva confirmada",           "Tu reserva de Piscina para mañana a las 11:00 ha sido confirmada.",            "booking"),
        (owners[4], "Reserva pendiente de aprobación", "Tu reserva de Zona Barbacoa está pendiente de aprobación del presidente.",  "booking"),
        (pres2,     "Documento pendiente",          "Hay un nuevo documento pendiente de aprobación: 'Acta Junta Extraordinaria Enero 2025'.", "document"),
        (owners[6], "Incidencia crítica",           "Se ha reportado una incidencia CRÍTICA: 'Ascensor averiado Torre 2'.",         "incident"),
        (pres4,     "Nuevo post publicado",         "Se ha publicado un nuevo anuncio: 'Fiesta de la urbanización'.",               "announcement"),
    ]
    for user, title, msg, ntype in notif_data:
        db.add(Notification(
            id=uuid4(), user_id=user.id, title=title,
            message=msg, notification_type=ntype,
        ))

    # ===== 12. PRESUPUESTOS (Budget Entries) =====
    print("   💰 Presupuestos...")
    from datetime import date
    budget_data = [
        # Org1 – Los Jardines (ingresos y gastos 2024+2025)
        (org1, date(2025, 1, 15), "Cuotas comunitarias", "Cuotas enero 2025", 4500.00, "income", None, admin1),
        (org1, date(2025, 2, 15), "Cuotas comunitarias", "Cuotas febrero 2025", 4500.00, "income", None, admin1),
        (org1, date(2025, 3, 15), "Cuotas comunitarias", "Cuotas marzo 2025", 4500.00, "income", None, admin1),
        (org1, date(2025, 4, 15), "Cuotas comunitarias", "Cuotas abril 2025", 4500.00, "income", None, admin1),
        (org1, date(2025, 5, 15), "Cuotas comunitarias", "Cuotas mayo 2025", 4500.00, "income", None, admin1),
        (org1, date(2025, 1, 20), "Mantenimiento", "Limpieza zonas comunes enero", 850.00, "expense", "Limpiezas del Sur S.L.", admin1),
        (org1, date(2025, 2, 20), "Mantenimiento", "Limpieza zonas comunes febrero", 850.00, "expense", "Limpiezas del Sur S.L.", admin1),
        (org1, date(2025, 3, 10), "Electricidad", "Factura eléctrica zonas comunes Q1", 1200.00, "expense", "Endesa", admin1),
        (org1, date(2025, 2, 5),  "Reparaciones", "Reparación puerta garaje", 450.00, "expense", "Cerrajería Rápida", admin1),
        (org1, date(2025, 4, 1),  "Jardinería", "Mantenimiento jardines primavera", 680.00, "expense", "Jardines Sevilla", pres1),
        (org1, date(2025, 3, 15), "Seguro", "Póliza seguro comunitario anual", 2800.00, "expense", "Mapfre", admin1),
        (org1, date(2025, 5, 10), "Piscina", "Apertura y puesta a punto piscina", 1500.00, "expense", "Pisciclean", pres1),
        # Org2 – Las Palmeras
        (org2, date(2025, 1, 15), "Cuotas comunitarias", "Cuotas enero 2025", 3800.00, "income", None, admin1),
        (org2, date(2025, 2, 15), "Cuotas comunitarias", "Cuotas febrero 2025", 3800.00, "income", None, admin1),
        (org2, date(2025, 3, 15), "Cuotas comunitarias", "Cuotas marzo 2025", 3800.00, "income", None, admin1),
        (org2, date(2025, 1, 25), "Mantenimiento", "Limpieza general enero", 720.00, "expense", "Limpiezas Express", pres2),
        (org2, date(2025, 2, 10), "Electricidad", "Factura luz febrero", 890.00, "expense", "Iberdrola", pres2),
        (org2, date(2025, 3, 20), "Reparaciones", "Reparación ascensor", 1800.00, "expense", "Otis Elevadores", admin1),
        (org2, date(2025, 4, 5),  "Jardinería", "Poda árboles primavera", 420.00, "expense", "Jardines del Sur", pres2),
        # Org3 – El Mirador
        (org3, date(2025, 1, 10), "Cuotas comunitarias", "Cuotas enero 2025", 5200.00, "income", None, admin2),
        (org3, date(2025, 2, 10), "Cuotas comunitarias", "Cuotas febrero 2025", 5200.00, "income", None, admin2),
        (org3, date(2025, 1, 28), "Mantenimiento", "Limpieza zonas comunes", 950.00, "expense", "Limpiezas Málaga", admin2),
        (org3, date(2025, 2, 15), "Seguro", "Seguro comunitario anual", 3200.00, "expense", "Allianz", pres3),
        (org3, date(2025, 3, 1),  "Electricidad", "Electricidad Q1", 1450.00, "expense", "Endesa", admin2),
        # Org4 – Puerta del Sol
        (org4, date(2025, 1, 12), "Cuotas comunitarias", "Cuotas enero 2025", 4000.00, "income", None, admin2),
        (org4, date(2025, 2, 12), "Cuotas comunitarias", "Cuotas febrero 2025", 4000.00, "income", None, admin2),
        (org4, date(2025, 1, 20), "Mantenimiento", "Limpieza enero", 780.00, "expense", "Limpiezas Granada", admin2),
        (org4, date(2025, 2, 25), "Reparaciones", "Reparación fontanería patio", 350.00, "expense", "Fontanería Rápida", pres4),
        (org4, date(2025, 3, 10), "Electricidad", "Factura eléctrica Q1", 1100.00, "expense", "Endesa", admin2),
        # Datos 2024 (para historial)
        (org1, date(2024, 6, 15), "Cuotas comunitarias", "Cuotas junio 2024", 4200.00, "income", None, admin1),
        (org1, date(2024, 7, 15), "Cuotas comunitarias", "Cuotas julio 2024", 4200.00, "income", None, admin1),
        (org1, date(2024, 6, 20), "Mantenimiento", "Limpieza junio 2024", 800.00, "expense", "Limpiezas del Sur S.L.", admin1),
        (org1, date(2024, 7, 10), "Piscina", "Mantenimiento piscina verano", 2200.00, "expense", "Pisciclean", pres1),
        (org1, date(2024, 8, 5),  "Electricidad", "Factura eléctrica verano", 1600.00, "expense", "Endesa", admin1),
    ]
    for org, edate, cat, concept, amount, etype, provider, uploader in budget_data:
        db.add(BudgetEntry(
            id=uuid4(), organization_id=org.id,
            entry_date=edate, category=cat, concept=concept,
            amount=amount, entry_type=etype, provider=provider,
            uploaded_by_id=uploader.id,
        ))

    # ===== COMMIT =====
    db.commit()
    print("✅ Seed completado exitosamente.")


# ---------------------------------------------------------------------------
# Limpieza previa
# ---------------------------------------------------------------------------
def clean(db: Session):
    """Elimina todos los datos en orden para respetar FKs."""
    print("🧹 Limpiando datos existentes...")
    db.execute(BudgetEntry.__table__.delete())
    db.execute(PostComment.__table__.delete())
    db.execute(PostLike.__table__.delete())
    db.execute(Notification.__table__.delete())
    db.execute(IncidentComment.__table__.delete())
    db.execute(Booking.__table__.delete())
    db.execute(Document.__table__.delete())
    db.execute(Incident.__table__.delete())
    db.execute(Post.__table__.delete())
    db.execute(Invitation.__table__.delete())
    db.execute(Zone.__table__.delete())
    db.execute(UserOrganization.__table__.delete())
    db.execute(User.__table__.delete())
    db.execute(Organization.__table__.delete())
    db.commit()
    print("   Datos eliminados.")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    print("=" * 60)
    print("  SEED DE DATOS — TFG Urbanizaciones")
    print("=" * 60)

    db = SessionLocal()
    try:
        clean(db)
        seed(db)
    except Exception as e:
        db.rollback()
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    finally:
        db.close()

    print()
    print("📋 Credenciales de acceso (contraseña: Test1234)")
    print("-" * 60)
    print("ADMINS:")
    print("  admin1@tfg.com     → Org: Los Jardines, Las Palmeras")
    print("  admin2@tfg.com     → Org: El Mirador, Puerta del Sol")
    print()
    print("PRESIDENTES:")
    print("  presidente1@tfg.com → Residencial Los Jardines")
    print("  presidente2@tfg.com → Urbanización Las Palmeras")
    print("  presidente3@tfg.com → Conjunto Residencial El Mirador")
    print("  presidente4@tfg.com → Residencial Puerta del Sol")
    print()
    print("VECINOS (propietarios): vecino1@tfg.com … vecino12@tfg.com")
    print("INQUILINOS (con contrato): inquilino1@tfg.com … inquilino8@tfg.com")
    print()
    print("Todos con contraseña: Test1234")
    print("=" * 60)


if __name__ == "__main__":
    main()
