# TFG Backend API

Backend API REST desarrollada con FastAPI y PostgreSQL siguiendo Clean Architecture.

## Requisitos

- Python 3.10+
- PostgreSQL 14+
- pip

## Instalación

### 1. Crear entorno virtual

```bash
cd backend
python -m venv venv

# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate
```

### 2. Instalar dependencias

```bash
pip install -r requirements.txt
```

### 3. Configurar variables de entorno

Copia `.env.example` a `.env` y configura las variables:

```bash
cp .env.example .env
```

Edita `.env` con tus credenciales:

```env
DATABASE_URL=postgresql://user:password@localhost:5432/tfg_db
SECRET_KEY=your-super-secret-key-change-this
```

### 4. Crear base de datos PostgreSQL

```bash
# Conecta a PostgreSQL
psql -U postgres

# Crea la base de datos
CREATE DATABASE tfg_db;
\q
```

### 5. Ejecutar el servidor

```bash
uvicorn app.main:app --reload
```

La API estará disponible en: http://localhost:8000

## Documentación

- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Endpoints principales

### Autenticación
- `POST /api/auth/register` - Registrar usuario
- `POST /api/auth/login` - Login
- `GET /api/auth/me` - Obtener usuario actual
- `POST /api/auth/logout` - Logout

### Posts
- `GET /api/posts` - Listar posts
- `POST /api/posts` - Crear post
- `GET /api/posts/{id}` - Obtener post
- `PUT /api/posts/{id}` - Actualizar post
- `DELETE /api/posts/{id}` - Eliminar post

### Reservas
- `GET /api/bookings` - Listar reservas
- `POST /api/bookings` - Crear reserva
- `GET /api/bookings/{id}` - Obtener reserva
- `PUT /api/bookings/{id}` - Actualizar reserva
- `DELETE /api/bookings/{id}` - Eliminar reserva

### Incidencias
- `GET /api/incidents` - Listar incidencias
- `POST /api/incidents` - Crear incidencia
- `GET /api/incidents/{id}` - Obtener incidencia
- `PUT /api/incidents/{id}` - Actualizar incidencia
- `DELETE /api/incidents/{id}` - Eliminar incidencia

## Estructura del proyecto

```
backend/
├── app/
│   ├── api/              # Endpoints API
│   │   ├── auth.py
│   │   ├── posts.py
│   │   ├── bookings.py
│   │   └── incidents.py
│   ├── core/             # Configuración y seguridad
│   │   ├── config.py
│   │   ├── database.py
│   │   ├── security.py
│   │   └── deps.py
│   ├── models/           # Modelos SQLAlchemy
│   │   ├── user.py
│   │   ├── post.py
│   │   ├── booking.py
│   │   └── incident.py
│   ├── schemas/          # Schemas Pydantic
│   │   ├── user.py
│   │   ├── post.py
│   │   ├── booking.py
│   │   └── incident.py
│   └── main.py          # Aplicación principal
├── requirements.txt
├── .env.example
└── README.md
```

## Desarrollo

### Crear migraciones con Alembic (opcional)

```bash
alembic init migrations
alembic revision --autogenerate -m "Initial migration"
alembic upgrade head
```

### Testing

```bash
pytest
```

## Despliegue

Para producción, configura:

1. `DEBUG=False` en `.env`
2. Usa un `SECRET_KEY` fuerte y único
3. Configura `allow_origins` en CORS con tus dominios específicos
4. Usa HTTPS
5. Configura un proxy inverso (Nginx)
6. Usa gunicorn o similar:

```bash
gunicorn app.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```
