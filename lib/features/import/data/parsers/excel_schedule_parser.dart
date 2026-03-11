import 'package:course_schedule_app/features/import/domain/entities/import_draft.dart';
import 'package:course_schedule_app/features/import/domain/entities/import_file.dart';
import 'package:course_schedule_app/features/import/domain/entities/import_source_type.dart';
import 'package:course_schedule_app/features/import/domain/entities/parsed_course.dart';
import 'package:course_schedule_app/features/import/domain/services/schedule_parser.dart';
import 'package:excel/excel.dart';

class ExcelScheduleParser implements ScheduleParser {
  @override
  Future<ImportDraft> parse(ImportFile file) async {
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw const FormatException('无法读取 Excel 文件内容。');
    }

    final excel = Excel.decodeBytes(bytes);
    final targetSheet = _findTargetSheet(excel);
    final result = _parseSheet(targetSheet.key, targetSheet.value);

    if (result.courses.isEmpty) {
      throw const FormatException('未在 Excel 中识别到课程，请确认表头包含“周一/星期一”等列名。');
    }

    return ImportDraft(
      sourceFilePath: file.path,
      sourceFileName: file.name,
      sourceType: ImportSourceType.excel,
      rawText: result.rawText,
      parsedCourses: result.courses,
      warnings: result.warnings,
    );
  }

  MapEntry<String, Sheet> _findTargetSheet(Excel excel) {
    for (final entry in excel.tables.entries) {
      final header = _detectHeader(entry.value);
      if (header != null) {
        return entry;
      }
    }

    throw const FormatException('没有找到包含星期表头的工作表。');
  }

  _SheetParseResult _parseSheet(String sheetName, Sheet sheet) {
    final header = _detectHeader(sheet);
    if (header == null) {
      throw const FormatException('未识别到星期列。');
    }

    final sectionRows = _detectSectionRows(sheet, header);
    if (sectionRows.isEmpty) {
      throw const FormatException('未识别到节次行，请确认左侧列包含“1-2节”之类的标记。');
    }

    final spanMap = _buildSpanMap(sheet.spannedItems);
    final warnings = <String>['已按工作表“$sheetName”解析规整课表。'];
    final courses = <ParsedCourse>[];
    final rawChunks = <String>[];

    for (final rowEntry in sectionRows.entries) {
      final rowIndex = rowEntry.key;
      final section = rowEntry.value;
      final row = sheet.row(rowIndex);

      for (final dayEntry in header.weekdayColumns.entries) {
        final weekday = dayEntry.key;
        final columnIndex = dayEntry.value;
        final cell = columnIndex < row.length ? row[columnIndex] : null;
        final text = _cellText(cell);
        if (text == null) {
          continue;
        }

        rawChunks.add(text);
        final span = spanMap['$rowIndex-$columnIndex'];
        final endRow = span?.endRow ?? rowIndex;
        final mergedSection = sectionRows[endRow];
        final parsed = _parseCourseText(text);
        final course = ParsedCourse(
          name: parsed.name,
          teacher: parsed.teacher,
          location: parsed.location,
          weekday: weekday,
          startSection: section.start,
          endSection: mergedSection?.end ?? section.end,
          weeks: parsed.weeks,
          note: parsed.note,
        );
        courses.add(course);

        if (parsed.weeks.isEmpty) {
          warnings.add('课程“${parsed.name}”未识别到周数，需在确认页补充。');
        }
      }
    }

    return _SheetParseResult(
      rawText: rawChunks.join('\n\n'),
      courses: courses,
      warnings: warnings.toSet().toList(),
    );
  }

  _HeaderInfo? _detectHeader(Sheet sheet) {
    _HeaderInfo? bestMatch;

    for (var rowIndex = 0; rowIndex < sheet.maxRows; rowIndex++) {
      final row = sheet.row(rowIndex);
      final weekdayColumns = <int, int>{};

      for (var columnIndex = 0; columnIndex < row.length; columnIndex++) {
        final weekday = _matchWeekday(_cellText(row[columnIndex]));
        if (weekday != null) {
          weekdayColumns[weekday] = columnIndex;
        }
      }

      if (weekdayColumns.length >= 3) {
        final candidate = _HeaderInfo(
          rowIndex: rowIndex,
          weekdayColumns: weekdayColumns,
        );

        if (bestMatch == null ||
            candidate.weekdayColumns.length > bestMatch.weekdayColumns.length) {
          bestMatch = candidate;
        }
      }
    }

    return bestMatch;
  }

  Map<int, _SectionRange> _detectSectionRows(Sheet sheet, _HeaderInfo header) {
    final firstWeekdayColumn = header.weekdayColumns.values.reduce(
      (left, right) => left < right ? left : right,
    );
    final sectionColumnCandidates = <int>[
      for (var index = 0; index < firstWeekdayColumn; index++) index,
    ].reversed;
    final sectionRows = <int, _SectionRange>{};

    for (
      var rowIndex = header.rowIndex + 1;
      rowIndex < sheet.maxRows;
      rowIndex++
    ) {
      final row = sheet.row(rowIndex);
      for (final columnIndex in sectionColumnCandidates) {
        if (columnIndex >= row.length) {
          continue;
        }

        final section = _parseSectionLabel(_cellText(row[columnIndex]));
        if (section != null) {
          sectionRows[rowIndex] = section;
          break;
        }
      }
    }

    return sectionRows;
  }

  Map<String, _MergedSpan> _buildSpanMap(List<String> spannedItems) {
    final spanMap = <String, _MergedSpan>{};

    for (final item in spannedItems) {
      final parts = item.split(':');
      if (parts.length != 2) {
        continue;
      }

      final start = CellIndex.indexByString(parts.first);
      final end = CellIndex.indexByString(parts.last);
      spanMap['${start.rowIndex}-${start.columnIndex}'] = _MergedSpan(
        endRow: end.rowIndex,
      );
    }

    return spanMap;
  }

  _SectionRange? _parseSectionLabel(String? input) {
    if (input == null || input.isEmpty) {
      return null;
    }

    final normalized = input.replaceAll(RegExp(r'\s+'), '');
    final rangeMatch =
        RegExp(r'第?(\d{1,2})\s*[-~至]\s*(\d{1,2})节?').firstMatch(normalized) ??
        RegExp(r'^(\d{1,2})\s*[-~至]\s*(\d{1,2})$').firstMatch(normalized);
    if (rangeMatch != null) {
      final start = int.tryParse(rangeMatch.group(1)!);
      final end = int.tryParse(rangeMatch.group(2)!);
      if (start != null && end != null) {
        return _SectionRange(start: start, end: end);
      }
    }

    final singleMatch =
        RegExp(r'第?(\d{1,2})节?').firstMatch(normalized) ??
        RegExp(r'^(\d{1,2})$').firstMatch(normalized);
    if (singleMatch != null) {
      final section = int.tryParse(singleMatch.group(1)!);
      if (section != null) {
        return _SectionRange(start: section, end: section);
      }
    }

    return null;
  }

  _ParsedCourseText _parseCourseText(String rawText) {
    final normalizedText = rawText.replaceAll('\r\n', '\n').trim();
    final lines = normalizedText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return const _ParsedCourseText(name: '未命名课程');
    }

    final weeks = _extractWeeks(normalizedText);
    final filteredLines = lines
        .where((line) => _extractWeeks(line).isEmpty)
        .toList();
    final contentLines = filteredLines.isEmpty ? lines : filteredLines;

    final name = contentLines.first;
    String? teacher;
    String? location;
    final notes = <String>[];

    for (final line in contentLines.skip(1)) {
      if (teacher == null && _looksLikeTeacher(line)) {
        teacher = _sanitizeTeacher(line);
        continue;
      }

      if (location == null && _looksLikeLocation(line)) {
        location = line;
        continue;
      }

      notes.add(line);
    }

    if (teacher == null) {
      for (final line in notes.toList()) {
        if (_looksLikeTeacher(line)) {
          teacher = _sanitizeTeacher(line);
          notes.remove(line);
          break;
        }
      }
    }

    if (location == null) {
      for (final line in notes.toList()) {
        if (_looksLikeLocation(line)) {
          location = line;
          notes.remove(line);
          break;
        }
      }
    }

    return _ParsedCourseText(
      name: name,
      teacher: teacher,
      location: location,
      weeks: weeks,
      note: notes.isEmpty ? null : notes.join(' / '),
    );
  }

  List<int> _extractWeeks(String input) {
    final normalized = input
        .replaceAll('（', '(')
        .replaceAll('）', ')')
        .replaceAll('，', ',')
        .replaceAll('、', ',')
        .replaceAll('至', '-')
        .replaceAll('~', '-')
        .replaceAll('—', '-')
        .replaceAll('–', '-');

    final segmentPattern = RegExp(
      r'(?:第)?\d{1,2}(?:\s*-\s*\d{1,2})?(?:\s*,\s*\d{1,2}(?:\s*-\s*\d{1,2})?)*\s*周(?:\s*\((单|双)\))?(?:\s*[单双]周?)?',
    );
    final weeks = <int>{};

    for (final match in segmentPattern.allMatches(normalized)) {
      final segment = match.group(0)!;
      final isOdd = segment.contains('单');
      final isEven = segment.contains('双');
      final numbersOnly = segment
          .replaceAll('第', '')
          .replaceAll(RegExp(r'周|\(|\)|单|双'), '')
          .trim();

      for (final part in numbersOnly.split(',')) {
        final piece = part.trim();
        if (piece.isEmpty) {
          continue;
        }

        if (piece.contains('-')) {
          final range = piece
              .split('-')
              .map((value) => int.tryParse(value.trim()))
              .toList();
          if (range.length != 2 || range[0] == null || range[1] == null) {
            continue;
          }

          for (var week = range[0]!; week <= range[1]!; week++) {
            if (isOdd && week.isEven) {
              continue;
            }
            if (isEven && week.isOdd) {
              continue;
            }
            weeks.add(week);
          }
        } else {
          final week = int.tryParse(piece);
          if (week != null) {
            if (isOdd && week.isEven) {
              continue;
            }
            if (isEven && week.isOdd) {
              continue;
            }
            weeks.add(week);
          }
        }
      }
    }

    return weeks.toList()..sort();
  }

  String? _cellText(Data? cell) {
    final value = cell?.value;
    switch (value) {
      case null:
        return null;
      case TextCellValue():
        final text = (value.value.text ?? value.toString()).trim();
        return text.isEmpty ? null : text;
      default:
        final text = value.toString().trim();
        return text.isEmpty ? null : text;
    }
  }

  int? _matchWeekday(String? input) {
    if (input == null) {
      return null;
    }

    final normalized = input.replaceAll(RegExp(r'\s+'), '');
    const mappings = <String, int>{
      '周一': 1,
      '星期一': 1,
      '周二': 2,
      '星期二': 2,
      '周三': 3,
      '星期三': 3,
      '周四': 4,
      '星期四': 4,
      '周五': 5,
      '星期五': 5,
      '周六': 6,
      '星期六': 6,
      '周日': 7,
      '星期日': 7,
      '星期天': 7,
      '周天': 7,
    };

    return mappings[normalized];
  }

  bool _looksLikeTeacher(String line) {
    return line.contains('老师') ||
        line.contains('教授') ||
        line.contains('讲师') ||
        line.contains('教师') ||
        (RegExp(r'^[\u4e00-\u9fa5]{2,4}$').hasMatch(line) &&
            !line.contains('周'));
  }

  bool _looksLikeLocation(String line) {
    return RegExp(
      r'(\d|[A-Z]-\d|教|楼|室|馆|机房|实验|校区|Room|Lab)',
      caseSensitive: false,
    ).hasMatch(line);
  }

  String _sanitizeTeacher(String line) {
    return line.replaceAll(RegExp(r'^(教师|老师)[:：]?'), '').trim();
  }
}

class _SheetParseResult {
  const _SheetParseResult({
    required this.rawText,
    required this.courses,
    required this.warnings,
  });

  final String rawText;
  final List<ParsedCourse> courses;
  final List<String> warnings;
}

class _HeaderInfo {
  const _HeaderInfo({required this.rowIndex, required this.weekdayColumns});

  final int rowIndex;
  final Map<int, int> weekdayColumns;
}

class _SectionRange {
  const _SectionRange({required this.start, required this.end});

  final int start;
  final int end;
}

class _MergedSpan {
  const _MergedSpan({required this.endRow});

  final int endRow;
}

class _ParsedCourseText {
  const _ParsedCourseText({
    required this.name,
    this.teacher,
    this.location,
    this.weeks = const <int>[],
    this.note,
  });

  final String name;
  final String? teacher;
  final String? location;
  final List<int> weeks;
  final String? note;
}
