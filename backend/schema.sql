-- ============================================================
-- TFG Urbanizaciones - Schema SQL Consolidado
-- Módulos: Usuarios/Roles, Reservas(Zonas), Incidencias, Tablón/Documentos
-- ============================================================

BEGIN;

-- ============ EXTENSIONES ============
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============ ORGANIZACIONES ============
CREATE TABLE IF NOT EXISTS organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    address TEXT,
    logo_url VARCHAR(500),
    primary_color VARCHAR(10) DEFAULT '#6366F1',
    phone VARCHAR(20),
    email VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ USUARIOS ============
-- Roles: ADMIN, PRESIDENT, NEIGHBOR
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    dwelling VARCHAR(100),        -- Ej: "Bloque A - 3ºB"
    avatar_url VARCHAR(500),
    role VARCHAR(50) NOT NULL DEFAULT 'NEIGHBOR',
    is_active BOOLEAN DEFAULT TRUE,
    contract_end TIMESTAMP,       -- Para inquilinos, cuándo expira el acceso
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ USUARIO <-> ORGANIZACIÓN ============
CREATE TABLE IF NOT EXISTS user_organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL DEFAULT 'NEIGHBOR',
    dwelling VARCHAR(100),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, organization_id)
);

-- ============ INVITACIONES ============
CREATE TABLE IF NOT EXISTS invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    dwelling VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'NEIGHBOR',
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    token VARCHAR(255) UNIQUE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP
);

-- ============ TABLÓN (POSTS) ============
CREATE TABLE IF NOT EXISTS posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    is_pinned BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ ZONAS COMUNES ============
CREATE TABLE IF NOT EXISTS zones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    zone_type VARCHAR(50) NOT NULL DEFAULT 'other',
    description TEXT,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    max_capacity INTEGER,
    max_booking_hours INTEGER DEFAULT 2,
    max_bookings_per_user_day INTEGER DEFAULT 1,
    advance_booking_days INTEGER DEFAULT 30,
    requires_approval BOOLEAN DEFAULT FALSE,
    available_from TIME DEFAULT '08:00',
    available_until TIME DEFAULT '22:00',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ RESERVAS ============
CREATE TABLE IF NOT EXISTS bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    zone_id UUID NOT NULL REFERENCES zones(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    status VARCHAR(50) DEFAULT 'confirmed',
    notes TEXT,
    cancellation_reason TEXT,
    cancelled_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ INCIDENCIAS ============
-- Status: OPEN, IN_PROGRESS, RESOLVED
CREATE TABLE IF NOT EXISTS incidents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    priority VARCHAR(50) NOT NULL DEFAULT 'medium',
    status VARCHAR(50) NOT NULL DEFAULT 'open',
    reporter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    assigned_to_id UUID REFERENCES users(id) ON DELETE SET NULL,
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    location VARCHAR(255),
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

-- ============ COMENTARIOS DE INCIDENCIAS ============
CREATE TABLE IF NOT EXISTS incident_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_id UUID NOT NULL REFERENCES incidents(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ DOCUMENTOS ============
CREATE TABLE IF NOT EXISTS documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    file_size INTEGER,
    uploaded_by_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    description VARCHAR(500),
    category VARCHAR(100),
    approval_status VARCHAR(20) DEFAULT 'approved',
    approved_by_id UUID REFERENCES users(id) ON DELETE SET NULL,
    approved_at TIMESTAMP,
    rejection_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============ NOTIFICACIONES ============
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(50) DEFAULT 'system',
    link VARCHAR(500),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- ÍNDICES
-- ============================================================

-- Users
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- User Organizations
CREATE INDEX IF NOT EXISTS idx_user_orgs_user ON user_organizations(user_id);
CREATE INDEX IF NOT EXISTS idx_user_orgs_org ON user_organizations(organization_id);

-- Invitations
CREATE INDEX IF NOT EXISTS idx_invitations_email ON invitations(email);
CREATE INDEX IF NOT EXISTS idx_invitations_token ON invitations(token);
CREATE INDEX IF NOT EXISTS idx_invitations_org ON invitations(organization_id);

-- Posts
CREATE INDEX IF NOT EXISTS idx_posts_author ON posts(author_id);
CREATE INDEX IF NOT EXISTS idx_posts_org ON posts(organization_id);
CREATE INDEX IF NOT EXISTS idx_posts_created ON posts(created_at DESC);

-- Zones
CREATE INDEX IF NOT EXISTS idx_zones_org ON zones(organization_id);

-- Bookings
CREATE INDEX IF NOT EXISTS idx_bookings_user ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_zone ON bookings(zone_id);
CREATE INDEX IF NOT EXISTS idx_bookings_time ON bookings(start_time, end_time);
CREATE INDEX IF NOT EXISTS idx_bookings_org ON bookings(organization_id);

-- Incidents
CREATE INDEX IF NOT EXISTS idx_incidents_reporter ON incidents(reporter_id);
CREATE INDEX IF NOT EXISTS idx_incidents_assigned ON incidents(assigned_to_id);
CREATE INDEX IF NOT EXISTS idx_incidents_status ON incidents(status);
CREATE INDEX IF NOT EXISTS idx_incidents_org ON incidents(organization_id);

-- Incident Comments
CREATE INDEX IF NOT EXISTS idx_incident_comments_incident ON incident_comments(incident_id);

-- Documents
CREATE INDEX IF NOT EXISTS idx_documents_uploader ON documents(uploaded_by_id);
CREATE INDEX IF NOT EXISTS idx_documents_org ON documents(organization_id);
CREATE INDEX IF NOT EXISTS idx_documents_approval ON documents(approval_status);

-- Notifications
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(user_id, is_read);

-- ============================================================
-- DATOS INICIALES
-- ============================================================

-- Organización de ejemplo
INSERT INTO organizations (id, name, code, address, email)
VALUES ('a0000000-0000-0000-0000-000000000001', 'Urbanización Demo', 'URB_DEMO', 'Calle Principal 1, Madrid', 'admin@urbdemo.com')
ON CONFLICT DO NOTHING;

-- Admin user (password: admin123)
INSERT INTO users (id, email, hashed_password, full_name, role, is_active, dwelling)
VALUES (
    'b0000000-0000-0000-0000-000000000001',
    'admin@tfg.com',
    '$2b$12$O0n7mR4L1.ukgYCFTbu3AuXRSoceYUo1fNs087Pbey6D7aDZ2R7FK',
    'Administrador',
    'ADMIN',
    TRUE,
    'Oficina'
)
ON CONFLICT (email) DO NOTHING;

-- Vincular admin a la organización
INSERT INTO user_organizations (user_id, organization_id, role, dwelling)
VALUES (
    'b0000000-0000-0000-0000-000000000001',
    'a0000000-0000-0000-0000-000000000001',
    'ADMIN',
    'Oficina'
)
ON CONFLICT (user_id, organization_id) DO NOTHING;

-- Zonas de ejemplo
INSERT INTO zones (name, zone_type, description, organization_id, max_capacity, max_booking_hours)
VALUES
    ('Piscina', 'pool', 'Piscina comunitaria', 'a0000000-0000-0000-0000-000000000001', 30, 3),
    ('Pista de Pádel', 'court', 'Pista de pádel con iluminación', 'a0000000-0000-0000-0000-000000000001', 4, 2),
    ('Salón de Eventos', 'room', 'Salón multiusos para eventos', 'a0000000-0000-0000-0000-000000000001', 50, 4),
    ('Zona BBQ', 'bbq', 'Zona de barbacoa con mesas', 'a0000000-0000-0000-0000-000000000001', 12, 3)
ON CONFLICT DO NOTHING;

COMMIT;
