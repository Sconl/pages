// lib/client/qspace/client_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Client-specific config for QSpace Pages deployment.
//             This is the ONLY file that should change between deployments.
//             Adapter selection, API URL, tenant ID — all here.
// ─────────────────────────────────────────────────────────────────────────────
//
// HOW TO USE FOR A NEW TENANT:
//   1. Duplicate this file or override these values per environment.
//   2. Set kAuthAdapterType to the adapter matching your backend.
//   3. Set kApiBaseUrl to your Rust backend URL (or Firebase project for Firebase adapter).
//   4. Set kDefaultTenantId to the subdomain/tenant slug.
//
// For production: these values should come from build-time --dart-define flags,
// not hardcoded strings. See the comment on each constant.

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// Which auth adapter to wire at startup.
// Change this to AuthAdapterType.firebase to use FirebaseAuthProvider instead.
// Everything else in the app is unaffected by this switch.
const kAuthAdapterType = AuthAdapterType.restJwt;

// ── API ──
// Production: pass via --dart-define=API_BASE_URL=https://api.qspace.co
// Dev: point at your local Rust backend.
const kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000', // local Rust backend
);

// ── Tenancy ──
// The tenant slug for this deployment. In SaaS production this is resolved
// from the subdomain at runtime via SubdomainTenancyProvider. For local
// development and single-tenant builds, this constant is used directly.
const kDefaultTenantId = String.fromEnvironment(
  'TENANT_ID',
  defaultValue: 'qspace-dev', // local dev tenant
);

// ── Firebase (only needed when kAuthAdapterType == AuthAdapterType.firebase) ──
// If you're using the Firebase adapter, initialise Firebase in main.dart with
// your project's GoogleService-Info.plist / google-services.json.
// The FirebaseAuthProvider reads these at runtime — no constants needed here.

// ─────────────────────────────────────────────────────────────────────────────
// AuthAdapterType
// ─────────────────────────────────────────────────────────────────────────────

enum AuthAdapterType {
  restJwt,  // Rust backend — JWT issued by /api/auth/login
  firebase, // Firebase Auth + Firestore user document
}