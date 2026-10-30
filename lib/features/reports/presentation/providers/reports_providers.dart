import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../data/reports_repository.dart';
import '../../domain/models/report_models.dart';

enum ReportPeriod {
  today,
  thisWeek,
  thisMonth,
  allTime,
}

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ReportsRepository(db);
});

final dashboardSummaryProvider =
    FutureProvider.autoDispose<DashboardSummary>((ref) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.getDashboardSummary();
});

final reportPeriodProvider =
    StateProvider<ReportPeriod>((ref) => ReportPeriod.thisMonth);

final salesReportProvider =
    FutureProvider.autoDispose<SalesReport>((ref) async {
  final repo = ref.watch(reportsRepositoryProvider);
  final period = ref.watch(reportPeriodProvider);

  final now = DateTime.now();
  int fromMs;
  final toMs = AppDateUtils.endOfToday();

  switch (period) {
    case ReportPeriod.today:
      fromMs = AppDateUtils.startOfToday();
      break;
    case ReportPeriod.thisWeek:
      // Start of week (Monday)
      final weekday = now.weekday; // 1 = Monday, 7 = Sunday
      final startOfWeek =
          DateTime(now.year, now.month, now.day - (weekday - 1));
      fromMs = startOfWeek.millisecondsSinceEpoch;
      break;
    case ReportPeriod.thisMonth:
      fromMs = DateTime(now.year, now.month, 1).millisecondsSinceEpoch;
      break;
    case ReportPeriod.allTime:
      fromMs = 0;
      break;
  }

  return repo.getSalesReport(fromDateMs: fromMs, toDateMs: toMs);
});
