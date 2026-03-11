import 'package:course_schedule_app/core/constants/app_constants.dart';
import 'package:course_schedule_app/core/utils/parser_utils.dart';
import 'package:course_schedule_app/features/import/domain/entities/parsed_course.dart';
import 'package:flutter/material.dart';

class ParsedCourseForm extends StatefulWidget {
  const ParsedCourseForm({super.key, this.initialCourse});

  final ParsedCourse? initialCourse;

  @override
  State<ParsedCourseForm> createState() => _ParsedCourseFormState();
}

class _ParsedCourseFormState extends State<ParsedCourseForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _teacherController;
  late final TextEditingController _locationController;
  late final TextEditingController _startSectionController;
  late final TextEditingController _endSectionController;
  late final TextEditingController _weeksController;
  late final TextEditingController _noteController;
  int? _weekday;

  @override
  void initState() {
    super.initState();
    final course = widget.initialCourse;
    _nameController = TextEditingController(text: course?.name ?? '');
    _teacherController = TextEditingController(text: course?.teacher ?? '');
    _locationController = TextEditingController(text: course?.location ?? '');
    _startSectionController = TextEditingController(
      text: course?.startSection?.toString() ?? '',
    );
    _endSectionController = TextEditingController(
      text: course?.endSection?.toString() ?? '',
    );
    _weeksController = TextEditingController(
      text: weeksToText(course?.weeks ?? const <int>[]),
    );
    _noteController = TextEditingController(text: course?.note ?? '');
    _weekday = course?.weekday;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _locationController.dispose();
    _startSectionController.dispose();
    _endSectionController.dispose();
    _weeksController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final startSection = int.tryParse(_startSectionController.text.trim());
    final endSection = int.tryParse(_endSectionController.text.trim());

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('课程名称不能为空')));
      return;
    }

    if (startSection != null &&
        endSection != null &&
        endSection < startSection) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('结束节次不能小于开始节次')));
      return;
    }

    Navigator.of(context).pop(
      ParsedCourse(
        name: name,
        teacher: _teacherController.text.trim().isEmpty
            ? null
            : _teacherController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        weekday: _weekday,
        startSection: startSection,
        endSection: endSection,
        weeks: parseWeeksInput(_weeksController.text),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.initialCourse == null ? '新增课程' : '编辑课程',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '课程名称'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _weekday,
              decoration: const InputDecoration(labelText: '星期'),
              items: List<DropdownMenuItem<int>>.generate(
                AppConstants.weekdays.length,
                (index) => DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text(AppConstants.weekdays[index]),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _weekday = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startSectionController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '开始节次'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _endSectionController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '结束节次'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _teacherController,
              decoration: const InputDecoration(labelText: '教师'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: '地点'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _weeksController,
              decoration: const InputDecoration(
                labelText: '周数',
                hintText: '例如：1、2、3、4',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: '备注'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('保存课程'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
