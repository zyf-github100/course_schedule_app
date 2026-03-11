class ParsedCourse {
  const ParsedCourse({
    required this.name,
    this.teacher,
    this.location,
    this.weekday,
    this.startSection,
    this.endSection,
    this.weeks = const <int>[],
    this.note,
  });

  final String name;
  final String? teacher;
  final String? location;
  final int? weekday;
  final int? startSection;
  final int? endSection;
  final List<int> weeks;
  final String? note;
}
