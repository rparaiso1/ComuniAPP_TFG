# ComuniApp (TFG DAM)

Aplicación multiplataforma para la gestión de comunidades/urbanizaciones.

- Frontend: Flutter (Web/Mobile)
- Backend: FastAPI + SQLAlchemy
- Base de datos: PostgreSQL 15 (Docker)

## Funcionalidades principales

- Autenticación JWT (access + refresh)
- Gestión por roles: ADMIN, PRESIDENT, NEIGHBOR
- Multi-organización (aislamiento por organization_id)
- Tablón, incidencias, reservas, documentos, calendario y notificaciones
- Panel administrativo con importación/exportación de datos

## Requisitos

- Docker Desktop
- Python 3.11+
- Flutter SDK 3.38+

## Puesta en marcha (Windows)

Desde la raíz del proyecto:

```powershell
./start-all.ps1
```

Scripts disponibles:

- `start-all.ps1`: DB + backend + frontend
- `start-db.ps1`: solo PostgreSQL + pgAdmin
- `start-backend.ps1`: solo backend FastAPI
- `start-flutter.ps1`: solo frontend Flutter Web

Nota: `start-all.ps1` y `start-db.ps1` limpian contenedores previos (`tfg_postgres`, `tfg_pgadmin`) para evitar conflictos de nombre en Docker.

## Variables de entorno (backend/.env)

```env
DATABASE_URL=postgresql+psycopg://tfg_user:tfg_password_123@localhost:5433/tfg_db
SECRET_KEY=<tu_clave_secreta_jwt>
```

Referencia: `backend/.env.example`

## Endpoints locales

- Backend API: http://localhost:8000
- Swagger: http://localhost:8000/docs
- PostgreSQL: localhost:5433
- pgAdmin: http://localhost:5050
- Flutter Web: http://localhost:3000

## Usuarios de prueba disponibles

Contraseña para todos: `Test1234`

### ADMIN

- `admin1@tfg.com` (Jardines del Valle, Las Palmeras)
- `admin2@tfg.com` (Mirador de la Sierra, Puerta del Sol)

### PRESIDENT

- `presidente1@tfg.com` (Jardines del Valle)
- `presidente2@tfg.com` (Las Palmeras)
- `presidente3@tfg.com` (Mirador de la Sierra)
- `presidente4@tfg.com` (Puerta del Sol)

### NEIGHBOR

- `vecino1@tfg.com` a `vecino3@tfg.com` (Jardines del Valle)
- `vecino4@tfg.com` a `vecino6@tfg.com` (Las Palmeras)
- `vecino7@tfg.com` a `vecino9@tfg.com` (Mirador de la Sierra)
- `vecino10@tfg.com` a `vecino12@tfg.com` (Puerta del Sol)
- `inquilino1@tfg.com` a `inquilino2@tfg.com` (Jardines del Valle)
- `inquilino3@tfg.com` a `inquilino4@tfg.com` (Las Palmeras)
- `inquilino5@tfg.com` a `inquilino6@tfg.com` (Mirador de la Sierra)
- `inquilino7@tfg.com` a `inquilino8@tfg.com` (Puerta del Sol)

Para regenerar los datos de prueba:

```powershell
cd backend
python seed_data.py
```

## Tests

Frontend:

```powershell
flutter test
```

Backend (suite principal por roles):

```powershell
cd backend
python test_all_roles.py
```

## Estructura del proyecto (resumen)

```text
ComuniAPP_TFG/
├── backend/               # FastAPI + SQLAlchemy + Alembic
├── lib/                   # Flutter (features por módulo)
├── test/                  # Tests frontend
├── docker-compose.yml
├── start-all.ps1
├── start-db.ps1
├── start-backend.ps1
└── start-flutter.ps1
```

