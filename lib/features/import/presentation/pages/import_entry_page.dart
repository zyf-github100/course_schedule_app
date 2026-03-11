import 'package:course_schedule_app/app/routes.dart';
import 'package:course_schedule_app/features/import/domain/entities/import_source_type.dart';
import 'package:course_schedule_app/features/import/presentation/controllers/import_controller.dart';
import 'package:course_schedule_app/features/import/presentation/pages/import_parsing_page.dart';
import 'package:course_schedule_app/features/import/presentation/widgets/import_source_card.dart';
import 'package:course_schedule_app/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';

class ImportEntryPage extends StatefulWidget {
  const ImportEntryPage({super.key, this.preferredSource});

  final ImportSourceType? preferredSource;

  @override
  State<ImportEntryPage> createState() => _ImportEntryPageState();
}

class _ImportEntryPageState extends State<ImportEntryPage> {
  final ImportController _controller = ImportController();
  bool _isPicking = false;

  Future<void> _pickFile(ImportSourceType sourceType) async {
    setState(() {
      _isPicking = true;
    });

    try {
      final selectedFile = await _controller.pickFile(sourceType);

      if (!mounted) {
        return;
      }

      if (selectedFile == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('你取消了文件选择。')));
        return;
      }

      Navigator.of(context).pushNamed(
        AppRoutes.importParsing,
        arguments: ImportParsingArguments(file: selectedFile),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('文件选择失败，请稍后重试。')));
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sources = <ImportSourceType>[
      ImportSourceType.excel,
      ImportSourceType.pdf,
    ];

    if (widget.preferredSource != null) {
      sources.remove(widget.preferredSource);
      sources.insert(0, widget.preferredSource!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('导入课表')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '流程已接通到确认页',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '这一步已经接入真实文件选择。Excel 会按规整课表解析，PDF 会尝试提取文本型 PDF 内容。',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.6),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        _ProcessChip(index: 1, label: '选文件'),
                        _ProcessChip(index: 2, label: '解析中'),
                        _ProcessChip(index: 3, label: '确认结果'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              for (var i = 0; i < sources.length; i++) ...[
                ImportSourceCard(
                  sourceType: sources[i],
                  isRecommended: sources[i] == ImportSourceType.excel,
                  onTap: () => _pickFile(sources[i]),
                ),
                if (i != sources.length - 1) const SizedBox(height: 14),
              ],
              const SizedBox(height: 18),
              AppCard(
                color: const Color(0xFFEEF7FF),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前阶段说明',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const _BulletText(text: 'Excel 已接入第一版真实解析，优先支持规整表头格式。'),
                    const SizedBox(height: 8),
                    const _BulletText(
                      text: 'PDF 已接入文本提取 MVP，扫描版或图片型 PDF 仍可能失败。',
                    ),
                    const SizedBox(height: 8),
                    const _BulletText(text: '确认页已支持编辑、删除、新增课程草稿。'),
                  ],
                ),
              ),
            ],
          ),
          if (_isPicking)
            ColoredBox(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _ProcessChip extends StatelessWidget {
  const _ProcessChip({required this.index, required this.label});

  final int index;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$index. $label',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  const _BulletText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 8),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }
}
