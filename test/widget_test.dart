import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:course_schedule_app/app/app.dart';
import 'package:course_schedule_app/features/import/data/local/import_history_local_datasource.dart';

void main() {
  testWidgets('app shows course schedule assistant home', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ImportHistoryLocalDataSource.historyKey: jsonEncode(<Map<String, Object>>[
        <String, Object>{
          'id': 'history-1',
          'sourceFileName': '2026春季课表.xlsx',
          'sourceType': 'excel',
          'semesterName': '2026年春季学期',
          'courseCount': 18,
          'warningCount': 1,
          'importedAt': DateTime(2026, 3, 11, 8, 30).toIso8601String(),
        },
      ]),
    });

    await tester.pumpWidget(const CourseScheduleApp());
    await tester.pumpAndSettle();

    expect(find.text('课程表助手'), findsOneWidget);
    expect(find.text('导入 PDF'), findsOneWidget);
    expect(find.text('导入 Excel'), findsOneWidget);
    expect(find.text('我的课表'), findsOneWidget);
    expect(find.text('最近导入'), findsOneWidget);
    expect(find.text('2026春季课表.xlsx'), findsOneWidget);
  });
}
