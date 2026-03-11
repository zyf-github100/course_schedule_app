import 'package:course_schedule_app/features/schedule/domain/entities/course.dart';
import 'package:course_schedule_app/features/settings/domain/entities/schedule_settings.dart';
import 'package:course_schedule_app/features/settings/domain/entities/section_time.dart';

class Semester {
  const Semester({
    required this.id,
    required this.name,
    required this.termStartDate,
    required this.totalWeeks,
    required this.courses,
    this.sectionTimes = ScheduleSettings.defaultSectionTimes,
  });

  final String id;
  final String name;
  final DateTime termStartDate;
  final int totalWeeks;
  final List<Course> courses;
  final List<SectionTime> sectionTimes;

  Semester copyWith({
    String? id,
    String? name,
    DateTime? termStartDate,
    int? totalWeeks,
    List<Course>? courses,
    List<SectionTime>? sectionTimes,
  }) {
    return Semester(
      id: id ?? this.id,
      name: name ?? this.name,
      termStartDate: termStartDate ?? this.termStartDate,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      courses: courses ?? this.courses,
      sectionTimes: sectionTimes ?? this.sectionTimes,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'termStartDate': termStartDate.toIso8601String(),
      'totalWeeks': totalWeeks,
      'courses': courses.map((course) => course.toJson()).toList(),
      'sectionTimes': sectionTimes.map((slot) => slot.toJson()).toList(),
    };
  }

  factory Semester.fromJson(Map<String, dynamic> json) {
    final sectionTimesJson = json['sectionTimes'] as List<dynamic>?;

    return Semester(
      id: json['id'] as String,
      name: json['name'] as String,
      termStartDate: DateTime.parse(json['termStartDate'] as String),
      totalWeeks: json['totalWeeks'] as int,
      courses: (json['courses'] as List<dynamic>)
          .map((item) => Course.fromJson(item as Map<String, dynamic>))
          .toList(),
      sectionTimes: sectionTimesJson == null
          ? ScheduleSettings.defaultSectionTimes
          : sectionTimesJson
                .map(
                  (item) => SectionTime.fromJson(item as Map<String, dynamic>),
                )
                .toList(),
    );
  }
}
