import 'package:course_schedule_app/features/schedule/domain/entities/semester.dart';

abstract class ScheduleRepository {
  Future<Semester?> loadCurrentSemester();

  Future<List<Semester>> loadSemesters();

  Future<void> saveSemester(Semester semester);

  Future<void> setCurrentSemester(String semesterId);

  Future<void> deleteSemester(String semesterId);

  Future<void> clearCurrentSemester();
}
