import 'package:course_schedule_app/core/utils/course_conflict_utils.dart';
import 'package:course_schedule_app/features/import/domain/entities/parsed_course.dart';
import 'package:course_schedule_app/features/schedule/domain/entities/course.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('course conflict utils', () {
    test(
      'detects parsed course conflicts with overlapping sections and weeks',
      () {
        final conflicts = detectParsedCourseConflicts(<ParsedCourse>[
          const ParsedCourse(
            name: '高等数学',
            weekday: 1,
            startSection: 1,
            endSection: 2,
            weeks: <int>[1, 2, 3, 4],
          ),
          const ParsedCourse(
            name: '大学物理',
            weekday: 1,
            startSection: 2,
            endSection: 3,
            weeks: <int>[3, 4, 5],
          ),
          const ParsedCourse(
            name: '英语',
            weekday: 2,
            startSection: 1,
            endSection: 2,
            weeks: <int>[1, 2],
          ),
        ]);

        expect(conflicts, hasLength(1));
        expect(conflicts.single.firstName, '高等数学');
        expect(conflicts.single.secondName, '大学物理');
        expect(conflicts.single.weekday, 1);
        expect(conflicts.single.startSection, 2);
        expect(conflicts.single.endSection, 2);
        expect(conflicts.single.overlapWeeks, <int>[3, 4]);
        expect(
          conflictSummary(conflicts.single),
          '高等数学 与 大学物理 在 周一 2-2节 · 第3、4周 冲突',
        );
      },
    );

    test('detects course conflicts and uses course ids as keys', () {
      final conflicts = detectCourseConflicts(<Course>[
        const Course(
          id: 'course-1',
          name: '高等数学',
          weekday: 3,
          startSection: 5,
          endSection: 6,
          weeks: <int>[7],
          colorValue: 0xFF7CB7FF,
        ),
        const Course(
          id: 'course-2',
          name: '线性代数',
          weekday: 3,
          startSection: 5,
          endSection: 6,
          weeks: <int>[7, 8],
          colorValue: 0xFF8ACB88,
        ),
      ]);

      expect(conflicts, hasLength(1));
      expect(conflicts.single.firstKey, 'course-1');
      expect(conflicts.single.secondKey, 'course-2');
      expect(conflicts.single.overlapWeeks, <int>[7]);
    });
  });
}
