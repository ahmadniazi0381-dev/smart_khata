import 'package:flutter/material.dart';
import 'package:smart_khata/core/theme/app_theme.dart';

/// Shows a confirmation [AlertDialog] and returns `true` when the user
/// confirms, or `false` / `null` (treated as false) when they cancel or
/// dismiss.
///
/// Parameters:
/// - [title]       — Dialog title text.
/// - [message]     — Body message explaining the action.
/// - [confirmText] — Label for the confirm button (e.g. `l10n.btnDelete`).
/// - [cancelText]  — Label for the cancel button; defaults to `l10n.btnCancel`.
///   Pass an explicit value if the ambient [AppLocalizations] is not available.
/// - [isDangerous] — When `true` the confirm button is styled in
///   [AppColors.error] to indicate a destructive action.
///
/// Example:
/// ```dart
/// final confirmed = await showConfirmDialog(
///   context,
///   title: l10n.confirmDelete,
///   message: 'Customer Ali Hassan will be removed.',
///   confirmText: l10n.btnDelete,
///   isDangerous: true,
/// );
/// if (confirmed) { /* proceed */ }
/// ```
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmText,
  String cancelText = 'Cancel',
  bool isDangerous = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => _ConfirmDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDangerous: isDangerous,
    ),
  );
  return result ?? false;
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.isDangerous,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDangerous;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confirmColor =
        isDangerous ? AppColors.error : theme.colorScheme.primary;

    return AlertDialog(
      title: Text(
        title,
        style: theme.textTheme.titleLarge,
      ),
      content: Text(
        message,
        style: theme.textTheme.bodyMedium,
      ),
      actionsPadding: const EdgeInsetsDirectional.fromSTEB(
        kSpaceS,
        0,
        kSpaceM,
        kSpaceM,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        const SizedBox(width: kSpaceXS),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: confirmColor,
            minimumSize: Size.zero,
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: kSpaceM,
              vertical: kSpaceS + 2,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
