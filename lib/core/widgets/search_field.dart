import 'package:flutter/material.dart';
import 'package:smart_khata/core/theme/app_theme.dart';

/// A search [TextField] with a prefix search icon and a clear (×) button.
///
/// Props:
/// - [controller]  — optional [TextEditingController] for external control.
/// - [onChanged]   — called whenever the text changes.
/// - [onSubmitted] — called when the user submits (presses ↵).
/// - [hintText]    — placeholder string; use `l10n.searchHint`.
/// - [autofocus]   — whether to auto-focus on mount.
///
/// Example:
/// ```dart
/// SearchField(
///   hintText: l10n.searchHint,
///   onChanged: (query) => ref.read(searchProvider.notifier).update(query),
/// )
/// ```
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? hintText;
  final bool autofocus;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller;
  bool _ownsController = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'Search...',
        prefixIcon: const Padding(
          padding: EdgeInsetsDirectional.only(start: kSpaceS, end: kSpaceXS),
          child: Icon(Icons.search, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.textSecondary,
                tooltip: 'Clear',
                onPressed: _clearText,
                splashRadius: 16,
              )
            : null,
      ),
    );
  }
}
