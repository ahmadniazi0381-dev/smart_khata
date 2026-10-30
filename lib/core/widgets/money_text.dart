import 'package:flutter/material.dart';
import 'package:smart_khata/core/theme/app_theme.dart';
import 'package:smart_khata/core/utils/money.dart';

/// Displays a monetary amount stored as **integer paisa** (100 paisa = 1 rupee).
///
/// • [amountPaisa] — the value in paisa.
/// • [style] — optional [TextStyle] override; theme body-large is the default.
/// • [isPositive] — when `true` the text is rendered in [AppColors.success].
/// • [isNegative] — when `true` the text is rendered in [AppColors.error].
///
/// If both [isPositive] and [isNegative] are false, the text inherits the
/// ambient text colour.
///
/// Formatting is delegated to [Money.format] from `core/utils/money.dart`.
class MoneyText extends StatelessWidget {
  const MoneyText({
    required this.amountPaisa,
    super.key,
    this.style,
    this.isPositive = false,
    this.isNegative = false,
  }) : assert(
          !(isPositive && isNegative),
          'isPositive and isNegative cannot both be true.',
        );

  final int amountPaisa;
  final TextStyle? style;
  final bool isPositive;
  final bool isNegative;

  Color? _resolveColor() {
    if (isPositive) return AppColors.success;
    if (isNegative) return AppColors.error;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        style ?? Theme.of(context).textTheme.bodyLarge ?? const TextStyle();

    final effectiveStyle = _resolveColor() != null
        ? baseStyle.copyWith(color: _resolveColor())
        : baseStyle;

    return Text(
      Money.format(amountPaisa),
      style: effectiveStyle,
    );
  }
}
