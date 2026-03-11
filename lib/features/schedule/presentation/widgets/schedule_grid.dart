import 'package:course_schedule_app/core/constants/app_constants.dart';
import 'package:course_schedule_app/features/schedule/domain/entities/course.dart';
import 'package:course_schedule_app/features/schedule/presentation/widgets/schedule_cell.dart';
import 'package:course_schedule_app/features/settings/domain/entities/section_time.dart';
import 'package:flutter/material.dart';

class ScheduleGrid extends StatelessWidget {
  const ScheduleGrid({
    super.key,
    required this.courses,
    required this.sectionTimes,
    required this.conflictingCourseIds,
    this.onCoursesTap,
  });

  final List<Course> courses;
  final List<SectionTime> sectionTimes;
  final Set<String> conflictingCourseIds;
  final ValueChanged<List<Course>>? onCoursesTap;

  @override
  Widget build(BuildContext context) {
    final courseMap = <String, List<Course>>{};
    for (final course in courses) {
      final key =
          '${course.weekday}-${course.startSection}-${course.endSection}';
      courseMap.putIfAbsent(key, () => <Course>[]).add(course);
    }
    final displaySlots = _buildDisplaySlots(sectionTimes, courses);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF6FAF6), Color(0xFFEEF4F8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE0E7E3)),
      ),
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 760),
            child: Column(
              children: [
                Row(
                  children: [
                    const _TableHeaderCell('节次', width: 96),
                    for (final day in AppConstants.weekdays.take(5))
                      _TableHeaderCell(day),
                  ],
                ),
                for (final slot in displaySlots)
                  Row(
                    children: [
                      _TableCell(
                        label: slot.label,
                        timeRange: '${slot.startTime}-${slot.endTime}',
                        width: 96,
                      ),
                      for (var weekday = 1; weekday <= 5; weekday++)
                        ScheduleCell(
                          courses:
                              courseMap['$weekday-${slot.startSection}-${slot.endSection}'] ??
                              const <Course>[],
                          isConflict:
                              (courseMap['$weekday-${slot.startSection}-${slot.endSection}'] ??
                                      const <Course>[])
                                  .any(
                                    (course) => conflictingCourseIds.contains(
                                      course.id,
                                    ),
                                  ),
                          onTap: () {
                            final cellCourses =
                                courseMap['$weekday-${slot.startSection}-${slot.endSection}'] ??
                                const <Course>[];
                            if (cellCourses.isEmpty) {
                              return;
                            }
                            onCoursesTap?.call(cellCourses);
                          },
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<SectionTime> _buildDisplaySlots(
    List<SectionTime> configuredSlots,
    List<Course> courses,
  ) {
    final slotsByKey = <String, SectionTime>{
      for (final slot in configuredSlots)
        '${slot.startSection}-${slot.endSection}': slot,
    };

    for (final course in courses) {
      final key = '${course.startSection}-${course.endSection}';
      if (slotsByKey.containsKey(key)) {
        continue;
      }
      slotsByKey[key] = SectionTime(
        startSection: course.startSection,
        endSection: course.endSection,
        startTime: course.startTime ?? '',
        endTime: course.endTime ?? '',
      );
    }

    final slots = slotsByKey.values.toList()
      ..sort((left, right) => left.startSection.compareTo(right.startSection));
    return slots;
  }
}

class _TableHeaderCell extends StatelessWidget {
  const _TableHeaderCell(this.text, {this.width = 118});

  final String text;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 56,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F3EA), Color(0xFFDCEAF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3ECE5)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Color(0xFF173024),
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell({
    required this.label,
    required this.timeRange,
    this.width = 118,
  });

  final String label;
  final String timeRange;
  final double width;

  @override
  Widget build(BuildContext context) {
    final hasTimeRange = timeRange.trim().isNotEmpty && timeRange != '-';

    return Container(
      width: width,
      height: 104,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3ECE5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5EE),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF173024),
              ),
            ),
          ),
          if (hasTimeRange) ...[
            const SizedBox(height: 6),
            Text(
              timeRange,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF667A70),
                fontWeight: FontWeight.w600,
                fontSize: 11,
                height: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
