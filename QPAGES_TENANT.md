# QSpace Pages

**Multi-tenant Flutter web platform. QSpace itself is its first client.**

---

## What this is

QSpace Pages is a Flutter-based site engine built on a `Canon → Suite → Client` overlay
architecture. Every tenant gets their own brand, copy, and feature configuration at runtime —
zero recompile between clients.

This repo is the full QSpace platform **and** the QSpace marketing site. The site at `qspace.io`
is rendered by the exact same engine it sells. That's what "QSpace as a tenant of QSpace Pages" means.
The overlay that defines the QSpace brand lives at `assets/client/qspace/overlay.json`.

---

## Architecture in one picture

```
Canon (lib/canon/)            — Locked structural IDs and vocab
  ↓
Suite manifest                — Template defaults (assets/suite/saas/manifest.json)
  ↓
Client overlay                — Brand + content overrides (assets/client/qspace/overlay.json)
  ↓
MergeEngine.resolve()         — deepMerge of all layers → effectiveManifest
  ↓
BrandConfig.fromManifest()    — Typed brand config object
  ↓
BrandScope → AppCanvas → MaterialApp.router
  ↓
QPScreen → section_core / section_context / section_connect
  ↓
Public site (Rendering Plane) ←→ space_admin (Control Plane)
```

---

## Quick start — development (no backend needed)

```bash
# 1. Install Flutter 3.27+
# 2. Clone and get dependencies
flutter pub get

# 3. Run in browser
flutter run -d chrome

# The app boots as the 'qspace' tenant automatically.
# Edit assets/client/qspace/overlay.json to change the brand/copy live.
```

That's it. In dev mode, `LocalJsonConfigProvider` loads manifests from bundled assets.
No Postgres, no Redis, no Rust backend required to see the full site including admin panel.

---

## Switching to full stack (Postgres + Redis + Rust)

```bash
# 1. Set environment variables
cp backend/.env.example backend/.env
# Edit backend/.env — fill in DATABASE_URL, JWT_SECRET, REDIS_URL

# 2. Build Flutter web
flutter build web --release --split-debug-info=build/debug-info --obfuscate

# 3. Start everything
docker-compose up --build

# Site:    http://localhost
# API:     http://localhost:8080/health
# Admin:   http://localhost/admin
```

---

## Making QSpace a tenant — how it works

Open `assets/client/qspace/overlay.json`. That file is the entire QSpace brand:
- Deep Violet `#9933FF` as primary
- Barlow + Inter + Niconne typography
- All three screens' worth of marketing copy

Open `lib/interface/app_root.dart`. Find this line:

```dart
const _kTenancyProvider = LocalTenancyProvider('qspace');
```

That string `'qspace'` is all it takes. The engine reads `assets/client/qspace/overlay.json`,
merges it with `assets/suite/saas/manifest.json`, builds a `BrandConfig`, and renders the site.
To add a new tenant: create `assets/client/<new-tenant>/overlay.json`, register the tenant in
`_kConfigProvider`'s tenant-suite map, and change that one string.

---

## Admin panel

Navigate to `/admin` in the browser. In dev mode, `LocalAuthProvider` auto-authenticates
as architect — no login needed.

**Six screens:**
- `/admin/overview` — tenant status, version history
- `/admin/content` — edit all copy by space/screen/section/block
- `/admin/brand` — colors, typography, canvas, identity
- `/admin/assets` — logo and media URLs
- `/admin/features` — feature toggles (waitlist, pricing, etc.)
- `/admin/preview` — live preview of draft, viewport toggle

Every edit is autosaved to draft. Changes don't go live until you click **Publish**.

---

## Project structure

```
lib/
├── canon/           Locked IDs and vocabulary
├── core/
│   ├── style/       7 design system files (your uploaded files)
│   ├── utils/       deep_merge.dart — single merge function
│   └── admin/       Admin data layer (schema, mapper, permissions, validation, diff)
├── shell/           merge_engine.dart + admin_draft_engine.dart
├── infrastructure/  Pluggable adapters (tenancy, config, auth, admin)
├── experience/
│   └── spaces/
│       ├── space_value/    Home / Features / Pricing screens
│       ├── space_admin/    Admin control plane screens
│       ├── space_system/   (Cycle 2)
│       └── space_auxiliary/(Cycle 2)
├── interface/
│   ├── components/  QButton, QCard, QNavBar, QSection, QContainer, QFooter
│   ├── admin/       QAdminShell, QAdminForm, QAdminPreviewPane, QAdminToolbar
│   ├── app_root.dart
│   ├── app_router.dart
│   └── qpages_app.dart
└── main.dart

assets/
├── suite/saas/manifest.json      Suite defaults + full copy fallback
└── client/qspace/overlay.json   QSpace tenant: brand + content + features

backend/
├── src/
│   ├── main.rs          Axum server + routes
│   ├── handlers/        admin, auth, manifest, tenant
│   ├── middleware/       JWT auth + role guard
│   └── models/          Domain types
├── migrations/init.sql  PostgreSQL schema
├── Cargo.toml
├── Dockerfile
└── .env.example
```

---

## Deployment (DigitalOcean)

```bash
# 1. Create a $12/mo Droplet (2vCPU / 2GB RAM)
# 2. Install Docker + Docker Compose
# 3. Clone repo, fill in .env
# 4. Run:
docker-compose up -d --build
# 5. Point your domain DNS to the droplet IP
# 6. Add SSL (certbot or DigitalOcean managed cert)
```

---

## What's next (Cycle 1)

- [ ] Wire SeaORM — replace all DB stubs with real queries
- [ ] `RustJwtAuthProvider` in Flutter — real login flow
- [ ] `RestConfigProvider` in Flutter — manifests from backend, not bundled assets
- [ ] Q-component library completion (QGrid, QImage, QTextField)
- [ ] `space_system` screens (Account, Settings, Billing)
- [ ] SendGrid waitlist email confirmation

---

*The Canon is law. The overlay is the brand. The merge engine is the gatekeeper.*
