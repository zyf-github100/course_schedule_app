import 'package:course_schedule_app/features/import/domain/entities/import_draft.dart';
import 'package:course_schedule_app/features/import/domain/entities/import_file.dart';

abstract class ScheduleParser {
  Future<ImportDraft> parse(ImportFile file);
}
