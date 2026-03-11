import 'package:course_schedule_app/features/settings/domain/entities/schedule_settings.dart';

abstract class ScheduleSettingsRepository {
  Future<ScheduleSettings> loadSettings();

  Future<void> saveSettings(ScheduleSettings settings);
}
