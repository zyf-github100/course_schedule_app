import 'package:course_schedule_app/app/routes.dart';
import 'package:course_schedule_app/features/import/domain/entities/import_file.dart';
import 'package:course_schedule_app/features/import/domain/entities/import_source_type.dart';
import 'package:course_schedule_app/features/import/presentation/controllers/import_controller.dart';
import 'package:course_schedule_app/features/import/presentation/pages/import_review_page.dart';
import 'package:course_schedule_app/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';

class ImportParsingArguments {
  const ImportParsingArguments({required this.file});

  final ImportFile file;
}

class ImportParsingPage extends StatefulWidget {
  const ImportParsingPage({super.key, required this.arguments});

  final ImportParsingArguments arguments;

  @override
  State<ImportParsingPage> createState() => _ImportParsingPageState();
}

class _ImportParsingPageState extends State<ImportParsingPage> {
  final ImportController _controller = ImportController();
  int _currentStep = 0;
  String? _errorMessage;

  List<String> get _steps {
    if (widget.arguments.file.sourceType == ImportSourceType.excel) {
      return const <String>['正在读取工作表', '正在分析表头与节次', '正在整理课程字段', '正在生成确认草稿'];
    }

    return const <String>['正在读取 PDF 文件', '正在提取文本内容', '正在匹配课程字段', '正在生成确认草稿'];
  }

  @override
  void initState() {
    super.initState();
    _runParsing();
  }

  Future<void> _runParsing() async {
    try {
      for (var index = 0; index < _steps.length - 1; index++) {
        if (!mounted) {
          return;
        }

        setState(() {
          _currentStep = index;
        });

        await Future<void>.delayed(const Duration(milliseconds: 650));
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _currentStep = _steps.length - 1;
      });

      final draft = await _controller.createDraft(widget.arguments.file);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacementNamed(
        AppRoutes.importReview,
        arguments: ImportReviewArguments(draft: draft),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = _readableErrorMessage(error);
      });
    }
  }

  String _readableErrorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('FormatException: ')) {
      return message.substring('FormatException: '.length);
    }

    return '解析流程执行失败，请返回重试。';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / _steps.length;

    return Scaffold(
      appBar: AppBar(title: const Text('解析中')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.arguments.file.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('文件类型：${widget.arguments.file.sourceType.label}'),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: _errorMessage == null ? progress : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _errorMessage ?? _steps[_currentStep],
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage == null
                        ? widget.arguments.file.sourceType ==
                                  ImportSourceType.excel
                              ? 'Excel 会尝试按规整课表格式做真实解析。'
                              : 'PDF 会尝试提取文本型 PDF 内容；扫描版通常会失败。'
                        : '你可以返回导入页重新选择文件。',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                itemCount: _steps.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final isDone = index < _currentStep && _errorMessage == null;
                  final isActive =
                      index == _currentStep && _errorMessage == null;

                  return AppCard(
                    color: Colors.white,
                    child: Row(
                      children: [
                        _StepIndicator(
                          isDone: isDone,
                          isActive: isActive,
                          isFailed:
                              _errorMessage != null && index == _currentStep,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _steps[index],
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.isDone,
    required this.isActive,
    required this.isFailed,
  });

  final bool isDone;
  final bool isActive;
  final bool isFailed;

  @override
  Widget build(BuildContext context) {
    final color = isFailed
        ? Colors.redAccent
        : isDone || isActive
        ? Theme.of(context).colorScheme.primary
        : Colors.black26;
    final icon = isFailed
        ? Icons.close_rounded
        : isDone
        ? Icons.check_rounded
        : Icons.more_horiz_rounded;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color),
    );
  }
}
