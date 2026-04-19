-- backend/migrations/init.sql

-- ─────────────────────────────────────────────────────────────────────────────
-- CHANGELOG
-- ─────────────────────────────────────────────────────────────────────────────
--   • Initial — users, tenants, manifest_versions, content_records, assets,
--     waitlist. Run on first container start via docker-entrypoint-initdb.d.
-- ─────────────────────────────────────────────────────────────────────────────

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── Users ─────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email       TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    name        TEXT NOT NULL DEFAULT '',
    role        TEXT NOT NULL DEFAULT 'clientAdmin'
                CHECK (role IN ('clientAdmin', 'developer', 'architect')),
    tenant_id   UUID,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS users_email_idx ON users(email);

-- ── Tenants ───────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS tenants (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id   TEXT UNIQUE NOT NULL,  -- 'qspace', 'acme', etc.
    name        TEXT NOT NULL,
    domain      TEXT UNIQUE NOT NULL,
    suite_id    TEXT NOT NULL DEFAULT 'saas',
    status      TEXT NOT NULL DEFAULT 'provisioning'
                CHECK (status IN ('active', 'suspended', 'provisioning')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- QSpace itself as the first tenant
INSERT INTO tenants (client_id, name, domain, suite_id, status)
VALUES ('qspace', 'QSpace', 'qspace.io', 'saas', 'active')
ON CONFLICT (client_id) DO NOTHING;

-- ── Manifest Versions ─────────────────────────────────────────────────────────
-- Audit trail: every publish creates a new row.
-- Never update rows here — append only.
CREATE TABLE IF NOT EXISTS manifest_versions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id       UUID NOT NULL REFERENCES tenants(id),
    version_tag     TEXT NOT NULL,
    manifest_json   JSONB NOT NULL,
    published_by    TEXT NOT NULL,
    publish_note    TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS mv_tenant_idx ON manifest_versions(tenant_id, created_at DESC);

-- ── Admin Drafts ──────────────────────────────────────────────────────────────
-- One row per tenant — overwritten on autosave.
-- Not the authoritative published manifest — that's manifest_versions.
CREATE TABLE IF NOT EXISTS admin_drafts (
    tenant_id     UUID PRIMARY KEY REFERENCES tenants(id),
    overrides     JSONB NOT NULL DEFAULT '{}',
    content       JSONB NOT NULL DEFAULT '{}',
    last_modified TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    modified_by   TEXT NOT NULL DEFAULT ''
);

-- ── Content Records ───────────────────────────────────────────────────────────
-- Keyed by the canonical 5-part key: space+screen+section+block+property.
-- Partial keys are not allowed — all 5 parts are required.
CREATE TABLE IF NOT EXISTS content_records (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id   UUID NOT NULL REFERENCES tenants(id),
    space_id    TEXT NOT NULL,   -- 'space_value'
    screen_id   TEXT NOT NULL,   -- 'screen_entry'
    section_id  TEXT NOT NULL,   -- 'core'
    block_id    TEXT NOT NULL,   -- 'hero'
    property    TEXT NOT NULL,   -- 'headline'
    value       TEXT NOT NULL DEFAULT '',
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by  TEXT NOT NULL DEFAULT '',
    UNIQUE(tenant_id, space_id, screen_id, section_id, block_id, property)
);

CREATE INDEX IF NOT EXISTS cr_tenant_space_idx
    ON content_records(tenant_id, space_id, screen_id);

-- ── Assets ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS assets (
    asset_id    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id   UUID NOT NULL REFERENCES tenants(id),
    url         TEXT NOT NULL,     -- persistent CDN URL — never a local path
    filename    TEXT NOT NULL,
    size        BIGINT NOT NULL DEFAULT 0,
    mime_type   TEXT NOT NULL DEFAULT 'application/octet-stream',
    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    uploaded_by TEXT NOT NULL DEFAULT ''
);

CREATE INDEX IF NOT EXISTS assets_tenant_idx ON assets(tenant_id, uploaded_at DESC);

-- ── Waitlist ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS waitlist (
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email      TEXT UNIQUE NOT NULL,
    source     TEXT NOT NULL DEFAULT 'web',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
