import 'package:flutter/material.dart';

class WeekSelector extends StatelessWidget {
  const WeekSelector({
    super.key,
    required this.selectedWeek,
    required this.totalWeeks,
    required this.onChanged,
  });

  final int selectedWeek;
  final int totalWeeks;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: totalWeeks,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final week = index + 1;
          final isSelected = week == selectedWeek;

          return ChoiceChip(
            label: Text('第 $week 周'),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: const Color(0xFF24543E),
            backgroundColor: const Color(0xFFFFFEFB),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF1B2E24),
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFF24543E)
                  : const Color(0xFFDCE6DE),
            ),
            onSelected: (_) => onChanged(week),
          );
        },
      ),
    );
  }
}
