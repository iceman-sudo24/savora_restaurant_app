/// Custom application exceptions for consistent error handling.
///
/// Instead of catching raw Firebase exceptions and showing cryptic error codes
/// to users, we map them to user-friendly messages at the repository layer.
/// The UI layer only needs to display [message] — no Firebase knowledge required.
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';

  // ── Auth Exceptions ──
  factory AppException.invalidCredentials() => const AppException(
        message: 'Invalid email or password. Please try again.',
        code: 'invalid-credentials',
      );

  factory AppException.emailAlreadyInUse() => const AppException(
        message: 'This email is already registered. Try logging in instead.',
        code: 'email-already-in-use',
      );

  factory AppException.weakPassword() => const AppException(
        message: 'Password is too weak. Use at least 6 characters.',
        code: 'weak-password',
      );

  factory AppException.userNotFound() => const AppException(
        message: 'No account found with this email.',
        code: 'user-not-found',
      );

  factory AppException.userDisabled() => const AppException(
        message: 'This account has been disabled. Contact support.',
        code: 'user-disabled',
      );

  factory AppException.tooManyRequests() => const AppException(
        message: 'Too many attempts. Please wait a moment and try again.',
        code: 'too-many-requests',
      );

  // ── Firestore Exceptions ──
  factory AppException.documentNotFound(String collection) => AppException(
        message: 'Record not found in $collection.',
        code: 'document-not-found',
      );

  factory AppException.permissionDenied() => const AppException(
        message: 'You don\'t have permission to perform this action.',
        code: 'permission-denied',
      );

  factory AppException.networkError() => const AppException(
        message: 'Network error. Check your internet connection and try again.',
        code: 'network-error',
      );

  // ── Generic ──
  factory AppException.unknown(dynamic error) => AppException(
        message: 'An unexpected error occurred. Please try again.',
        code: 'unknown',
        originalError: error,
      );
}