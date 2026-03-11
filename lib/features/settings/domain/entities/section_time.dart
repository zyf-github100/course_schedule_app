class SectionTime {
  const SectionTime({
    required this.startSection,
    required this.endSection,
    required this.startTime,
    required this.endTime,
  });

  final int startSection;
  final int endSection;
  final String startTime;
  final String endTime;

  String get label => '$startSection-$endSection节';

  bool containsSection(int section) {
    return section >= startSection && section <= endSection;
  }

  SectionTime copyWith({
    int? startSection,
    int? endSection,
    String? startTime,
    String? endTime,
  }) {
    return SectionTime(
      startSection: startSection ?? this.startSection,
      endSection: endSection ?? this.endSection,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'startSection': startSection,
      'endSection': endSection,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory SectionTime.fromJson(Map<String, dynamic> json) {
    return SectionTime(
      startSection: json['startSection'] as int,
      endSection: json['endSection'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );
  }
}
