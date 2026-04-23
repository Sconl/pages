// lib/core/auth/auth_session.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. QAuthSession + QRole. Zero framework deps.
//             Roles match canvas admin permissions model exactly.
// ─────────────────────────────────────────────────────────────────────────────
//
// QAuthSession is the single normalized auth truth across the app.
// Every adapter produces one of these — no Firebase User, no JWT map,
// leaks out of the infrastructure layer.
//
// The role hierarchy matters: index order is the permission level.
// Always compare with >= not ==.

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Role labels (these match the Rust backend JWT claim values exactly) ──
const kRoleUser        = 'user';
const kRoleClientAdmin = 'clientAdmin';
const kRoleDeveloper   = 'developer';
const kRoleArchitect   = 'architect';

// ─────────────────────────────────────────────────────────────────────────────
// QRole
// ─────────────────────────────────────────────────────────────────────────────

// Index order = permission level. guest < user < clientAdmin < developer < architect.
// Always check with role.index >= QRole.someRole.index — never with ==.
enum QRole {
  guest,       // unauthenticated (used for routing logic only)
  user,        // authenticated, no admin rights
  clientAdmin, // can edit brand/copy/features for their tenant
  developer,   // structural mappings, advanced fields, rollback
  architect,   // schema-level rules, canonical defaults, all permissions
}

extension QRoleX on QRole {
  static QRole fromString(String? value) {
    switch (value) {
      case kRoleClientAdmin: return QRole.clientAdmin;
      case kRoleDeveloper:   return QRole.developer;
      case kRoleArchitect:   return QRole.architect;
      case kRoleUser:        return QRole.user;
      default:               return QRole.user;
    }
  }

  String get value {
    switch (this) {
      case QRole.guest:       return 'guest';
      case QRole.user:        return kRoleUser;
      case QRole.clientAdmin: return kRoleClientAdmin;
      case QRole.developer:   return kRoleDeveloper;
      case QRole.architect:   return kRoleArchitect;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QAuthSession
// ─────────────────────────────────────────────────────────────────────────────

class QAuthSession {
  final String  userId;
  final String  email;
  final String  displayName;
  final String  tenantId;    // every session is scoped to a tenant
  final QRole   role;
  final DateTime? expiresAt; // null if adapter doesn't expose expiry
  // Token is opaque — only the adapter should ever read it directly.
  // Everything else calls AuthPort.getToken().
  final String? _token;

  const QAuthSession({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.tenantId,
    required this.role,
    this.expiresAt,
    String? token,
  }) : _token = token;

  bool get isAdmin => role.index >= QRole.clientAdmin.index;
  bool get isDeveloper => role.index >= QRole.developer.index;
  bool get isArchitect => role == QRole.architect;

  // Only the infrastructure layer should call this.
  // Everything else uses AuthPort.getToken().
  String? get rawToken => _token;

  QAuthSession copyWith({
    String?   displayName,
    QRole?    role,
    String?   tenantId,
    DateTime? expiresAt,
    String?   token,
  }) => QAuthSession(
    userId:      userId,
    email:       email,
    displayName: displayName ?? this.displayName,
    tenantId:    tenantId    ?? this.tenantId,
    role:        role        ?? this.role,
    expiresAt:   expiresAt   ?? this.expiresAt,
    token:       token       ?? _token,
  );

  @override
  String toString() =>
      'QAuthSession(uid=$userId, tenant=$tenantId, role=${role.value})';
}