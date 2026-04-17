import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../data/repository_impl.dart';
import '../domain/entities.dart';
import '../domain/repository.dart';
import '../domain/usecases.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final repositoryProvider = Provider<AppRepository>((ref) {
  final repository = AppRepositoryImpl(ref.watch(databaseProvider));
  ref.onDispose(repository.dispose);
  return repository;
});

final getCoursesUseCaseProvider = Provider<GetCourses>((ref) {
  return GetCourses(ref.watch(repositoryProvider));
});

final getProgressUseCaseProvider = Provider<GetProgress>((ref) {
  return GetProgress(ref.watch(repositoryProvider));
});

final watchProgressUseCaseProvider = Provider<WatchProgress>((ref) {
  return WatchProgress(ref.watch(repositoryProvider));
});

final updateProgressUseCaseProvider = Provider<UpdateProgress>((ref) {
  return UpdateProgress(ref.watch(repositoryProvider));
});

final currentPageProvider = StateProvider<int>((ref) => 0);
final courseFilterProvider = StateProvider<String>((ref) => '');

final coursesProvider = FutureProvider<List<Course>>((ref) {
  final query = ref.watch(courseFilterProvider);
  return ref.watch(getCoursesUseCaseProvider).call(query: query);
});

final progressProvider = StreamProvider<List<StudentProgress>>((ref) {
  return ref.watch(watchProgressUseCaseProvider).call();
});

final updateProgressActionProvider =
    Provider<Future<void> Function(int courseId, int delta)>((ref) {
  return (courseId, delta) async {
    await ref
        .read(updateProgressUseCaseProvider)
        .call(courseId: courseId, delta: delta);
  };
});

final progressSimulationProvider = Provider<ProgressSimulation>((ref) {
  final simulation = ProgressSimulation(ref);
  simulation.start();
  ref.onDispose(simulation.dispose);
  return simulation;
});

class ProgressSimulation {
  ProgressSimulation(this.ref);

  final Ref ref;
  Timer? _timer;
  int _currentIndex = 0;

  void start() {
    _timer ??= Timer.periodic(const Duration(seconds: 5), (_) async {
      final courses = await ref.read(getCoursesUseCaseProvider).call();

      if (courses.isEmpty) {
        return;
      }

      final course = courses[_currentIndex % courses.length];
      _currentIndex++;

      await ref
          .read(updateProgressUseCaseProvider)
          .call(courseId: course.id, delta: 1);
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}
