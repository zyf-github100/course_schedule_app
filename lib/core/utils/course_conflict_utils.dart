import 'dart:math' as math;

import 'package:course_schedule_app/core/constants/app_constants.dart';
import 'package:course_schedule_app/core/utils/parser_utils.dart';
import 'package:course_schedule_app/features/import/domain/entities/parsed_course.dart';
import 'package:course_schedule_app/features/schedule/domain/entities/course.dart';

class ScheduleConflict {
  const ScheduleConflict({
    required this.firstKey,
    required this.secondKey,
    required this.firstName,
    required this.secondName,
    required this.weekday,
    required this.startSection,
    required this.endSection,
    required this.overlapWeeks,
  });

  final String firstKey;
  final String secondKey;
  final String firstName;
  final String secondName;
  final int weekday;
  final int startSection;
  final int endSection;
  final List<int> overlapWeeks;
}

List<ScheduleConflict> detectParsedCourseConflicts(List<ParsedCourse> courses) {
  return _detectConflicts<ParsedCourse>(
    courses,
    keyOf: (_, index) => index.toString(),
    nameOf: (course) => course.name,
    weekdayOf: (course) => course.weekday,
    startSectionOf: (course) => course.startSection,
    endSectionOf: (course) => course.endSection,
    weeksOf: (course) => course.weeks,
  );
}

List<ScheduleConflict> detectCourseConflicts(List<Course> courses) {
  return _detectConflicts<Course>(
    courses,
    keyOf: (course, _) => course.id,
    nameOf: (course) => course.name,
    weekdayOf: (course) => course.weekday,
    startSectionOf: (course) => course.startSection,
    endSectionOf: (course) => course.endSection,
    weeksOf: (course) => course.weeks,
  );
}

String conflictSummary(ScheduleConflict conflict, {bool includeWeeks = true}) {
  final timeText =
      '${AppConstants.weekdayLabel(conflict.weekday)} '
      '${conflict.startSection}-${conflict.endSection}节';
  final weeksText = includeWeeks
      ? ' · 第${weeksToText(conflict.overlapWeeks)}周'
      : '';
  return '${conflict.firstName} 与 ${conflict.secondName} 在 $timeText$weeksText 冲突';
}

List<ScheduleConflict> _detectConflicts<T>(
  List<T> items, {
  required String Function(T item, int index) keyOf,
  required String Function(T item) nameOf,
  required int? Function(T item) weekdayOf,
  required int? Function(T item) startSectionOf,
  required int? Function(T item) endSectionOf,
  required List<int> Function(T item) weeksOf,
}) {
  final conflicts = <ScheduleConflict>[];

  for (var leftIndex = 0; leftIndex < items.length; leftIndex++) {
    final left = items[leftIndex];
    final leftWeekday = weekdayOf(left);
    final leftStartSection = startSectionOf(left);
    final leftEndSection = endSectionOf(left);
    if (leftWeekday == null ||
        leftStartSection == null ||
        leftEndSection == null) {
      continue;
    }

    final leftWeeks = weeksOf(left).toSet();
    if (leftWeeks.isEmpty) {
      continue;
    }

    for (
      var rightIndex = leftIndex + 1;
      rightIndex < items.length;
      rightIndex++
    ) {
      final right = items[rightIndex];
      final rightWeekday = weekdayOf(right);
      final rightStartSection = startSectionOf(right);
      final rightEndSection = endSectionOf(right);
      if (rightWeekday == null ||
          rightStartSection == null ||
          rightEndSection == null ||
          leftWeekday != rightWeekday) {
        continue;
      }

      final overlapStartSection = math.max(leftStartSection, rightStartSection);
      final overlapEndSection = math.min(leftEndSection, rightEndSection);
      if (overlapStartSection > overlapEndSection) {
        continue;
      }

      final overlapWeeks = weeksOf(
        right,
      ).where((week) => leftWeeks.contains(week)).toSet().toList()..sort();
      if (overlapWeeks.isEmpty) {
        continue;
      }

      conflicts.add(
        ScheduleConflict(
          firstKey: keyOf(left, leftIndex),
          secondKey: keyOf(right, rightIndex),
          firstName: nameOf(left),
          secondName: nameOf(right),
          weekday: leftWeekday,
          startSection: overlapStartSection,
          endSection: overlapEndSection,
          overlapWeeks: overlapWeeks,
        ),
      );
    }
  }

  return conflicts;
}
