# Smart Khata — Rules for Every AI Agent

- Flutter stable, Dart null-safe, Android only. Offline-first: no network calls, no analytics, no accounts.
- Architecture: features/<name>/{data,domain,presentation}. Widgets contain no business logic and no SQL.
- Money: int paisa only. Quantities: int milli-units only. Use core/utils/money.dart and qty.dart. Never double.
- Every multi-table write goes through a service inside db.transaction.
- Never DELETE financial rows (sales, payments, ledger, stock movements). Cancel with reversal rows.
- Sale items store name, unit, unit price and cost price snapshots at sale time.
- No hardcoded user-facing text: use AppLocalizations. Support RTL (EdgeInsetsDirectional, AlignmentDirectional).
- Colors and spacing come only from core/theme.
- Riverpod without code generation. Drift is the only codegen.
- After each task run: dart format ., flutter analyze (zero issues), flutter test.
- Do not add packages and do not edit files outside the task file list without asking.
- Small commits, for example: feat(sales): add cart screen
