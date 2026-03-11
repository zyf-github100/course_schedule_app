import 'package:course_schedule_app/features/import/domain/entities/import_source_type.dart';
import 'package:flutter/material.dart';

class ImportSourceCard extends StatelessWidget {
  const ImportSourceCard({
    super.key,
    required this.sourceType,
    required this.onTap,
    this.isRecommended = false,
  });

  final ImportSourceType sourceType;
  final VoidCallback onTap;
  final bool isRecommended;

  @override
  Widget build(BuildContext context) {
    final icon = sourceType == ImportSourceType.pdf
        ? Icons.picture_as_pdf_rounded
        : Icons.table_view_rounded;
    final backgroundColor = sourceType == ImportSourceType.pdf
        ? const Color(0xFFFFEEE9)
        : const Color(0xFFEAF8EE);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28),
                const Spacer(),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '推荐先做',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '导入 ${sourceType.label}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              sourceType.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                height: 1.5,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
