import 'package:course_schedule_app/features/import/domain/entities/import_source_type.dart';
import 'package:course_schedule_app/features/import/domain/entities/parsed_course.dart';
import 'package:course_schedule_app/features/settings/domain/entities/section_time.dart';

class ImportDraft {
  const ImportDraft({
    required this.sourceFilePath,
    required this.sourceFileName,
    required this.sourceType,
    required this.parsedCourses,
    this.rawText,
    this.warnings = const <String>[],
    this.suggestedSectionTimes = const <SectionTime>[],
  });

  final String sourceFilePath;
  final String sourceFileName;
  final ImportSourceType sourceType;
  final String? rawText;
  final List<ParsedCourse> parsedCourses;
  final List<String> warnings;
  final List<SectionTime> suggestedSectionTimes;
}
