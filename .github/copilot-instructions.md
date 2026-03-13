# ComuniApp — Copilot Project Context

> **TFG DAM** — App de gestión de comunidades/urbanizaciones.
> Última actualización: junio 2025.

---

## 1. Stack tecnológico

| Capa | Tecnología | Versión |
|------|-----------|---------|
| **Frontend** | Flutter Web/Mobile | 3.38+ / Dart 3.10+ |
| **State Mgmt** | Riverpod (Notifier) | flutter_riverpod 2.5 |
| **Charts** | fl_chart | 0.69 |
| **Routing** | GoRouter | 14.2 |
| **i18n** | flutter_localizations + ARB | intl 0.20.2 |
| **Backend** | FastAPI (Python) | 0.115 |
| **ORM** | SQLAlchemy 2.0 | 2.0.36 |
| **DB** | PostgreSQL 15 (Docker) | puerto 5433 |
| **Auth** | JWT (access + refresh tokens) | python-jose |
| **Migrations** | Alembic | 1.14 |
| **Validación** | Pydantic v2 | 2.10 |

---

## 2. Cómo levantar el proyecto

```bash
# 1. Base de datos
docker-compose up -d          # PostgreSQL en puerto 5433, pgAdmin en 5050

# 2. Backend
cd backend
pip install -r requirements.txt
# Crear .env con DATABASE_URL, SECRET_KEY (ver backend/.env.example)
python start_server.py        # o: uvicorn app.main:app --reload --port 8000

# 3. Frontend
cd ..  # raíz del proyecto
flutter pub get
flutter run -d chrome --web-port 3000
```

Variables de entorno backend (`.env`):
```
DATABASE_URL=postgresql+psycopg://tfg_user:tfg_password_123@localhost:5433/tfg_db
SECRET_KEY=<clave_secreta_jwt>
```

---

## 3. Arquitectura del proyecto

### Backend (`backend/app/`)
```
main.py                 ← FastAPI app, CORS, router mount
core/
  config.py             ← Settings (pydantic-settings, .env)
  database.py           ← SQLAlchemy engine + SessionLocal + get_db
  deps.py               ← Depends() — auth, roles, org filtering
  security.py           ← JWT encode/decode, password hashing
  security_utils.py     ← Rate limiter, input sanitizer
api/                    ← Routers (1 archivo por recurso)
  auth.py, admin.py, bookings.py, calendar.py, documents.py,
  incidents.py, invitations.py, notifications.py, organizations.py,
  posts.py, stats.py, zones.py
services/               ← Lógica de negocio (1 servicio por recurso)
  admin_service.py, auth_service.py, booking_service.py, etc.
models/                 ← SQLAlchemy models
  user.py, organization.py, user_organization.py (M2M),
  booking.py, document.py, incident.py, incident_comment.py,
  invitation.py, notification.py, post.py, zone.py
schemas/                ← Pydantic v2 schemas (request/response)
  user.py, admin.py, booking.py, document.py, incident.py,
  invitation.py, organization.py, post.py, zone.py
```

**Patrón**: Router → Service → Model/Schema. Los routers NO contienen lógica de negocio.

### Frontend (`lib/`)
```
main.dart / bootstrap.dart / app.dart
core/
  config/       ← app_constants.dart, env_config.dart
  data/         ← base_remote_datasource.dart (HTTP genérico)
  di/           ← providers.dart (Riverpod), locale_provider.dart,
                   theme_provider.dart (ThemeModeNotifier)
  errors/       ← app_exception.dart, exceptions.dart
  routing/      ← router.dart (GoRouter + auth guard), route_names.dart
  services/     ← local_storage_service.dart (Hive), app_logger.dart,
                   notifications_service.dart, org_selector_service.dart
  theme/        ← app_theme.dart, app_colors.dart (+ ThemeColorsExtension),
                   app_animations.dart
  utils/        ← form_validators.dart, l10n_extension.dart,
                   responsive.dart, paginated_state.dart,
                   web_download_stub.dart / web_download_web.dart
  widgets/      ← error_dialog.dart, app_feedback.dart,
                   common_widgets.dart, dashboard_widgets.dart,
                   navigation_widgets.dart, org_selector_chip.dart
features/
  auth/         ← Clean Architecture completa (data/domain/presentation)
  home/         ← HomePage con dashboard stats + charts (fl_chart)
  board/        ← Tablón de anuncios (Clean Architecture + pagination)
  bookings/     ← Reservas (Clean Architecture + pagination)
  incidents/    ← Incidencias (Clean Architecture + pagination)
  documents/    ← Documentos (Clean Architecture + real file upload + pagination)
  notifications/ ← Notificaciones (Clean Architecture)
  calendar/     ← Calendario (Clean Architecture)
  admin/        ← Importar usuarios (CSV/Excel), gestión invitaciones, exportar datos (CSV)
l10n/           ← app_es.arb (template ~300 keys), app_en.arb, generated/
```

**Patrón**: Clean Architecture por feature (data → domain → presentation). TODAS las features siguen este patrón.

---

## 4. Modelo de datos y roles

### Roles (3 niveles, a nivel de organización):
- **ADMIN** — Gestión total: usuarios, zonas, documentos, incidencias, reservas, invitaciones, importación masiva
- **PRESIDENT** — Gestión de su urbanización: aprobar reservas, cambiar estado incidencias, publicar documentos, gestionar invitaciones. NO puede asignar rol ADMIN.
- **NEIGHBOR** — Usuario base: crear incidencias, reservar zonas, ver tablón/documentos/calendario. (Propietarios e inquilinos comparten este rol)

### Multi-tenancy:
- Tabla `user_organizations` (M2M) con `role` y `is_active` por organización
- TODAS las queries filtran por `organization_id` del usuario
- Un admin puede gestionar múltiples organizaciones
- Cross-org isolation verificado con tests

### Modelos principales:
| Modelo | Relaciones clave |
|--------|-----------------|
| `User` | → UserOrganization (M2M) |
| `Organization` | → UserOrganization, Zone |
| `Zone` | → Organization, Booking |
| `Booking` | → User, Zone (estados: pending/approved/cancelled) |
| `Post` | → User, Organization |
| `Incident` | → User (reporter), Organization, IncidentComment |
| `Document` | → User (uploader), Organization (estados: pending_approval/approved/rejected) |
| `Notification` | → User |
| `Invitation` | → Organization (token único, expira 7d) |

---

## 5. API Endpoints (prefix `/api`)

| Grupo | Endpoints principales |
|-------|----------------------|
| **Auth** | POST /auth/register, /auth/login, /auth/refresh, GET /auth/me, PUT /auth/me, POST /auth/change-password |
| **Admin** | GET /admin/dashboard, /admin/users, GET/PUT/DELETE /admin/users/{id}, PUT /users/{id}/role, /users/{id}/toggle, POST /admin/users/{id}/reset-password, POST /admin/import-users, GET /admin/export/{resource} |
| **Organizations** | GET /organizations/, /organizations/{id}, /organizations/{id}/members |
| **Zones** | CRUD /zones/ |
| **Posts** | CRUD /posts/ |
| **Incidents** | CRUD /incidents/, POST /{id}/comments, PUT /{id}/status |
| **Bookings** | CRUD /bookings/, PUT /{id}/approve, /{id}/cancel |
| **Documents** | CRUD /documents/, PUT /{id}/status, POST /upload (multipart), GET /files/{filename} |
| **Notifications** | GET /notifications/, POST /{id}/read, /read-all, DELETE /{id}, DELETE / |
| **Invitations** | CRUD /invitations/, GET /verify/{token}, POST /register |
| **Stats** | GET /stats/dashboard, /stats/bookings, /stats/incidents |
| **Calendar** | GET /calendar/events, /today, /upcoming, /month |

---

## 6. Datos de prueba (seed)

Password para TODOS los usuarios: **`Test1234`**

| Email | Rol | Organizaciones |
|-------|-----|---------------|
| `admin1@tfg.com` | ADMIN | Jardines del Valle, Las Palmeras |
| `admin2@tfg.com` | ADMIN | Mirador de la Sierra, Puerta del Sol |
| `presidente1@tfg.com` | PRESIDENT | Jardines del Valle |
| `presidente2@tfg.com` | PRESIDENT | Las Palmeras |
| `presidente3@tfg.com` | PRESIDENT | Mirador de la Sierra |
| `presidente4@tfg.com` | PRESIDENT | Puerta del Sol |
| `vecino1@tfg.com` — `vecino3@tfg.com` | NEIGHBOR | Jardines del Valle (propietarios) |
| `vecino4@tfg.com` — `vecino6@tfg.com` | NEIGHBOR | Las Palmeras (propietarios) |
| `vecino7@tfg.com` — `vecino9@tfg.com` | NEIGHBOR | Mirador de la Sierra |
| `vecino10@tfg.com` — `vecino12@tfg.com` | NEIGHBOR | Puerta del Sol |
| `inquilino1@tfg.com` — `inquilino2@tfg.com` | NEIGHBOR | Jardines del Valle (inquilinos) |
| `inquilino3@tfg.com` — `inquilino4@tfg.com` | NEIGHBOR | Las Palmeras |
| `inquilino5@tfg.com` — `inquilino6@tfg.com` | NEIGHBOR | Mirador de la Sierra |
| `inquilino7@tfg.com` — `inquilino8@tfg.com` | NEIGHBOR | Puerta del Sol |

Script: `backend/seed_data.py` → ejecutar con `python seed_data.py`

---

## 7. Internacionalización (i18n)

- Idiomas: **Español** (template) y **Inglés**
- ARB files: `lib/l10n/app_es.arb` (~300 keys), `lib/l10n/app_en.arb`
- Config: `l10n.yaml` → output class `S`, output dir `lib/l10n/generated/`
- Uso: `context.l.clave` (extensión en `lib/core/utils/l10n_extension.dart`)
- Cambio de idioma: `_LanguageSwitcher` widget en `profile_page.dart`
- Persistencia: Hive box `app_settings`, key `locale`
- Regenerar: `flutter gen-l10n`

---

## 8. Testing

- **Backend**: `backend/test_all_roles.py` → 164 tests, 15 secciones, 8 tipos de usuario
- Ejecutar: `cd backend && python test_all_roles.py`
- Requiere: backend corriendo en port 8000, seed data cargado
- **Frontend**: `flutter test` → 182 tests (7 test suites)
  - `test/core/utils/responsive_test.dart` — Responsive utility
  - `test/core/utils/form_validators_test.dart` — Form validators
  - `test/core/utils/paginated_state_test.dart` — Pagination mixin
  - `test/features/auth/domain/entities/user_entity_test.dart` — UserEntity, UserRole, UserOrganization
  - `test/features/auth/data/models/user_model_test.dart` — UserModel.fromJson
  - `test/features/documents/domain/entities/document_entity_test.dart` — DocumentEntity
  - `test/features/documents/data/models/document_model_test.dart` — DocumentModel.fromJson

---

## 9. Convenciones de código

### Backend (Python/FastAPI):
- Servicios con `class XxxService` — toda la lógica de negocio aquí
- Routers solo delegan a servicios, manejan HTTP status codes
- Errores de servicio: `raise XxxError(message, status)` → router hace `raise HTTPException`
- Schemas Pydantic v2: usar `@field_validator` + `@classmethod`, `Field(max_length=...)`, `model_config`
- Queries SIEMPRE filtran por `org_ids` del usuario autenticado
- `to_response()` (público) para convertir model → dict en servicios

### Frontend (Flutter/Dart):
- Clean Architecture por feature: `data/` → `domain/` → `presentation/`
- State management: `Notifier` + `NotifierProvider` (Riverpod 2+)
- i18n: SIEMPRE usar `context.l.clave`, NUNCA strings hardcodeados
- Imports: `package:comuniapp/...` para imports del proyecto
- Widgets: `ConsumerWidget` o `ConsumerStatefulWidget` para acceso a Riverpod
- Errores: `AppException` hierarchy en `core/errors/`
- HTTP: `BaseRemoteDataSource` para features con Clean Arch; controllers directos para features simples
- Colores: `context.colors.*` (ThemeColorsExtension) para respetar dark/light mode
- Responsive: `context.responsive.*` para breakpoints y layouts adaptativos
- Org-aware HTTP: `ref.read(authHeadersProvider)` incluye Authorization + X-Organization-ID
- Paginación: `PaginatedState` mixin, `kDefaultPageSize = 20`, `loadMore()` en controllers

---

## 10. Decisiones técnicas importantes

1. **Roles a nivel de organización** (`user_organizations.role`), NO en `users.role` (el campo `users.role` se sincroniza como fallback pero la fuente de verdad es la tabla M2M)
2. **Auth guard en router** — redirect callback en GoRouter lee token de Hive
3. **CORS restringido** — orígenes desde `settings.CORS_ORIGINS`, no wildcard
4. **Password policy** — mínimo 8 chars, al menos 1 mayúscula, 1 minúscula, 1 dígito
5. **Rate limiting** — 30 requests/minuto en auth endpoints
6. **DB pool** — `pool_size=10, max_overflow=20, pool_recycle=1800`
7. **Refresh token en body** (POST), no en query string
8. **Solo ADMIN puede asignar rol ADMIN** (president escalation prevented)
9. **Invitaciones** — registro por token con expiración 7 días
10. **Soft delete para usuarios** (`is_active` toggle), hard delete para contenido

---

## 11. Estructura de archivos clave

```
TFG/
├── .github/copilot-instructions.md    ← ESTE ARCHIVO
├── pubspec.yaml                       ← Dependencias Flutter
├── l10n.yaml                          ← Config i18n
├── docker-compose.yml                 ← PostgreSQL + pgAdmin
├── lib/                               ← Código Flutter
├── backend/
│   ├── .env                           ← Variables de entorno (NO en git)
│   ├── requirements.txt               ← Dependencias Python
│   ├── alembic.ini + alembic/         ← Migraciones DB
│   ├── seed_data.py                   ← Datos de prueba
│   ├── test_all_roles.py              ← Tests comprehensivos (164)
│   └── app/                           ← Código FastAPI
├── android/ ios/ web/                 ← Platform-specific
└── build/                             ← Build output
```

---

## 12. Problemas conocidos y deuda técnica

### Prioridad media:
- `NotificationsService` (push local) definido pero no integrado completamente
- `form_validators.dart` sin i18n (sin BuildContext)
- Animaciones `TweenAnimationBuilder` en items de lista se re-evalúan al scroll

### Prioridad baja:
- `appRouter` global en vez de provider inyectable
- Migrar `dart:html` completamente a `package:web` (ya parcialmente hecho)
