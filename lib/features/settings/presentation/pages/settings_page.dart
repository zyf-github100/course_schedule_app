import 'package:course_schedule_app/app/routes.dart';
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

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    this.scheduleRepository,
    this.settingsRepository,
  });

  final ScheduleRepository? scheduleRepository;
  final ScheduleSettingsRepository? settingsRepository;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _semesterNameController = TextEditingController();
  late final ScheduleRepository _scheduleRepository;
  late final ScheduleSettingsRepository _settingsRepository;
  List<Semester> _semesters = const <Semester>[];
  List<SectionTime> _sectionTimes = const <SectionTime>[];
  DateTime? _termStartDate;
  String? _currentSemesterId;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isManagingSemesters = false;

  @override
  void initState() {
    super.initState();
    _scheduleRepository = widget.scheduleRepository ?? ScheduleRepositoryImpl();
    _settingsRepository =
        widget.settingsRepository ?? ScheduleSettingsRepositoryImpl();
    _loadPageData();
  }

  @override
  void dispose() {
    _semesterNameController.dispose();
    super.dispose();
  }

  Future<void> _loadPageData() async {
    final settings = await _settingsRepository.loadSettings();
    final semesters = await _scheduleRepository.loadSemesters();
    final currentSemester = await _scheduleRepository.loadCurrentSemester();

    if (!mounted) {
      return;
    }

    final activeSemester = currentSemester;
    setState(() {
      _semesters = semesters;
      _currentSemesterId = activeSemester?.id;
      _semesterNameController.text =
          activeSemester?.name ?? settings.semesterName;
      _termStartDate = _dateOnly(
        activeSemester?.termStartDate ?? settings.termStartDate,
      );
      _sectionTimes = List<SectionTime>.from(
        activeSemester?.sectionTimes ?? settings.sectionTimes,
      );
      _isLoading = false;
    });
  }

  Future<void> _pickTermStartDate() async {
    final initialDate = _termStartDate ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2035, 12, 31),
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() {
      _termStartDate = _dateOnly(pickedDate);
    });
  }

  Future<void> _pickTime({
    required int index,
    required bool isStartTime,
  }) async {
    final slot = _sectionTimes[index];
    final initialTime = _parseTimeOfDay(
      isStartTime ? slot.startTime : slot.endTime,
    );

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (pickedTime == null || !mounted) {
      return;
    }

    setState(() {
      _sectionTimes[index] = slot.copyWith(
        startTime: isStartTime ? _formatTimeOfDay(pickedTime) : null,
        endTime: isStartTime ? null : _formatTimeOfDay(pickedTime),
      );
    });
  }

  Future<void> _saveSettings() async {
    final validationError = _validateSettings();
    if (validationError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final settings = _settingsFromForm();

    try {
      await _settingsRepository.saveSettings(settings);

      final currentSemester = await _scheduleRepository.loadCurrentSemester();
      if (currentSemester != null) {
        final updatedSemester = currentSemester.copyWith(
          name: settings.semesterName,
          termStartDate: settings.termStartDate,
          sectionTimes: List<SectionTime>.from(settings.sectionTimes),
          courses: _applySettingsToCourses(currentSemester.courses, settings),
        );
        await _scheduleRepository.saveSemester(updatedSemester);
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('设置保存失败，请稍后重试。')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _switchSemester(Semester semester) async {
    setState(() {
      _isManagingSemesters = true;
    });

    try {
      await _scheduleRepository.setCurrentSemester(semester.id);
      await _settingsRepository.saveSettings(_settingsFromSemester(semester));

      if (!mounted) {
        return;
      }

      await _loadPageData();
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已切换到 ${semester.name}。')));
    } finally {
      if (mounted) {
        setState(() {
          _isManagingSemesters = false;
        });
      }
    }
  }

  Future<void> _deleteSemester(Semester semester) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('删除学期'),
              content: Text('“${semester.name}”会从本地移除，确定继续吗？'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('删除'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    setState(() {
      _isManagingSemesters = true;
    });

    try {
      await _scheduleRepository.deleteSemester(semester.id);
      final currentSemester = await _scheduleRepository.loadCurrentSemester();
      if (currentSemester != null) {
        await _settingsRepository.saveSettings(
          _settingsFromSemester(currentSemester),
        );
      }

      if (!mounted) {
        return;
      }

      await _loadPageData();
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已删除 ${semester.name}。')));
    } finally {
      if (mounted) {
        setState(() {
          _isManagingSemesters = false;
        });
      }
    }
  }

  List<Course> _applySettingsToCourses(
    List<Course> courses,
    ScheduleSettings settings,
  ) {
    return courses
        .map(
          (course) => course.copyWith(
            startTime: settings.startTimeForSection(course.startSection),
            endTime: settings.endTimeForSection(course.endSection),
          ),
        )
        .toList();
  }

  ScheduleSettings _settingsFromForm() {
    return ScheduleSettings(
      semesterName: _semesterNameController.text.trim(),
      termStartDate: _dateOnly(_termStartDate!),
      sectionTimes: List<SectionTime>.from(_sectionTimes),
    );
  }

  ScheduleSettings _settingsFromSemester(Semester semester) {
    return ScheduleSettings(
      semesterName: semester.name,
      termStartDate: _dateOnly(semester.termStartDate),
      sectionTimes: List<SectionTime>.from(semester.sectionTimes),
    );
  }

  String? _validateSettings() {
    if (_semesterNameController.text.trim().isEmpty) {
      return '请先填写学期名称。';
    }

    if (_termStartDate == null) {
      return '请先选择开学日期。';
    }

    var previousEnd = -1;
    for (final slot in _sectionTimes) {
      final startMinutes = _minutesOfDay(slot.startTime);
      final endMinutes = _minutesOfDay(slot.endTime);
      if (startMinutes >= endMinutes) {
        return '${slot.label} 的开始时间必须早于结束时间。';
      }
      if (previousEnd >= 0 && startMinutes < previousEnd) {
        return '${slot.label} 的开始时间不能早于上一节的结束时间。';
      }
      previousEnd = endMinutes;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('学期设置')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '已保存学期',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _semesters.isEmpty
                            ? '当前还没有已保存学期。导入后会自动生成学期，并出现在这里。'
                            : '切换学期后，上面的学期名称、开学日期和节次时间会自动切换到该学期。',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_semesters.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAF8),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Text(
                            '还没有学期数据，先去导入课表即可。',
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        for (var i = 0; i < _semesters.length; i++) ...[
                          _SemesterTile(
                            semester: _semesters[i],
                            isCurrent: _semesters[i].id == _currentSemesterId,
                            isBusy: _isManagingSemesters,
                            onSwitch: () => _switchSemester(_semesters[i]),
                            onDelete: () => _deleteSemester(_semesters[i]),
                            dateText: _formatDate(_semesters[i].termStartDate),
                          ),
                          if (i != _semesters.length - 1)
                            const SizedBox(height: 12),
                        ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '当前学期配置',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _currentSemesterId == null
                            ? '当前没有选中的学期，保存后会把这些配置作为下次导入时的默认值。'
                            : '保存后会更新当前选中学期，并同步影响首页和课表页展示。',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _semesterNameController,
                        decoration: const InputDecoration(
                          labelText: '学期名称',
                          hintText: '例如：2026年春季学期',
                        ),
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: _pickTermStartDate,
                        borderRadius: BorderRadius.circular(18),
                        child: Ink(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAF8),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event_rounded),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '开学日期',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.black54),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDate(_termStartDate!),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '每节课时间',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '这里的时间会用于当前学期课表网格展示，以及导入后课程时间的补全。',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (var i = 0; i < _sectionTimes.length; i++) ...[
                        _SectionTimeTile(
                          slot: _sectionTimes[i],
                          onPickStartTime: () {
                            _pickTime(index: i, isStartTime: true);
                          },
                          onPickEndTime: () {
                            _pickTime(index: i, isStartTime: false);
                          },
                        ),
                        if (i != _sectionTimes.length - 1)
                          const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  color: const Color(0xFFF7FAF8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '导入管理',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '重新导入会进入导入入口，并在确认后生成新的学期数据。旧学期会保留在上面的列表中，可随时切换回来。',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.importEntry);
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('导入新学期'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomSheet: _isLoading
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveSettings,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isSaving ? '保存中...' : '保存设置'),
                ),
              ),
            ),
    );
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String _formatDate(DateTime value) {
    return '${value.year}-${_twoDigits(value.month)}-${_twoDigits(value.day)}';
  }

  TimeOfDay _parseTimeOfDay(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTimeOfDay(TimeOfDay value) {
    return '${_twoDigits(value.hour)}:${_twoDigits(value.minute)}';
  }

  int _minutesOfDay(String value) {
    final parts = value.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return (hour * 60) + minute;
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}

class _SemesterTile extends StatelessWidget {
  const _SemesterTile({
    required this.semester,
    required this.isCurrent,
    required this.isBusy,
    required this.onSwitch,
    required this.onDelete,
    required this.dateText,
  });

  final Semester semester;
  final bool isCurrent;
  final bool isBusy;
  final VoidCallback onSwitch;
  final VoidCallback onDelete;
  final String dateText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrent ? const Color(0xFF7BB8FF) : const Color(0xFFE5EFE9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  semester.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8EE),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '当前学期',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$dateText · ${semester.totalWeeks} 周 · ${semester.courses.length} 门课程',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (!isCurrent)
                FilledButton.tonalIcon(
                  onPressed: isBusy ? null : onSwitch,
                  icon: const Icon(Icons.swap_horiz_rounded),
                  label: const Text('切换到这里'),
                ),
              if (!isCurrent) const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: isBusy ? null : onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('删除'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTimeTile extends StatelessWidget {
  const _SectionTimeTile({
    required this.slot,
    required this.onPickStartTime,
    required this.onPickEndTime,
  });

  final SectionTime slot;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EFE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            slot.label,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TimeButton(
                  label: '开始时间',
                  value: slot.startTime,
                  onTap: onPickStartTime,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeButton(
                  label: '结束时间',
                  value: slot.endTime,
                  onTap: onPickEndTime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAF8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
