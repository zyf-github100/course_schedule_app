import 'dart:typed_data';

import 'package:course_schedule_app/features/import/data/parsers/excel_schedule_parser.dart';
import 'package:course_schedule_app/features/import/domain/entities/import_file.dart';
import 'package:course_schedule_app/features/import/domain/entities/import_source_type.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExcelScheduleParser', () {
    test('parses a regular schedule worksheet into courses', () async {
      final parser = ExcelScheduleParser();
      final draft = await parser.parse(
        ImportFile(
          path: 'sample.xlsx',
          name: 'sample.xlsx',
          sourceType: ImportSourceType.excel,
          bytes: _buildRegularWorkbook(),
        ),
      );

      expect(draft.parsedCourses, hasLength(3));
      final math = draft.parsedCourses.firstWhere(
        (course) => course.name == '高等数学',
      );
      final english = draft.parsedCourses.firstWhere(
        (course) => course.name == '大学英语',
      );
      final coding = draft.parsedCourses.firstWhere(
        (course) => course.name == '程序设计',
      );

      expect(math.teacher, '刘老师');
      expect(math.location, 'A-203');
      expect(math.weekday, 1);
      expect(math.startSection, 1);
      expect(math.endSection, 2);
      expect(math.weeks.first, 1);
      expect(math.weeks.last, 16);

      expect(english.weekday, 3);
      expect(english.location, 'B-401');
      expect(english.weeks, List<int>.generate(8, (index) => index + 1));

      expect(coding.teacher, '李老师');
      expect(coding.weekday, 5);
      expect(coding.startSection, 5);
      expect(coding.endSection, 6);
      expect(coding.weeks.first, 9);
      expect(coding.weeks.last, 16);
    });

    test('parses merged cells and odd week expressions', () async {
      final parser = ExcelScheduleParser();
      final draft = await parser.parse(
        ImportFile(
          path: 'merged.xlsx',
          name: 'merged.xlsx',
          sourceType: ImportSourceType.excel,
          bytes: _buildMergedWorkbook(),
        ),
      );

      expect(draft.parsedCourses, hasLength(1));
      final physics = draft.parsedCourses.single;

      expect(physics.name, '大学物理');
      expect(physics.teacher, '王老师');
      expect(physics.location, '理科楼 204');
      expect(physics.weekday, 1);
      expect(physics.startSection, 1);
      expect(physics.endSection, 4);
      expect(physics.weeks, <int>[1, 3, 5, 7, 9, 11, 13, 15]);
    });
  });
}

Uint8List _buildRegularWorkbook() {
  final excel = Excel.createExcel();
  final sheetName = excel.getDefaultSheet() ?? 'Sheet1';
  final sheet = excel[sheetName];

  sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('节次');
  sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('周一');
  sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('周二');
  sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('周三');
  sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('周四');
  sheet.cell(CellIndex.indexByString('F1')).value = TextCellValue('周五');

  sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue('1-2节');
  sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue('3-4节');
  sheet.cell(CellIndex.indexByString('A4')).value = TextCellValue('5-6节');

  sheet.cell(CellIndex.indexByString('B2')).value = TextCellValue(
    '高等数学\n刘老师\nA-203\n1-16周',
  );
  sheet.cell(CellIndex.indexByString('D3')).value = TextCellValue(
    '大学英语\nB-401\n周老师\n1-8周',
  );
  sheet.cell(CellIndex.indexByString('F4')).value = TextCellValue(
    '程序设计\n机房 302\n李老师\n9-16周',
  );

  return Uint8List.fromList(excel.save()!);
}

Uint8List _buildMergedWorkbook() {
  final excel = Excel.createExcel();
  final sheetName = excel.getDefaultSheet() ?? 'Sheet1';
  final sheet = excel[sheetName];

  sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('节次');
  sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('周一');
  sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('周二');
  sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('周三');

  sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue('1-2节');
  sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue('3-4节');

  sheet.merge(
    CellIndex.indexByString('B2'),
    CellIndex.indexByString('B3'),
    customValue: TextCellValue('大学物理\n王老师\n理科楼 204\n1-16周(单)'),
  );

  return Uint8List.fromList(excel.save()!);
}
