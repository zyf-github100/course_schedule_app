class AppConstants {
  static const weekdays = <String>['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  static const sectionSlots = <SectionSlot>[
    SectionSlot(1, 2, '1-2节'),
    SectionSlot(3, 4, '3-4节'),
    SectionSlot(5, 6, '5-6节'),
    SectionSlot(7, 8, '7-8节'),
    SectionSlot(9, 10, '9-10节'),
    SectionSlot(11, 12, '11-12节'),
  ];

  static String weekdayLabel(int? weekday) {
    if (weekday == null || weekday < 1 || weekday > weekdays.length) {
      return '待确认';
    }

    return weekdays[weekday - 1];
  }
}

class SectionSlot {
  const SectionSlot(this.start, this.end, this.label);

  final int start;
  final int end;
  final String label;
}
