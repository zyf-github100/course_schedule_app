import 'package:course_schedule_app/features/settings/domain/entities/section_time.dart';

class ScheduleSettings {
  const ScheduleSettings({
    required this.semesterName,
    required this.termStartDate,
    required this.sectionTimes,
  });

  final String semesterName;
  final DateTime termStartDate;
  final List<SectionTime> sectionTimes;

  factory ScheduleSettings.defaults({DateTime? now}) {
    final current = now ?? DateTime.now();

    return ScheduleSettings(
      semesterName: defaultSemesterNameFor(current),
      termStartDate: defaultTermStartDateFor(current),
      sectionTimes: defaultSectionTimes,
    );
  }

  static String defaultSemesterNameFor(DateTime date) {
    return '${date.year}年${date.month >= 8 ? '秋季学期' : '春季学期'}';
  }

  static DateTime defaultTermStartDateFor(DateTime date) {
    if (date.month >= 8) {
      return DateTime(date.year, 9, 1);
    }

    return DateTime(date.year, 2, 24);
  }

  static const List<SectionTime> defaultSectionTimes = <SectionTime>[
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
    SectionTime(
      startSection: 5,
      endSection: 6,
      startTime: '14:00',
      endTime: '15:35',
    ),
    SectionTime(
      startSection: 7,
      endSection: 8,
      startTime: '16:00',
      endTime: '17:35',
    ),
    SectionTime(
      startSection: 9,
      endSection: 10,
      startTime: '19:00',
      endTime: '20:35',
    ),
    SectionTime(
      startSection: 11,
      endSection: 12,
      startTime: '20:45',
      endTime: '22:20',
    ),
  ];

  SectionTime? slotForSection(int section) {
    for (final slot in sectionTimes) {
      if (slot.containsSection(section)) {
        return slot;
      }
    }

    return null;
  }

  String? startTimeForSection(int section) {
    return slotForSection(section)?.startTime;
  }

  String? endTimeForSection(int section) {
    return slotForSection(section)?.endTime;
  }

  ScheduleSettings copyWith({
    String? semesterName,
    DateTime? termStartDate,
    List<SectionTime>? sectionTimes,
  }) {
    return ScheduleSettings(
      semesterName: semesterName ?? this.semesterName,
      termStartDate: termStartDate ?? this.termStartDate,
      sectionTimes: sectionTimes ?? this.sectionTimes,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'semesterName': semesterName,
      'termStartDate': termStartDate.toIso8601String(),
      'sectionTimes': sectionTimes.map((slot) => slot.toJson()).toList(),
    };
  }

  factory ScheduleSettings.fromJson(Map<String, dynamic> json) {
    return ScheduleSettings(
      semesterName: json['semesterName'] as String,
      termStartDate: DateTime.parse(json['termStartDate'] as String),
      sectionTimes: (json['sectionTimes'] as List<dynamic>)
          .map((item) => SectionTime.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
