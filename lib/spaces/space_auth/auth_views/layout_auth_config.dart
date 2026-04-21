// lib/spaces/space_auth/auth_views/layout_auth_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. AuthMode, AuthLayoutVariant, AuthSectionVisibility,
//             AuthLayoutConfig.
//   v2.0.0 — Added social and biometric fields to AuthSectionVisibility.
//             AuthLayoutConfig.forMode() gains showSocial + showBiometric params.
//             Social shown on login + signup. Biometric on login only.
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// AuthMode
// ─────────────────────────────────────────────────────────────────────────────

enum AuthMode { login, signup, reset }

// ─────────────────────────────────────────────────────────────────────────────
// AuthLayoutVariant
// ─────────────────────────────────────────────────────────────────────────────

enum AuthLayoutVariant { stack, split, card }

// ─────────────────────────────────────────────────────────────────────────────
// AuthSectionVisibility
// ─────────────────────────────────────────────────────────────────────────────

class AuthSectionVisibility {
  final bool header;
  final bool roles;
  final bool form;
  final bool help;
  final bool actions;
  final bool social;     // social login button row
  final bool biometric;  // biometric button (login only)
  final bool bottomLink;

  const AuthSectionVisibility({
    this.header     = true,
    this.roles      = false,
    this.form       = true,
    this.help       = true,
    this.actions    = true,
    this.social     = false,
    this.biometric  = false,
    this.bottomLink = true,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// AuthLayoutConfig
// ─────────────────────────────────────────────────────────────────────────────

class AuthLayoutConfig {
  final AuthLayoutVariant  variant;
  final AuthSectionVisibility sections;

  const AuthLayoutConfig({
    this.variant = AuthLayoutVariant.stack,
    required this.sections,
  });

  static AuthLayoutConfig forMode(
    AuthMode mode, {
    AuthLayoutVariant variant     = AuthLayoutVariant.stack,
    bool              showRoles   = false,
    bool              showSocial  = false,
    bool              showBiometric = false,
  }) {
    switch (mode) {
      case AuthMode.login:
        return AuthLayoutConfig(
          variant: variant,
          sections: AuthSectionVisibility(
            header:     true,
            roles:      showRoles,
            form:       true,
            help:       true,
            actions:    true,
            social:     showSocial,
            biometric:  showBiometric, // only on login
            bottomLink: true,
          ),
        );
      case AuthMode.signup:
        return AuthLayoutConfig(
          variant: variant,
          sections: AuthSectionVisibility(
            header:     true,
            roles:      showRoles,
            form:       true,
            help:       false,
            actions:    true,
            social:     showSocial,
            biometric:  false, // never on signup
            bottomLink: true,
          ),
        );
      case AuthMode.reset:
        return AuthLayoutConfig(
          variant: variant,
          sections: AuthSectionVisibility(
            header:     true,
            roles:      false,
            form:       true,
            help:       false,
            actions:    true,
            social:     false, // never on reset
            biometric:  false,
            bottomLink: true,
          ),
        );
    }
  }
}