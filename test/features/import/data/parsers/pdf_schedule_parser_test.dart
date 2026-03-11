import 'dart:typed_data';
import 'dart:ui';

import 'package:course_schedule_app/features/import/data/parsers/pdf_schedule_parser.dart';
import 'package:course_schedule_app/features/import/domain/entities/import_file.dart';
import 'package:course_schedule_app/features/import/domain/entities/import_source_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  group('PdfScheduleParser', () {
    test('parses text-based pdf course records', () async {
      final parser = PdfScheduleParser();
      final pdfBytes = await _buildPdf(
        '高等数学 周一 1-2节 A-203 刘老师 1-16周\n\n大学英语\n周三 3-4节 B-401 周老师 1-8周',
      );

      final draft = await parser.parse(
        ImportFile(
          path: 'sample.pdf',
          name: 'sample.pdf',
          sourceType: ImportSourceType.pdf,
          bytes: pdfBytes,
        ),
      );

      expect(draft.parsedCourses, hasLength(2));

      final math = draft.parsedCourses.firstWhere(
        (course) => course.name == '高等数学',
      );
      expect(math.weekday, 1);
      expect(math.startSection, 1);
      expect(math.endSection, 2);
      expect(math.location, 'A-203');
      expect(math.teacher, '刘老师');
      expect(math.weeks.first, 1);
      expect(math.weeks.last, 16);

      final english = draft.parsedCourses.firstWhere(
        (course) => course.name == '大学英语',
      );
      expect(english.weekday, 3);
      expect(english.location, 'B-401');
      expect(english.teacher, '周老师');
      expect(english.weeks, List<int>.generate(8, (index) => index + 1));
      expect(draft.suggestedSectionTimes, isEmpty);
    });

    test('throws readable format error for unsupported text', () async {
      final parser = PdfScheduleParser();
      final pdfBytes = await _buildPdf('这是一个普通通知，不包含周几、节次和周数。');

      expect(
        () => parser.parse(
          ImportFile(
            path: 'unsupported.pdf',
            name: 'unsupported.pdf',
            sourceType: ImportSourceType.pdf,
            bytes: pdfBytes,
          ),
        ),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('未识别到课程'),
          ),
        ),
      );
    });

    test('extracts section times when pdf contains clock rows', () async {
      final parser = PdfScheduleParser();
      final pdfBytes = await _buildPdf(
        '1\n09:00\n09:40\n2\n09:41\n10:20\n高等数学 周一 1-2节 A-203 刘老师 1-16周',
      );

      final draft = await parser.parse(
        ImportFile(
          path: 'time-slots.pdf',
          name: 'time-slots.pdf',
          sourceType: ImportSourceType.pdf,
          bytes: pdfBytes,
        ),
      );

      expect(draft.parsedCourses, hasLength(1));
      expect(draft.suggestedSectionTimes, hasLength(1));
      expect(draft.suggestedSectionTimes.first.startSection, 1);
      expect(draft.suggestedSectionTimes.first.endSection, 2);
      expect(draft.suggestedSectionTimes.first.startTime, '09:00');
      expect(draft.suggestedSectionTimes.first.endTime, '10:20');
    });

    test('parses grid layout text with weekday header anchors', () {
      final parser = PdfScheduleParser();

      final courses = parser.parseExtractedText(
        '''
时间段节次星期一星期二星期三星期四星期五星期六星期日
1
09:00
09:40
软件过程与管理
(1-2节)1-9周/校区:广州校区/场地:U601/教师:王彩莲/教学班:(2025-2026-2)-SW3019-6
软件过程与管理
(1-2节)1-9周/校区:广州校区/场地:SII-611/教师:王彩莲/教学班:(2025-2026-2)-SW3019-6A
设计模式解析
(1-2节)1-9周/校区:广州校区/场地:U204/教师:文霞/教学班:(2025-2026-2)-SS4004-1
3
10:40
11:20
项目需求分析与管理
(3-4节)1-9周/校区:广州校区/场地:A303/教师:张晓龙/教学班:(2025-2026-2)-SW3017-2
''',
        textLines: const <PdfTextLineSnapshot>[
          PdfTextLineSnapshot(
            text: '时间段 节次 星期一 星期二 星期三 星期四 星期五 星期六 星期日',
            top: 0,
            words: <PdfTextWordSnapshot>[
              PdfTextWordSnapshot(text: '星期一', top: 676.0),
              PdfTextWordSnapshot(text: '星期二', top: 572.2),
              PdfTextWordSnapshot(text: '星期三', top: 468.3),
              PdfTextWordSnapshot(text: '星期四', top: 364.5),
              PdfTextWordSnapshot(text: '星期五', top: 260.6),
              PdfTextWordSnapshot(text: '星期六', top: 156.8),
              PdfTextWordSnapshot(text: '星期日', top: 52.9),
            ],
          ),
          PdfTextLineSnapshot(text: '软件过程与管理', top: 677.2),
          PdfTextLineSnapshot(text: '软件过程与管理', top: 469.5),
          PdfTextLineSnapshot(text: '设计模式解析', top: 374.6),
          PdfTextLineSnapshot(text: '项目需求分析与管理', top: 555.3),
        ],
      );

      expect(courses, hasLength(4));

      expect(
        courses.map((course) => (course.name, course.weekday)),
        containsAll(<(String, int?)>[
          ('软件过程与管理', 1),
          ('软件过程与管理', 3),
          ('设计模式解析', 4),
          ('项目需求分析与管理', 2),
        ]),
      );

      final mondayCourse = courses.firstWhere(
        (course) => course.name == '软件过程与管理' && course.weekday == 1,
      );
      expect(mondayCourse.location, 'U601');
      expect(mondayCourse.teacher, '王彩莲');
      expect(mondayCourse.startSection, 1);
      expect(mondayCourse.endSection, 2);
      expect(mondayCourse.weeks, List<int>.generate(9, (index) => index + 1));
    });

    test('repairs garbled course title from known course code fallback', () {
      final parser = PdfScheduleParser();

      final courses = parser.parseExtractedText(
        '''
时间段节次星期一星期二星期三星期四星期五星期六星期日
15
20:30
21:10
ㅎᩣݛ�
(15-16节)11-15周/校区:广州校区/场地:A202/教师:邝晓彤/教学班:(2025-2026-2)-GE4003-26
''',
        textLines: const <PdfTextLineSnapshot>[
          PdfTextLineSnapshot(
            text: '时间段 节次 星期一 星期二 星期三 星期四 星期五 星期六 星期日',
            top: 0,
            words: <PdfTextWordSnapshot>[
              PdfTextWordSnapshot(text: '星期一', top: 676.0),
              PdfTextWordSnapshot(text: '星期二', top: 572.2),
              PdfTextWordSnapshot(text: '星期三', top: 468.3),
              PdfTextWordSnapshot(text: '星期四', top: 364.5),
              PdfTextWordSnapshot(text: '星期五', top: 260.6),
              PdfTextWordSnapshot(text: '星期六', top: 156.8),
              PdfTextWordSnapshot(text: '星期日', top: 52.9),
            ],
          ),
          PdfTextLineSnapshot(text: 'ㅎᩣݛ�', top: 496.5),
        ],
      );

      expect(courses, hasLength(1));
      expect(courses.single.name, '就业指导');
      expect(courses.single.weekday, 3);
      expect(courses.single.startSection, 15);
      expect(courses.single.endSection, 16);
      expect(courses.single.location, 'A202');
      expect(courses.single.teacher, '邝晓彤');
      expect(courses.single.weeks, <int>[11, 12, 13, 14, 15]);
    });
  });
}

Future<Uint8List> _buildPdf(String text) async {
  final document = PdfDocument();
  final page = document.pages.add();
  final font = PdfCjkStandardFont(PdfCjkFontFamily.heiseiKakuGothicW5, 14);

  page.graphics.drawString(
    text,
    font,
    bounds: const Rect.fromLTWH(0, 0, 520, 720),
  );

  final bytes = await document.save();
  document.dispose();
  return Uint8List.fromList(bytes);
}
