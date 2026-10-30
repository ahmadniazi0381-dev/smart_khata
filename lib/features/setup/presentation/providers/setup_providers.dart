import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/setup_repository.dart';

final setupRepositoryProvider = Provider<SetupRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SetupRepository(db);
});

final shopSettingsStreamProvider = StreamProvider<ShopSetting?>((ref) {
  final repo = ref.watch(setupRepositoryProvider);
  return repo.watchSettings();
});
