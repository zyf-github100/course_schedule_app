import 'package:course_schedule_app/features/settings/domain/entities/schedule_settings.dart';
import 'package:course_schedule_app/features/settings/domain/entities/section_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScheduleSettings', () {
    test('builds season defaults from a fixed date', () {
      final springSettings = ScheduleSettings.defaults(
        now: DateTime(2026, 3, 11),
      );
      final autumnSettings = ScheduleSettings.defaults(
        now: DateTime(2026, 9, 5),
      );

      expect(springSettings.semesterName, '2026年春季学期');
      expect(springSettings.termStartDate, DateTime(2026, 2, 24));
      expect(autumnSettings.semesterName, '2026年秋季学期');
      expect(autumnSettings.termStartDate, DateTime(2026, 9, 1));
    });

    test('resolves course time range from configured section slots', () {
      final settings = ScheduleSettings(
        semesterName: '2026年春季学期',
        termStartDate: DateTime(2026, 2, 24),
        sectionTimes: <SectionTime>[
          SectionTime(
            startSection: 1,
            endSection: 2,
            startTime: '08:00',
            endTime: '09:35',
          ),
          SectionTime(
            startSection: 3,
            endSection: 4,
            startTime: '10:00',
            endTime: '11:35',
          ),
        ],
      );

      expect(settings.startTimeForSection(1), '08:00');
      expect(settings.endTimeForSection(4), '11:35');
      expect(settings.startTimeForSection(6), isNull);
    });
  });
}
