import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/database/app_database.dart';

class BackupService {
  final AppDatabase _db;

  BackupService(this._db);

  /// Find the actual SQLite database file on disk.
  Future<File?> getDatabaseFile() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final candidate1 = File(p.join(docsDir.path, 'smart_khata.sqlite'));
    if (await candidate1.exists()) return candidate1;

    final candidate2 = File(p.join(docsDir.path, 'smart_khata.db'));
    if (await candidate2.exists()) return candidate2;

    final supportDir = await getApplicationSupportDirectory();
    final candidate3 = File(p.join(supportDir.path, 'smart_khata.sqlite'));
    if (await candidate3.exists()) return candidate3;

    final candidate4 = File(p.join(supportDir.path, 'smart_khata.db'));
    if (await candidate4.exists()) return candidate4;

    return null;
  }

  /// Create an offline backup file and trigger OS Share / Save dialog.
  Future<String> createBackupAndShare() async {
    // 1. Checkpoint WAL to flush all transactions to the main file
    await _db.customStatement('PRAGMA wal_checkpoint(FULL);');

    final dbFile = await getDatabaseFile();
    if (dbFile == null) {
      throw Exception('Database file not found on device.');
    }

    // 2. Create export copy in temporary directory with timestamp
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final backupFileName = 'smart_khata_backup_$timestamp.db';
    final backupPath = p.join(tempDir.path, backupFileName);

    await dbFile.copy(backupPath);

    // 3. Share via OS Share dialog
    await Share.shareXFiles(
      [XFile(backupPath, name: backupFileName)],
      subject: 'Smart Khata Backup ($timestamp)',
    );

    return backupPath;
  }

  /// Pick a backup file and restore the SQLite database.
  Future<bool> pickAndRestoreDatabase() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return false;
    final pickedPath = result.files.first.path;
    if (pickedPath == null) return false;

    final pickedFile = File(pickedPath);
    if (!await pickedFile.exists()) return false;

    // Validate SQLite header: first 16 bytes must equal "SQLite format 3\000"
    final headerBytes = await pickedFile.openRead(0, 16).first;
    final sqliteHeader = 'SQLite format 3\x00'.codeUnits;
    if (headerBytes.length < 16) return false;
    for (int i = 0; i < 16; i++) {
      if (headerBytes[i] != sqliteHeader[i]) return false;
    }

    // Flush & close checkpoint
    await _db.customStatement('PRAGMA wal_checkpoint(FULL);');

    final dbFile = await getDatabaseFile();
    final targetPath = dbFile?.path ??
        p.join((await getApplicationDocumentsDirectory()).path,
            'smart_khata.sqlite');

    // Remove WAL & SHM auxiliary files if present
    final walFile = File('$targetPath-wal');
    if (await walFile.exists()) await walFile.delete();

    final shmFile = File('$targetPath-shm');
    if (await shmFile.exists()) await shmFile.delete();

    // Copy picked file over database
    await pickedFile.copy(targetPath);

    return true;
  }
}
