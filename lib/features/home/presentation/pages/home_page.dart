import 'package:course_schedule_app/app/routes.dart';
import 'package:course_schedule_app/core/constants/app_constants.dart';
import 'package:course_schedule_app/features/home/presentation/widgets/quick_import_card.dart';
import 'package:course_schedule_app/features/home/presentation/widgets/today_course_card.dart';
import 'package:course_schedule_app/features/import/data/repositories/import_history_repository_impl.dart';
import 'package:course_schedule_app/features/import/domain/entities/import_history_entry.dart';
import 'package:course_schedule_app/features/import/domain/entities/import_source_type.dart';
import 'package:course_schedule_app/features/import/domain/repositories/import_history_repository.dart';
import 'package:course_schedule_app/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:course_schedule_app/features/schedule/domain/entities/course.dart';
import 'package:course_schedule_app/features/schedule/domain/entities/semester.dart';
import 'package:course_schedule_app/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:course_schedule_app/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.repository, this.importHistoryRepository});

  final ScheduleRepository? repository;
  final ImportHistoryRepository? importHistoryRepository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ScheduleRepository _repository;
  late final ImportHistoryRepository _importHistoryRepository;
  late Future<Semester?> _semesterFuture;
  late Future<List<ImportHistoryEntry>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ScheduleRepositoryImpl();
    _importHistoryRepository =
        widget.importHistoryRepository ?? ImportHistoryRepositoryImpl();
    _semesterFuture = _repository.loadCurrentSemester();
    _historyFuture = _importHistoryRepository.loadHistory();
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).pushNamed(AppRoutes.settings);

    if (!mounted) {
      return;
    }

    setState(() {
      _semesterFuture = _repository.loadCurrentSemester();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const _HomeBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2B6A54), Color(0xFF5D95D6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x18245A45),
                              blurRadius: 24,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '课程表助手',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '把导入、确认和查看课表收进同一套更清晰的界面。',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: _openSettings,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.88),
                          foregroundColor: const Color(0xFF1B2E24),
                        ),
                        icon: const Icon(Icons.tune_rounded),
                        tooltip: '学期设置',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF24543E), Color(0xFF79A7D9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderColor: Colors.white.withValues(alpha: 0.18),
                    borderRadius: 32,
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Semester Flow',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    '流程可用',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          '导入、修正、保存，再快速回到今天的课程。',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'PDF / Excel 已接通，本地保存、多学期和日视图也都在主链路里。',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.86),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: const [
                            _HomeStatPill(
                              icon: Icons.picture_as_pdf_rounded,
                              label: 'PDF / Excel',
                            ),
                            _HomeStatPill(
                              icon: Icons.save_outlined,
                              label: '本地保存',
                            ),
                            _HomeStatPill(
                              icon: Icons.calendar_view_day_rounded,
                              label: '日 / 周视图',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed(AppRoutes.importEntry);
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF1F4A37),
                                ),
                                icon: const Icon(Icons.file_open_rounded),
                                label: const Text('立即导入'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed(AppRoutes.schedule);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.42),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                icon: const Icon(Icons.grid_view_rounded),
                                label: const Text('查看课表'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  const _SectionHeader(
                    title: '快速开始',
                    subtitle: '从导入入口进入，先把课表带进应用里。',
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: QuickImportCard(
                          icon: Icons.picture_as_pdf_rounded,
                          title: '导入 PDF',
                          subtitle: '适合已有教务导出课表\n文本型 PDF 优先',
                          color: const Color(0xFFFFF0E8),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.importEntry,
                              arguments: ImportSourceType.pdf,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickImportCard(
                          icon: Icons.table_view_rounded,
                          title: '导入 Excel',
                          subtitle: '适合规整课程表模板\n识别链路更稳定',
                          color: const Color(0xFFE9F5EC),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.importEntry,
                              arguments: ImportSourceType.excel,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const _SectionHeader(
                    title: '我的课表',
                    subtitle: '这里显示当前学期，以及本周最需要看的课程。',
                  ),
                  const SizedBox(height: 14),
                  FutureBuilder<Semester?>(
                    future: _semesterFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const AppCard(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      }

                      final semester = snapshot.data;
                      if (semester == null) {
                        return AppCard(
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F6F1),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Icon(
                                  Icons.calendar_month_outlined,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                '还没有已保存的课表',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '从 Excel 或 PDF 导入并完成确认后，这里会展示真实课表。',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.importEntry,
                                    arguments: ImportSourceType.excel,
                                  );
                                },
                                icon: const Icon(Icons.upload_file_rounded),
                                label: const Text('立即导入'),
                              ),
                            ],
                          ),
                        );
                      }

                      final currentWeek = _currentWeekOfSemester(semester);
                      final courses = List<Course>.of(semester.courses)
                        ..sort((a, b) {
                          final weekdayCompare = a.weekday.compareTo(b.weekday);
                          if (weekdayCompare != 0) {
                            return weekdayCompare;
                          }

                          return a.startSection.compareTo(b.startSection);
                        });
                      final currentWeekCourses = courses
                          .where((course) => course.weeks.contains(currentWeek))
                          .take(3)
                          .toList();

                      return AppCard(
                        borderRadius: 30,
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        semester.name,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '第 $currentWeek 周 · 共 ${semester.courses.length} 门课程',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pushNamed(AppRoutes.schedule);
                                  },
                                  icon: const Icon(Icons.grid_view_rounded),
                                  label: const Text('完整课表'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFF5F8F2),
                                    Color(0xFFF7FBFD),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _MiniMetric(
                                      label: '当前周',
                                      value: '$currentWeek',
                                    ),
                                  ),
                                  Expanded(
                                    child: _MiniMetric(
                                      label: '节次配置',
                                      value: '${semester.sectionTimes.length}',
                                    ),
                                  ),
                                  Expanded(
                                    child: _MiniMetric(
                                      label: '视图状态',
                                      value: '已保存',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (currentWeekCourses.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7FAF8),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Text(
                                  '当前周没有课程数据，可能需要在确认页补充周数或切换到其他周查看。',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              )
                            else
                              for (
                                var i = 0;
                                i < currentWeekCourses.length;
                                i++
                              ) ...[
                                TodayCourseCard(
                                  name: currentWeekCourses[i].name,
                                  time: _courseTimeText(
                                    currentWeekCourses[i],
                                    semester,
                                  ),
                                  location:
                                      currentWeekCourses[i].location ?? '地点待定',
                                  color: Color(
                                    currentWeekCourses[i].colorValue,
                                  ),
                                ),
                                if (i != currentWeekCourses.length - 1)
                                  const SizedBox(height: 10),
                              ],
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  const _SectionHeader(
                    title: '最近导入',
                    subtitle: '每次成功保存课表后，这里都会保留最近的导入结果。',
                  ),
                  const SizedBox(height: 14),
                  FutureBuilder<List<ImportHistoryEntry>>(
                    future: _historyFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const AppCard(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      }

                      final historyEntries =
                          snapshot.data ?? const <ImportHistoryEntry>[];
                      if (historyEntries.isEmpty) {
                        return AppCard(
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F6F1),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Icon(
                                  Icons.history_rounded,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                '还没有最近导入记录',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '课表保存成功后，这里会展示来源文件、保存学期和课程数量。',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      }

                      return AppCard(
                        borderRadius: 30,
                        child: Column(
                          children: [
                            for (
                              var i = 0;
                              i < historyEntries.length && i < 3;
                              i++
                            ) ...[
                              _ImportHistoryTile(
                                entry: historyEntries[i],
                                timeText: _formatImportTime(
                                  historyEntries[i].importedAt,
                                ),
                              ),
                              if (i != historyEntries.length - 1 && i < 2)
                                const SizedBox(height: 12),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  const _SectionHeader(
                    title: '当前推进',
                    subtitle: '核心主链路已可用，下面这些能力已经接通。',
                  ),
                  const SizedBox(height: 14),
                  const _ProgressTile(
                    icon: Icons.account_tree_outlined,
                    title: '工程结构已拆分',
                    subtitle: '路由、主题、features 以及数据层已经独立。',
                  ),
                  const SizedBox(height: 10),
                  const _ProgressTile(
                    icon: Icons.table_chart_outlined,
                    title: '导入链路已打通',
                    subtitle: 'Excel / PDF 都能进入确认页并做规则解析。',
                  ),
                  const SizedBox(height: 10),
                  const _ProgressTile(
                    icon: Icons.save_outlined,
                    title: '本地保存与多学期已接入',
                    subtitle: '确认后的课表会持久化，并支持切换当前学期。',
                  ),
                  const SizedBox(height: 10),
                  const _ProgressTile(
                    icon: Icons.calendar_view_day_rounded,
                    title: '课表视图已完善',
                    subtitle: '支持周视图、日视图、冲突提示和详情查看。',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _currentWeekOfSemester(Semester semester) {
    final start = DateTime(
      semester.termStartDate.year,
      semester.termStartDate.month,
      semester.termStartDate.day,
    );
    final now = DateTime.now();
    final difference = now.difference(start).inDays;
    final week = difference < 0 ? 1 : (difference ~/ 7) + 1;
    return week.clamp(1, semester.totalWeeks);
  }

  String _courseTimeText(Course course, Semester semester) {
    final sectionLabel =
        '${AppConstants.weekdayLabel(course.weekday)} ${course.startSection}-${course.endSection}节';
    final startTime =
        course.startTime ?? _startTimeForSection(semester, course.startSection);
    final endTime =
        course.endTime ?? _endTimeForSection(semester, course.endSection);
    if (startTime != null && endTime != null) {
      return '${AppConstants.weekdayLabel(course.weekday)} $startTime-$endTime';
    }

    return sectionLabel;
  }

  String? _startTimeForSection(Semester semester, int section) {
    for (final slot in semester.sectionTimes) {
      if (section >= slot.startSection && section <= slot.endSection) {
        return slot.startTime;
      }
    }

    return null;
  }

  String? _endTimeForSection(Semester semester, int section) {
    for (final slot in semester.sectionTimes) {
      if (section >= slot.startSection && section <= slot.endSection) {
        return slot.endTime;
      }
    }

    return null;
  }

  String _formatImportTime(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$month-$day $hour:$minute';
  }
}

class _HomeBackdrop extends StatelessWidget {
  const _HomeBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -40,
            child: _BackdropOrb(
              size: 220,
              colors: const [Color(0x332D6B54), Color(0x1479A7D9)],
            ),
          ),
          Positioned(
            top: 180,
            left: -70,
            child: _BackdropOrb(
              size: 180,
              colors: const [Color(0x18F4A261), Color(0x12FFDCC2)],
            ),
          ),
          Positioned(
            bottom: 60,
            right: -60,
            child: _BackdropOrb(
              size: 240,
              colors: const [Color(0x166FAEDB), Color(0x102D6B54)],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackdropOrb extends StatelessWidget {
  const _BackdropOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _HomeStatPill extends StatelessWidget {
  const _HomeStatPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ProgressTile extends StatelessWidget {
  const _ProgressTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2EAE3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEAF3EC), Color(0xFFE8F1F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF24543E)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF24543E),
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _ImportHistoryTile extends StatelessWidget {
  const _ImportHistoryTile({required this.entry, required this.timeText});

  final ImportHistoryEntry entry;
  final String timeText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = entry.sourceType == ImportSourceType.excel
        ? const Color(0xFF2C7A4B)
        : const Color(0xFFC8682D);
    final backgroundColor = entry.sourceType == ImportSourceType.excel
        ? const Color(0xFFEAF6EE)
        : const Color(0xFFFFF2E8);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2EAE3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              entry.sourceType == ImportSourceType.excel
                  ? Icons.table_view_rounded
                  : Icons.picture_as_pdf_rounded,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.sourceFileName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${entry.semesterName} · $timeText',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HistoryPill(
                      icon: Icons.folder_outlined,
                      label: entry.sourceType.label,
                    ),
                    _HistoryPill(
                      icon: Icons.menu_book_rounded,
                      label: '${entry.courseCount} 门课程',
                    ),
                    _HistoryPill(
                      icon: Icons.warning_amber_rounded,
                      label: '${entry.warningCount} 条提醒',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryPill extends StatelessWidget {
  const _HistoryPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF607469)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
