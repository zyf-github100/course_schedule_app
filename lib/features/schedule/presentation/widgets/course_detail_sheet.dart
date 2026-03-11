import 'package:course_schedule_app/core/constants/app_constants.dart';
import 'package:course_schedule_app/core/utils/parser_utils.dart';
import 'package:course_schedule_app/features/schedule/domain/entities/course.dart';
import 'package:course_schedule_app/features/settings/domain/entities/section_time.dart';
import 'package:flutter/material.dart';

class CourseDetailSheet extends StatelessWidget {
  const CourseDetailSheet({
    super.key,
    required this.courses,
    required this.selectedWeek,
    required this.sectionTimes,
  });

  final List<Course> courses;
  final int selectedWeek;
  final List<SectionTime> sectionTimes;

  @override
  Widget build(BuildContext context) {
    final sortedCourses = List<Course>.from(courses)
      ..sort((left, right) => left.startSection.compareTo(right.startSection));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sortedCourses.length == 1 ? '课程详情' : '同时间段课程',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                '当前查看第 $selectedWeek 周，共 ${sortedCourses.length} 门课程。',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < sortedCourses.length; i++) ...[
                _CourseDetailCard(
                  course: sortedCourses[i],
                  timeText: _courseTimeText(sortedCourses[i]),
                ),
                if (i != sortedCourses.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _courseTimeText(Course course) {
    final startTime =
        course.startTime ?? _slotForSection(course.startSection)?.startTime;
    final endTime =
        course.endTime ?? _slotForSection(course.endSection)?.endTime;
    final sectionText =
        '${AppConstants.weekdayLabel(course.weekday)} '
        '${course.startSection}-${course.endSection}节';
    if (startTime != null && endTime != null) {
      return '$sectionText · $startTime-$endTime';
    }

    return sectionText;
  }

  SectionTime? _slotForSection(int section) {
    for (final slot in sectionTimes) {
      if (section >= slot.startSection && section <= slot.endSection) {
        return slot;
      }
    }

    return null;
  }
}

class _CourseDetailCard extends StatelessWidget {
  const _CourseDetailCard({required this.course, required this.timeText});

  final Course course;
  final String timeText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EFE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  course.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(course.colorValue),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoLine(label: '时间', value: timeText),
          _InfoLine(label: '周数', value: weeksToText(course.weeks)),
          _InfoLine(label: '地点', value: course.location ?? '待补充'),
          _InfoLine(label: '教师', value: course.teacher ?? '待补充'),
          if (course.note != null && course.note!.isNotEmpty)
            _InfoLine(label: '备注', value: course.note!),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
