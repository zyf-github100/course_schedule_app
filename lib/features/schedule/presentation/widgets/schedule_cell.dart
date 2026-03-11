import 'package:course_schedule_app/features/schedule/domain/entities/course.dart';
import 'package:flutter/material.dart';

class ScheduleCell extends StatelessWidget {
  const ScheduleCell({
    super.key,
    required this.courses,
    required this.isConflict,
    this.onTap,
  });

  final List<Course> courses;
  final bool isConflict;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return Container(
        width: 118,
        height: 104,
        alignment: Alignment.center,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFCFDFC), Color(0xFFF3F8F3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE3ECE5)),
        ),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Icon(
            Icons.add_rounded,
            size: 18,
            color: Color(0x4013201A),
          ),
        ),
      );
    }

    final primaryCourse = courses.first;
    final baseColor = Color(primaryCourse.colorValue);

    return Container(
      margin: const EdgeInsets.all(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 118,
          height: 104,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                baseColor.withValues(alpha: 0.28),
                baseColor.withValues(alpha: 0.14),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isConflict
                  ? const Color(0xFFE36464)
                  : baseColor.withValues(alpha: 0.34),
              width: isConflict ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: baseColor.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 4,
                  height: 46,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      primaryCourse.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: Color(0xFF14231B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      primaryCourse.location ?? '地点待定',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF5D7268),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.open_in_full_rounded,
                  size: 14,
                  color: baseColor.withValues(alpha: 0.58),
                ),
              ),
              if (courses.length > 1 || isConflict)
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isConflict
                          ? const Color(0xFFFFE1E1)
                          : Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      courses.length > 1 ? '+${courses.length - 1}' : '冲突',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
