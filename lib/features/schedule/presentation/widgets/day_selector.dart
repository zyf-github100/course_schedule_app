import 'package:course_schedule_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

class DaySelector extends StatelessWidget {
  const DaySelector({
    super.key,
    required this.selectedDay,
    required this.onChanged,
    this.courseCounts = const <int, int>{},
  });

  final int selectedDay;
  final ValueChanged<int> onChanged;
  final Map<int, int> courseCounts;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.weekdays.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final weekday = index + 1;
          final courseCount = courseCounts[weekday] ?? 0;
          final isSelected = weekday == selectedDay;

          return ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppConstants.weekdays[index]),
                if (courseCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.28)
                          : const Color(0xFFEAF4EC),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$courseCount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF295742),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: const Color(0xFF24543E),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF1B2E24),
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFF24543E)
                  : const Color(0xFFDCE6DE),
            ),
            backgroundColor: const Color(0xFFFFFEFB),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            onSelected: (_) => onChanged(weekday),
          );
        },
      ),
    );
  }
}
