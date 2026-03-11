class Course {
  const Course({
    required this.id,
    required this.name,
    required this.weekday,
    required this.startSection,
    required this.endSection,
    required this.weeks,
    required this.colorValue,
    this.teacher,
    this.location,
    this.startTime,
    this.endTime,
    this.note,
  });

  final String id;
  final String name;
  final String? teacher;
  final String? location;
  final int weekday;
  final int startSection;
  final int endSection;
  final String? startTime;
  final String? endTime;
  final List<int> weeks;
  final int colorValue;
  final String? note;

  Course copyWith({
    String? id,
    String? name,
    String? teacher,
    String? location,
    int? weekday,
    int? startSection,
    int? endSection,
    String? startTime,
    String? endTime,
    List<int>? weeks,
    int? colorValue,
    String? note,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      location: location ?? this.location,
      weekday: weekday ?? this.weekday,
      startSection: startSection ?? this.startSection,
      endSection: endSection ?? this.endSection,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      weeks: weeks ?? this.weeks,
      colorValue: colorValue ?? this.colorValue,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'teacher': teacher,
      'location': location,
      'weekday': weekday,
      'startSection': startSection,
      'endSection': endSection,
      'startTime': startTime,
      'endTime': endTime,
      'weeks': weeks,
      'colorValue': colorValue,
      'note': note,
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      name: json['name'] as String,
      teacher: json['teacher'] as String?,
      location: json['location'] as String?,
      weekday: json['weekday'] as int,
      startSection: json['startSection'] as int,
      endSection: json['endSection'] as int,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      weeks: (json['weeks'] as List<dynamic>).cast<int>(),
      colorValue: json['colorValue'] as int,
      note: json['note'] as String?,
    );
  }
}
