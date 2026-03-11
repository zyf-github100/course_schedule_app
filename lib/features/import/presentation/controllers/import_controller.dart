import 'package:course_schedule_app/features/import/domain/entities/import_draft.dart';
import 'package:course_schedule_app/features/import/data/parsers/pdf_schedule_parser.dart';
import 'package:course_schedule_app/features/import/domain/entities/import_file.dart';
import 'package:course_schedule_app/features/import/domain/entities/import_source_type.dart';
import 'package:course_schedule_app/features/import/data/parsers/excel_schedule_parser.dart';
import 'package:file_picker/file_picker.dart';

class ImportController {
  final ExcelScheduleParser _excelScheduleParser = ExcelScheduleParser();
  final PdfScheduleParser _pdfScheduleParser = PdfScheduleParser();

  Future<ImportFile?> pickFile(ImportSourceType sourceType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: sourceType.allowedExtensions,
      dialogTitle: '选择${sourceType.label}课表文件',
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;

    return ImportFile(
      path: file.path ?? file.name,
      name: file.name,
      sourceType: sourceType,
      bytes: file.bytes,
    );
  }

  Future<ImportDraft> createDraft(ImportFile file) async {
    if (file.sourceType == ImportSourceType.excel) {
      return _excelScheduleParser.parse(file);
    }

    return _pdfScheduleParser.parse(file);
  }
}
