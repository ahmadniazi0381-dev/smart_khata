import 'package:flutter/material.dart';

/// A reusable card widget that wraps [Card] + [ListTile].
///
/// All parameters are optional. Respects RTL layout through
/// [ListTile]'s built-in directionality support.
///
/// Example:
/// ```dart
/// AppCard(
///   title: Text(l10n.customerSaved),
///   subtitle: Text('Balance: ₨ 1,500'),
///   trailing: const Icon(Icons.chevron_right),
///   onTap: () => context.push('/customers/42'),
/// )
/// ```
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding,
    this.child,
  });

  /// Primary text / widget shown in the card header.
  final Widget? title;

  /// Secondary text / widget shown below the title.
  final Widget? subtitle;

  /// Optional leading widget (e.g. an avatar or icon).
  final Widget? leading;

  /// Optional trailing widget (e.g. a chevron or badge).
  final Widget? trailing;

  /// If non-null the entire card is tappable.
  final VoidCallback? onTap;

  /// Override padding inside the card. Defaults to [ListTile]'s own
  /// `contentPadding` which is `EdgeInsetsDirectional.symmetric(horizontal: 16)`.
  final EdgeInsetsDirectional? padding;

  /// Supply a custom [child] to bypass the [ListTile] layout entirely.
  /// When set, [title], [subtitle], [leading], and [trailing] are ignored.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (child != null) {
      content = child!;
    } else {
      content = ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        contentPadding: padding ??
            const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 4),
      );
    }

    if (child != null && onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: content,
      );
    }

    return Card(child: content);
  }
}
