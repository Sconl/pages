# QSpace Pages

QSpace Pages is a multi-tenant business platform for building, managing, and scaling digital presence from a single unified system.

It is not just a website builder.

It is a structured digital infrastructure for modern businesses.

---

## Vision

QSpace Pages exists to give businesses full control over their digital presence — without fragmented tools, expensive custom development, or platform lock-in.

It combines:

* Structured website systems
* Client dashboards
* Analytics
* Messaging
* Billing
* Multi-tenant architecture

Built for clarity. Built for scale. Built for the future.

---

## Core Capabilities

* Multi-tenant SaaS architecture
* Signature Design Suites (structured layout systems)
* Real-time content management
* Integrated analytics
* Built-in messaging
* Kenya-first billing (M-Pesa + cards)
* Role-based access control
* Modular backend architecture (future OpenArq extraction)

---

## Who It’s For

QSpace Pages is designed for:

* Growing businesses that need more than a static website
* Agencies managing multiple client sites
* Entrepreneurs who want full ownership of their digital infrastructure
* Developers who prefer structured systems over plugin-heavy stacks

---

## Product Philosophy

QSpace Pages is built on the belief that businesses should not depend on fragmented tools to operate online.

It prioritizes:

* Structural clarity over feature bloat
* Multi-tenant correctness over shortcuts
* Clean modular boundaries
* Long-term infrastructure thinking

This is not a quick template system.
This is a foundation.

---

## Architecture Overview

Each client operates within an isolated tenant environment.

Each tenant includes:

* Public website
* Admin dashboard
* Content management
* Analytics
* Messaging
* Billing integration

The system is designed for future modular extraction into standalone backend engines.

---

## Tech Stack

Frontend:

* Flutter (Web-first UI)

Backend:

* Rust (modular architecture)

Infrastructure:

* PostgreSQL
* Docker
* Multi-tenant architecture from day one

---

## Repository Structure

```
pages/
├── frontend/              # Flutter application
├── backend/               # Rust API server
├── infrastructure/        # Deployment & environment configs
├── docs/                  # Architecture & API documentation
├── LICENSE
├── README.md
```

---

## Development Setup

### 1. Clone the repository

```
git clone https://github.com/q-space/pages.git
cd pages
```

### 2. Backend

```
cd backend
cargo run
```

### 3. Frontend

```
cd frontend
flutter run -d chrome
```

Full setup documentation will evolve as the project matures.

---

## Roadmap

QSpace Pages is currently in early architectural development.

Upcoming milestones include:

* Multi-tenant foundation
* Content engine core
* Dashboard MVP
* Billing integration
* Initial public release

See ROADMAP.md for detailed direction.

---

## Contributing

Thoughtful contributions aligned with the long-term architecture and vision are welcome.

Please review CONTRIBUTING.md before submitting pull requests.

---

## Security

If you discover a vulnerability, please follow the reporting process defined in SECURITY.md.

---

## License

This project is licensed under the GNU Affero General Public License v3.0 (AGPL-3.0).

See the LICENSE file for full details.

---

© 2026 SCONL
