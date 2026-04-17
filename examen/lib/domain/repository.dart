import 'entities.dart';

abstract class AppRepository {
  Future<List<Course>> getCourses({String query = ''});
  Future<List<StudentProgress>> getProgress();
  Stream<List<StudentProgress>> watchProgress();
  Future<void> updateProgress(int courseId, int delta);
}
