import 'package:flutter/material.dart';
import 'package:smart_khata/core/theme/app_theme.dart';

/// A centred empty-state widget shown when a list or query returns no data.
///
/// Layout (top-to-bottom, all centred):
///   1. [icon] — large icon, defaults to `Icons.inbox_outlined`.
///   2. [title] — bolded message (required).
///   3. [subtitle] — lighter helper text (optional).
///   4. [action] — optional call-to-action button.
///
/// Example:
/// ```dart
/// EmptyState(
///   title: Text(l10n.emptyState),
///   subtitle: Text('Add your first customer to get started.'),
///   action: FilledButton(
///     onPressed: () => context.push('/customers/new'),
///     child: Text(l10n.btnAdd),
///   ),
/// )
/// ```
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    super.key,
    this.icon,
    this.subtitle,
    this.action,
  });

  /// Icon displayed at the top. Defaults to [Icons.inbox_outlined].
  final IconData? icon;

  /// Primary message — should use [AppLocalizations] string.
  final Widget title;

  /// Optional secondary helper text.
  final Widget? subtitle;

  /// Optional action button (e.g. `FilledButton` or `ElevatedButton`).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(kSpaceXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 72,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: kSpaceM),
            DefaultTextStyle(
              style: theme.textTheme.titleMedium!.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              child: title,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: kSpaceS),
              DefaultTextStyle(
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                child: subtitle!,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: kSpaceL),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
