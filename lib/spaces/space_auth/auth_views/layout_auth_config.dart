// lib/spaces/space_auth/auth_views/layout_auth_config.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. AuthMode, AuthLayoutVariant, AuthSectionVisibility,
//             AuthLayoutConfig. Pure config — no imports, no UI, no providers.
// ─────────────────────────────────────────────────────────────────────────────
//
// What lives here: existence and arrangement intent — what should be present.
// What does NOT live here: how anything is drawn, any auth logic, any state.

// ─────────────────────────────────────────────────────────────────────────────
// AuthMode — which auth flow is active
// ─────────────────────────────────────────────────────────────────────────────

enum AuthMode { login, signup, reset }

// ─────────────────────────────────────────────────────────────────────────────
// AuthLayoutVariant — which template to render
// ─────────────────────────────────────────────────────────────────────────────

enum AuthLayoutVariant {
  stack,  // single column — default
  split,  // two-panel (branding + form)
  card,   // centered card container
}

// ─────────────────────────────────────────────────────────────────────────────
// AuthSectionVisibility — which sections the template should include
// ─────────────────────────────────────────────────────────────────────────────

class AuthSectionVisibility {
  final bool header;     // logo + heading + subheading
  final bool roles;      // user class / role toggle
  final bool form;       // credential input fields
  final bool help;       // forgot password link + error message
  final bool actions;    // submit button
  final bool bottomLink; // signup / login / back link

  const AuthSectionVisibility({
    this.header     = true,
    this.roles      = false,
    this.form       = true,
    this.help       = true,
    this.actions    = true,
    this.bottomLink = true,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// AuthLayoutConfig — the full config for one auth screen render
// ─────────────────────────────────────────────────────────────────────────────

class AuthLayoutConfig {
  final AuthLayoutVariant variant;
  final AuthSectionVisibility sections;

  const AuthLayoutConfig({
    this.variant = AuthLayoutVariant.stack,
    required this.sections,
  });

  // Sensible defaults per mode. ShellAuthRoot calls this.
  // showRoles is driven by QAuthConfig.isToggleVisible, not hardcoded here.
  static AuthLayoutConfig forMode(
    AuthMode mode, {
    AuthLayoutVariant variant = AuthLayoutVariant.stack,
    bool showRoles = false,
  }) {
    switch (mode) {
      case AuthMode.login:
        return AuthLayoutConfig(
          variant:  variant,
          sections: AuthSectionVisibility(
            header:     true,
            roles:      showRoles,
            form:       true,
            help:       true,   // shows forgot password + errors
            actions:    true,
            bottomLink: true,   // sign up link
          ),
        );
      case AuthMode.signup:
        return AuthLayoutConfig(
          variant:  variant,
          sections: AuthSectionVisibility(
            header:     true,
            roles:      showRoles,
            form:       true,
            help:       false,  // no forgot password on signup
            actions:    true,
            bottomLink: true,   // log in link
          ),
        );
      case AuthMode.reset:
        return AuthLayoutConfig(
          variant:  variant,
          sections: AuthSectionVisibility(
            header:     true,
            roles:      false,
            form:       true,
            help:       false,
            actions:    true,
            bottomLink: true,   // back to login link
          ),
        );
    }
  }
}