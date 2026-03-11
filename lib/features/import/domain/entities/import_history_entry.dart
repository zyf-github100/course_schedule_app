import 'package:course_schedule_app/features/import/domain/entities/import_source_type.dart';

class ImportHistoryEntry {
  const ImportHistoryEntry({
    required this.id,
    required this.sourceFileName,
    required this.sourceType,
    required this.semesterName,
    required this.courseCount,
    required this.warningCount,
    required this.importedAt,
  });

  final String id;
  final String sourceFileName;
  final ImportSourceType sourceType;
  final String semesterName;
  final int courseCount;
  final int warningCount;
  final DateTime importedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'sourceFileName': sourceFileName,
      'sourceType': sourceType.name,
      'semesterName': semesterName,
      'courseCount': courseCount,
      'warningCount': warningCount,
      'importedAt': importedAt.toIso8601String(),
    };
  }

  factory ImportHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ImportHistoryEntry(
      id: json['id'] as String,
      sourceFileName: json['sourceFileName'] as String,
      sourceType: ImportSourceType.values.firstWhere(
        (type) => type.name == json['sourceType'],
      ),
      semesterName: json['semesterName'] as String,
      courseCount: json['courseCount'] as int,
      warningCount: json['warningCount'] as int,
      importedAt: DateTime.parse(json['importedAt'] as String),
    );
  }
}
