// lib/experience/spaces/space_auth/model/auth_form_state.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// CHANGELOG
// ─────────────────────────────────────────────────────────────────────────────
//   v1.0.0 — Initial. Pure data models for auth form state. No framework deps.
//             Immutable. Copyable. Tested in isolation.
// ─────────────────────────────────────────────────────────────────────────────
//
// These exist so the Riverpod notifiers have typed state to work with,
// and so the screens can pass structured data instead of raw strings.

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG BLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── Validation limits ──
const kDisplayNameMinLength = 2;
const kDisplayNameMaxLength = 50;
const kPasswordMinLength    = 8;

// ─────────────────────────────────────────────────────────────────────────────
// LoginFormState
// ─────────────────────────────────────────────────────────────────────────────

class LoginFormState {
  final String  email;
  final String  password;
  final bool    isLoading;
  final String? errorMessage;

  const LoginFormState({
    this.email        = '',
    this.password     = '',
    this.isLoading    = false,
    this.errorMessage,
  });

  bool get isValid =>
      email.trim().isNotEmpty && password.isNotEmpty;

  LoginFormState copyWith({
    String?  email,
    String?  password,
    bool?    isLoading,
    String?  errorMessage,
    // Passing null explicitly clears the error.
    bool clearError = false,
  }) => LoginFormState(
    email:        email        ?? this.email,
    password:     password     ?? this.password,
    isLoading:    isLoading    ?? this.isLoading,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SignupFormState
// ─────────────────────────────────────────────────────────────────────────────

class SignupFormState {
  final String  displayName;
  final String  email;
  final String  password;
  final String  confirmPassword;
  final bool    isLoading;
  final String? errorMessage;

  const SignupFormState({
    this.displayName     = '',
    this.email           = '',
    this.password        = '',
    this.confirmPassword = '',
    this.isLoading       = false,
    this.errorMessage,
  });

  bool get passwordsMatch => password == confirmPassword;
  bool get isValid =>
      displayName.trim().length >= kDisplayNameMinLength &&
      email.trim().isNotEmpty &&
      password.length >= kPasswordMinLength &&
      passwordsMatch;

  SignupFormState copyWith({
    String? displayName,
    String? email,
    String? password,
    String? confirmPassword,
    bool?   isLoading,
    String? errorMessage,
    bool    clearError = false,
  }) => SignupFormState(
    displayName:     displayName     ?? this.displayName,
    email:           email           ?? this.email,
    password:        password        ?? this.password,
    confirmPassword: confirmPassword ?? this.confirmPassword,
    isLoading:       isLoading       ?? this.isLoading,
    errorMessage:    clearError ? null : (errorMessage ?? this.errorMessage),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ResetFormState
// ─────────────────────────────────────────────────────────────────────────────

class ResetFormState {
  final String  email;
  final bool    isLoading;
  final String? errorMessage;
  final bool    emailSent;

  const ResetFormState({
    this.email        = '',
    this.isLoading    = false,
    this.errorMessage,
    this.emailSent    = false,
  });

  ResetFormState copyWith({
    String? email,
    bool?   isLoading,
    String? errorMessage,
    bool?   emailSent,
    bool    clearError = false,
  }) => ResetFormState(
    email:        email        ?? this.email,
    isLoading:    isLoading    ?? this.isLoading,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    emailSent:    emailSent    ?? this.emailSent,
  );
}