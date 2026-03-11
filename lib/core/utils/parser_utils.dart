String weeksToText(List<int> weeks) {
  if (weeks.isEmpty) {
    return '待确认';
  }

  final uniqueWeeks = weeks.toSet().toList()..sort();
  return uniqueWeeks.join('、');
}

List<int> parseWeeksInput(String input) {
  if (input.trim().isEmpty) {
    return const <int>[];
  }

  return input
      .split(RegExp(r'[\s,，、/]+'))
      .map((part) => int.tryParse(part.trim()))
      .whereType<int>()
      .where((week) => week > 0)
      .toSet()
      .toList()
    ..sort();
}
