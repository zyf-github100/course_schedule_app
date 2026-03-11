import 'package:course_schedule_app/app/routes.dart';
import 'package:course_schedule_app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CourseScheduleApp extends StatelessWidget {
  const CourseScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '课程表',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
