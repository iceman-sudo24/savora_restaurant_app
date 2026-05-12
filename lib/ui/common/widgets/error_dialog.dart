import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/errors/app_exception.dart';

/// Shows an error dialog with a user-friendly message.
///
/// Extracts the message from [AppException] or displays a generic
/// fallback for unknown errors. Keeps the UI layer clean — it doesn't
/// need to know about Firebase error codes.
void showErrorDialog(BuildContext context, dynamic error) {
  final message = error is AppException
      ? error.message
      : 'An unexpected error occurred. Please try again.';

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(
        Icons.error_outline,
        color: AppColors.error,
        size: 48,
      ),
      title: const Text('Error'),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

/// Shows a success dialog (for confirming actions like booking creation).
void showSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
  VoidCallback? onDismiss,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(
        Icons.check_circle_outline,
        color: AppColors.success,
        size: 48,
      ),
      title: Text(title),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDismiss?.call();
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

/// Shows a confirmation dialog (e.g., cancel booking).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDestructive
              ? TextButton.styleFrom(foregroundColor: AppColors.error)
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}