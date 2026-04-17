import 'dart:async';

import '../domain/entities.dart';
import '../domain/repository.dart';
import 'app_database.dart';
import 'models.dart';

class AppRepositoryImpl implements AppRepository {
  AppRepositoryImpl(this._database);

  final AppDatabase _database;
  final StreamController<List<StudentProgress>> _progressController =
      StreamController<List<StudentProgress>>.broadcast();
  bool _useMemoryFallback = false;
  final List<Course> _memoryCourses = const [
    Course(
      id: 1,
      title: 'Flutter desde cero',
      description:
          'Aprende widgets, navegacion y construccion de interfaces modernas.',
      instructor: 'Ana Rivera',
      duration: '6 semanas',
      category: 'Mobile',
    ),
    Course(
      id: 2,
      title: 'SQLite practico',
      description:
          'Guarda datos locales y crea aplicaciones con persistencia simple.',
      instructor: 'Carlos Mena',
      duration: '4 semanas',
      category: 'Base de datos',
    ),
    Course(
      id: 3,
      title: 'Riverpod esencial',
      description:
          'Administra estado de forma ordenada y separa la UI de la logica.',
      instructor: 'Lucia Torres',
      duration: '5 semanas',
      category: 'Estado',
    ),
    Course(
      id: 4,
      title: 'Arquitectura limpia',
      description:
          'Organiza tu proyecto en capas para hacerlo escalable y mantenible.',
      instructor: 'Diego Paz',
      duration: '3 semanas',
      category: 'Arquitectura',
    ),
  ];
  List<StudentProgress> _memoryProgress = const [
    StudentProgress(courseId: 1, completedLessons: 3, totalLessons: 10),
    StudentProgress(courseId: 2, completedLessons: 5, totalLessons: 8),
    StudentProgress(courseId: 3, completedLessons: 2, totalLessons: 12),
    StudentProgress(courseId: 4, completedLessons: 1, totalLessons: 6),
  ];

  @override
  Future<List<Course>> getCourses({String query = ''}) async {
    final normalizedQuery = query.trim();

    if (_useMemoryFallback) {
      return _filterCourses(normalizedQuery);
    }

    try {
      final db = await _database.database;
      final maps = await db.query(
        'courses',
        where: normalizedQuery.isEmpty ? null : 'title LIKE ? OR category LIKE ?',
        whereArgs: normalizedQuery.isEmpty
            ? null
            : ['%$normalizedQuery%', '%$normalizedQuery%'],
        orderBy: 'id ASC',
      );

      return maps.map(CourseModel.fromMap).toList();
    } catch (_) {
      _useMemoryFallback = true;
      return _filterCourses(normalizedQuery);
    }
  }

  @override
  Future<List<StudentProgress>> getProgress() async {
    if (_useMemoryFallback) {
      return List<StudentProgress>.from(_memoryProgress);
    }

    try {
      final db = await _database.database;
      final maps = await db.query('progress', orderBy: 'course_id ASC');
      return maps.map(StudentProgressModel.fromMap).toList();
    } catch (_) {
      _useMemoryFallback = true;
      return List<StudentProgress>.from(_memoryProgress);
    }
  }

  @override
  Stream<List<StudentProgress>> watchProgress() async* {
    yield await getProgress();
    yield* _progressController.stream;
  }

  @override
  Future<void> updateProgress(int courseId, int delta) async {
    if (_useMemoryFallback) {
      _updateMemoryProgress(courseId, delta);
      _progressController.add(List<StudentProgress>.from(_memoryProgress));
      return;
    }

    try {
      final db = await _database.database;
      final maps = await db.query(
        'progress',
        where: 'course_id = ?',
        whereArgs: [courseId],
        limit: 1,
      );

      if (maps.isEmpty) {
        return;
      }

      final current = StudentProgressModel.fromMap(maps.first);
      final nextLessons =
          (current.completedLessons + delta).clamp(0, current.totalLessons);

      await db.update(
        'progress',
        {'completed_lessons': nextLessons},
        where: 'course_id = ?',
        whereArgs: [courseId],
      );

      _progressController.add(await getProgress());
    } catch (_) {
      _useMemoryFallback = true;
      _updateMemoryProgress(courseId, delta);
      _progressController.add(List<StudentProgress>.from(_memoryProgress));
    }
  }

  void dispose() {
    _progressController.close();
  }

  List<Course> _filterCourses(String query) {
    if (query.isEmpty) {
      return List<Course>.from(_memoryCourses);
    }

    final lowerQuery = query.toLowerCase();
    return _memoryCourses
        .where(
          (course) =>
              course.title.toLowerCase().contains(lowerQuery) ||
              course.category.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  void _updateMemoryProgress(int courseId, int delta) {
    _memoryProgress = _memoryProgress.map((item) {
      if (item.courseId != courseId) {
        return item;
      }

      final nextLessons =
          (item.completedLessons + delta).clamp(0, item.totalLessons);

      return item.copyWith(completedLessons: nextLessons);
    }).toList();
  }
}
