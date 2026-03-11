import 'dart:typed_data';

import 'package:course_schedule_app/features/import/domain/entities/import_source_type.dart';

class ImportFile {
  const ImportFile({
    required this.path,
    required this.name,
    required this.sourceType,
    this.bytes,
  });

  final String path;
  final String name;
  final ImportSourceType sourceType;
  final Uint8List? bytes;
}
