# Contributing to QSpace Pages

Thank you for your interest in contributing to QSpace Pages.

This project is built with long-term infrastructure thinking. Contributions are welcome, but they must align with architectural clarity, multi-tenant correctness, and system integrity.

---

## Before You Start

1. Read the README.md fully.
2. Review ROADMAP.md to understand direction.
3. Check existing issues before opening a new one.

If your proposal significantly changes architecture, open a discussion issue before submitting a pull request.

---

## Development Principles

QSpace Pages prioritizes:

* Structural clarity over feature bloat
* Explicit multi-tenant isolation
* Modular backend boundaries
* Clean, readable code
* Long-term maintainability over shortcuts

If a contribution increases complexity without clear architectural value, it may not be accepted.

---

## Project Structure

```
pages/
├── frontend/      # Flutter application
├── backend/       # Rust API server
├── infrastructure/
├── docs/
```

Contributions must respect this structure.

---

## Branching Strategy

* `main` is always production-safe.
* Create feature branches from `main`.

Branch naming convention:

```
feature/<short-description>
fix/<short-description>
refactor/<short-description>
```

Examples:

```
feature/content-editor
fix/tenant-isolation
refactor/auth-module
```

---

## Commit Message Convention

We follow Conventional Commits:

```
type(scope): short description
```

Types:

* feat
* fix
* docs
* chore
* refactor
* build
* test
* ci

Examples:

```
feat(content): add section editing endpoint
fix(auth): correct token expiration logic
docs(api): update tenant schema
```

Keep messages concise and descriptive.

---

## Pull Request Guidelines

Every pull request must:

1. Explain what problem it solves
2. Explain why the approach was chosen
3. Avoid unrelated changes
4. Pass compilation and lint checks

Large architectural changes must be discussed before implementation.

---

## Code Style Expectations

### Rust

* Follow idiomatic Rust patterns
* Keep modules small and focused
* Avoid unnecessary abstractions

### Flutter

* Use feature-based folder structure
* Keep widgets modular and composable
* Avoid business logic inside UI layers

---

## Security Considerations

* Never commit secrets
* Never expose tenant data across boundaries
* Validate all external inputs

If you discover a security issue, follow SECURITY.md instead of opening a public issue.

---

## Contributor Conduct

All contributors are expected to follow CODE_OF_CONDUCT.md.

Professionalism and clarity are mandatory.

---

## Licensing

By contributing, you agree that your contributions will be licensed under the same license as the project (AGPL-3.0).

---

Thank you for helping build long-term digital infrastructure.

© 2026 SCONL
