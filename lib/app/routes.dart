import 'package:course_schedule_app/features/home/presentation/pages/home_page.dart';
import 'package:course_schedule_app/features/import/domain/entities/import_source_type.dart';
import 'package:course_schedule_app/features/import/presentation/pages/import_entry_page.dart';
import 'package:course_schedule_app/features/import/presentation/pages/import_parsing_page.dart';
import 'package:course_schedule_app/features/import/presentation/pages/import_review_page.dart';
import 'package:course_schedule_app/features/schedule/presentation/pages/schedule_page.dart';
import 'package:course_schedule_app/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const home = '/';
  static const schedule = '/schedule';
  static const settings = '/settings';
  static const importEntry = '/import';
  static const importParsing = '/import/parsing';
  static const importReview = '/import/review';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _buildRoute(const HomePage(), settings);
      case schedule:
        return _buildRoute(const SchedulePage(), settings);
      case AppRoutes.settings:
        return _buildRoute(const SettingsPage(), settings);
      case importEntry:
        final preferredSource = settings.arguments is ImportSourceType
            ? settings.arguments! as ImportSourceType
            : null;
        return _buildRoute(
          ImportEntryPage(preferredSource: preferredSource),
          settings,
        );
      case importParsing:
        final args = settings.arguments is ImportParsingArguments
            ? settings.arguments! as ImportParsingArguments
            : null;
        if (args == null) {
          return _buildRoute(
            const _RouteErrorPage(message: '缺少导入文件信息，无法进入解析流程。'),
            settings,
          );
        }
        return _buildRoute(ImportParsingPage(arguments: args), settings);
      case importReview:
        final args = settings.arguments is ImportReviewArguments
            ? settings.arguments! as ImportReviewArguments
            : null;
        if (args == null) {
          return _buildRoute(
            const _RouteErrorPage(message: '缺少导入草稿，无法进入确认页面。'),
            settings,
          );
        }
        return _buildRoute(ImportReviewPage(arguments: args), settings);
      default:
        return _buildRoute(
          _RouteErrorPage(message: '未找到路由：${settings.name}'),
          settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    Widget child,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<void>(settings: settings, builder: (_) => child);
  }
}

class _RouteErrorPage extends StatelessWidget {
  const _RouteErrorPage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('页面错误')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
