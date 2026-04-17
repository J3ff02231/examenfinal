import 'entities.dart';
import 'repository.dart';

class GetCourses {
  const GetCourses(this.repository);

  final AppRepository repository;

  Future<List<Course>> call({String query = ''}) {
    return repository.getCourses(query: query);
  }
}

class GetProgress {
  const GetProgress(this.repository);

  final AppRepository repository;

  Future<List<StudentProgress>> call() {
    return repository.getProgress();
  }
}

class WatchProgress {
  const WatchProgress(this.repository);

  final AppRepository repository;

  Stream<List<StudentProgress>> call() {
    return repository.watchProgress();
  }
}

class UpdateProgress {
  const UpdateProgress(this.repository);

  final AppRepository repository;

  Future<void> call({
    required int courseId,
    required int delta,
  }) {
    return repository.updateProgress(courseId, delta);
  }
}
