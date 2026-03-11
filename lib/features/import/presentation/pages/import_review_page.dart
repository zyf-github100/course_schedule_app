import 'package:course_schedule_app/app/routes.dart';
import 'package:course_schedule_app/core/constants/app_constants.dart';
import 'package:course_schedule_app/core/utils/course_conflict_utils.dart';
import 'package:course_schedule_app/core/utils/parser_utils.dart';
import 'package:course_schedule_app/features/import/data/repositories/import_history_repository_impl.dart';
import 'package:course_schedule_app/features/import/domain/entities/import_draft.dart';
import 'package:course_schedule_app/features/import/domain/entities/import_history_entry.dart';
import 'package:course_schedule_app/features/import/domain/entities/import_source_type.dart';
import 'package:course_schedule_app/features/import/domain/entities/parsed_course.dart';
import 'package:course_schedule_app/features/import/domain/repositories/import_history_repository.dart';
import 'package:course_schedule_app/features/import/presentation/widgets/parsed_course_form.dart';
import 'package:course_schedule_app/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:course_schedule_app/features/schedule/domain/entities/course.dart';
import 'package:course_schedule_app/features/schedule/domain/entities/semester.dart';
import 'package:course_schedule_app/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:course_schedule_app/features/settings/data/repositories/schedule_settings_repository_impl.dart';
import 'package:course_schedule_app/features/settings/domain/entities/schedule_settings.dart';
import 'package:course_schedule_app/features/settings/domain/entities/section_time.dart';
import 'package:course_schedule_app/features/settings/domain/repositories/schedule_settings_repository.dart';
import 'package:course_schedule_app/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';

class ImportReviewArguments {
  const ImportReviewArguments({required this.draft});

  final ImportDraft draft;
}

class ImportReviewPage extends StatefulWidget {
  const ImportReviewPage({super.key, required this.arguments});

  final ImportReviewArguments arguments;

  @override
  State<ImportReviewPage> createState() => _ImportReviewPageState();
}

class _ImportReviewPageState extends State<ImportReviewPage> {
  late List<ParsedCourse> _courses;
  final ScheduleRepository _scheduleRepository = ScheduleRepositoryImpl();
  final ImportHistoryRepository _historyRepository =
      ImportHistoryRepositoryImpl();
  final ScheduleSettingsRepository _settingsRepository =
      ScheduleSettingsRepositoryImpl();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _courses = List<ParsedCourse>.from(widget.arguments.draft.parsedCourses);
  }

  Future<void> _upsertCourse({ParsedCourse? course, int? index}) async {
    final result = await showModalBottomSheet<ParsedCourse>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ParsedCourseForm(initialCourse: course),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      if (index == null) {
        _courses.add(result);
      } else {
        _courses[index] = result;
      }
    });
  }

  void _removeCourse(int index) {
    setState(() {
      _courses.removeAt(index);
    });
  }

  Future<void> _finishReview() async {
    final validationError = _validateCourses(_courses);
    if (validationError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }

    final conflicts = detectParsedCourseConflicts(_courses);
    if (conflicts.isNotEmpty) {
      final shouldContinue = await _confirmSaveWithConflicts(conflicts);
      if (shouldContinue != true || !mounted) {
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final settings = await _settingsRepository.loadSettings();
      final semester = _buildSemester(_courses, settings);
      await _scheduleRepository.saveSemester(semester);
      await _saveImportHistory(semester);

      if (!mounted) {
        return;
      }

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('保存失败，请稍后重试。')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.arguments.draft;
    final conflicts = detectParsedCourseConflicts(_courses);
    final conflictingIndexes = <String>{
      for (final conflict in conflicts) conflict.firstKey,
      for (final conflict in conflicts) conflict.secondKey,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('确认导入结果'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.settings);
            },
            icon: const Icon(Icons.tune_rounded),
            tooltip: '学期设置',
          ),
          TextButton.icon(
            onPressed: () => _upsertCourse(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('新增'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.sourceFileName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text('来源类型：${draft.sourceType.label}'),
                const SizedBox(height: 4),
                Text(
                  draft.sourceType == ImportSourceType.excel
                      ? 'Excel 已按当前规则完成解析，你可以继续修改后保存到本地。'
                      : 'PDF 已完成文本提取和规则识别，建议继续在确认页复核。',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAF8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          draft.suggestedSectionTimes.isEmpty
                              ? '保存时会套用当前学期设置里的学期名称、开学日期和节次时间。'
                              : '已从源文件识别到节次时间；保存时会优先使用源文件时间，并继续套用当前学期名称和开学日期。',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.settings);
                        },
                        child: const Text('去设置'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (draft.warnings.isNotEmpty) ...[
            const SizedBox(height: 16),
            AppCard(
              color: const Color(0xFFFFF6E8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '提醒',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < draft.warnings.length; i++) ...[
                    _WarningText(text: draft.warnings[i]),
                    if (i != draft.warnings.length - 1)
                      const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ],
          if (conflicts.isNotEmpty) ...[
            const SizedBox(height: 16),
            AppCard(
              color: const Color(0xFFFFF2F2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '检测到课程冲突',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '这些课程在相同周次和时间段有重叠，建议先检查后再保存。',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < conflicts.length; i++) ...[
                    _WarningText(text: conflictSummary(conflicts[i])),
                    if (i != conflicts.length - 1) const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '识别课程',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                '${_courses.length} 条',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_courses.isEmpty)
            AppCard(
              child: Column(
                children: [
                  const Icon(Icons.inbox_outlined, size: 42),
                  const SizedBox(height: 10),
                  Text(
                    '当前没有课程草稿',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '可以手动新增一条课程，先把确认页交互跑通。',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            for (var i = 0; i < _courses.length; i++) ...[
              _CourseDraftCard(
                course: _courses[i],
                isConflict: conflictingIndexes.contains(i.toString()),
                onEdit: () => _upsertCourse(course: _courses[i], index: i),
                onDelete: () => _removeCourse(i),
              ),
              if (i != _courses.length - 1) const SizedBox(height: 12),
            ],
        ],
      ),
      bottomSheet: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _finishReview,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_isSaving ? '保存中...' : '保存课表'),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmSaveWithConflicts(List<ScheduleConflict> conflicts) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('仍然保存冲突课表？'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('检测到以下时间冲突，保存后课表页会继续提示这些冲突：'),
                const SizedBox(height: 12),
                for (var i = 0; i < conflicts.length && i < 4; i++) ...[
                  Text('• ${conflictSummary(conflicts[i])}'),
                  if (i != conflicts.length - 1 && i < 3)
                    const SizedBox(height: 8),
                ],
                if (conflicts.length > 4) ...[
                  const SizedBox(height: 8),
                  Text('还有 ${conflicts.length - 4} 组冲突未展开。'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('返回检查'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('继续保存'),
            ),
          ],
        );
      },
    );
  }

  String? _validateCourses(List<ParsedCourse> courses) {
    if (courses.isEmpty) {
      return '至少需要保留一条课程才能保存。';
    }

    for (final course in courses) {
      if (course.name.trim().isEmpty) {
        return '存在课程名称为空的记录，请先修正。';
      }
      if (course.weekday == null ||
          course.startSection == null ||
          course.endSection == null) {
        return '课程“${course.name}”缺少星期或节次，请先补充。';
      }
      if (course.weeks.isEmpty) {
        return '课程“${course.name}”缺少周数，请先补充。';
      }
    }

    return null;
  }

  Future<void> _saveImportHistory(Semester semester) async {
    final savedAt = DateTime.now();
    final historyEntry = ImportHistoryEntry(
      id: savedAt.microsecondsSinceEpoch.toString(),
      sourceFileName: widget.arguments.draft.sourceFileName,
      sourceType: widget.arguments.draft.sourceType,
      semesterName: semester.name,
      courseCount: semester.courses.length,
      warningCount: widget.arguments.draft.warnings.length,
      importedAt: savedAt,
    );

    try {
      await _historyRepository.saveHistoryEntry(historyEntry);
    } catch (_) {
      // Import history is supplemental; saving the semester remains the priority.
    }
  }

  Semester _buildSemester(
    List<ParsedCourse> courses,
    ScheduleSettings settings,
  ) {
    final now = DateTime.now();
    final sectionTimes = widget.arguments.draft.suggestedSectionTimes.isEmpty
        ? List<SectionTime>.of(settings.sectionTimes)
        : List<SectionTime>.of(widget.arguments.draft.suggestedSectionTimes);
    final courseEntities = <Course>[
      for (var index = 0; index < courses.length; index++)
        // Prefer source-derived time slots when the import file contains them.
        Course(
          id: '${now.microsecondsSinceEpoch}_$index',
          name: courses[index].name.trim(),
          teacher: courses[index].teacher,
          location: courses[index].location,
          weekday: courses[index].weekday!,
          startSection: courses[index].startSection!,
          endSection: courses[index].endSection!,
          startTime:
              _slotForSection(
                sectionTimes,
                courses[index].startSection!,
              )?.startTime ??
              settings.startTimeForSection(courses[index].startSection!),
          endTime:
              _slotForSection(
                sectionTimes,
                courses[index].endSection!,
              )?.endTime ??
              settings.endTimeForSection(courses[index].endSection!),
          weeks: courses[index].weeks,
          colorValue: _courseColor(courses[index].name),
          note: courses[index].note,
        ),
    ];

    final totalWeeks = courseEntities.fold<int>(
      1,
      (current, course) => course.weeks.isEmpty
          ? current
          : course.weeks.last > current
          ? course.weeks.last
          : current,
    );

    return Semester(
      id: now.microsecondsSinceEpoch.toString(),
      name: settings.semesterName.trim(),
      termStartDate: DateTime(
        settings.termStartDate.year,
        settings.termStartDate.month,
        settings.termStartDate.day,
      ),
      totalWeeks: totalWeeks,
      courses: courseEntities,
      sectionTimes: sectionTimes,
    );
  }

  SectionTime? _slotForSection(List<SectionTime> sectionTimes, int section) {
    for (final slot in sectionTimes) {
      if (slot.containsSection(section)) {
        return slot;
      }
    }

    return null;
  }

  int _courseColor(String name) {
    const palette = <int>[
      0xFF7CB7FF,
      0xFF8ACB88,
      0xFFFFA860,
      0xFFF785A3,
      0xFF74D4C0,
      0xFFB79BFF,
    ];

    return palette[name.hashCode.abs() % palette.length];
  }
}

class _CourseDraftCard extends StatelessWidget {
  const _CourseDraftCard({
    required this.course,
    required this.isConflict,
    required this.onEdit,
    required this.onDelete,
  });

  final ParsedCourse course;
  final bool isConflict;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final weekdayText = AppConstants.weekdayLabel(course.weekday);
    final sectionsText =
        course.startSection == null || course.endSection == null
        ? '节次待确认'
        : '第 ${course.startSection}-${course.endSection} 节';

    return AppCard(
      color: isConflict ? const Color(0xFFFFF8F8) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  course.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (isConflict)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE1E1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '冲突',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                tooltip: '编辑',
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: '删除',
              ),
            ],
          ),
          const SizedBox(height: 6),
          _InfoLine(label: '时间', value: '$weekdayText · $sectionsText'),
          const SizedBox(height: 6),
          _InfoLine(label: '地点', value: course.location ?? '待补充'),
          const SizedBox(height: 6),
          _InfoLine(label: '教师', value: course.teacher ?? '待补充'),
          const SizedBox(height: 6),
          _InfoLine(label: '周数', value: weeksToText(course.weeks)),
          if (course.note != null && course.note!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _InfoLine(label: '备注', value: course.note!),
          ],
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 42,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _WarningText extends StatelessWidget {
  const _WarningText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 3),
          child: Icon(Icons.warning_amber_rounded, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
