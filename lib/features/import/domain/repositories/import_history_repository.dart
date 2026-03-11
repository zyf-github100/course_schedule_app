import 'package:course_schedule_app/features/import/domain/entities/import_history_entry.dart';

abstract class ImportHistoryRepository {
  Future<List<ImportHistoryEntry>> loadHistory();

  Future<void> saveHistoryEntry(ImportHistoryEntry entry);
}
