import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:examen/domain/entities.dart';
import 'package:examen/domain/repository.dart';
import 'package:examen/main.dart';
import 'package:examen/presentation/app_provider.dart';

void main() {
  testWidgets('muestra la pantalla principal', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(FakeAppRepository()),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Cursos'), findsWidgets);
    expect(find.text('Flutter desde cero'), findsOneWidget);
  });
}

class FakeAppRepository implements AppRepository {
  final List<Course> _courses = const [
    Course(
      id: 1,
      title: 'Flutter desde cero',
      description: 'Curso inicial para construir interfaces moviles.',
      instructor: 'Ana Rivera',
      duration: '6 semanas',
      category: 'Mobile',
    ),
  ];

  List<StudentProgress> _progress = const [
    StudentProgress(courseId: 1, completedLessons: 2, totalLessons: 8),
  ];

  @override
  Future<List<Course>> getCourses({String query = ''}) async {
    if (query.isEmpty) {
      return _courses;
    }

    return _courses
        .where(
          (course) =>
              course.title.toLowerCase().contains(query.toLowerCase()) ||
              course.category.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  @override
  Future<List<StudentProgress>> getProgress() async => _progress;

  @override
  Future<void> updateProgress(int courseId, int delta) async {
    _progress = _progress
        .map((item) {
          if (item.courseId != courseId) {
            return item;
          }

          final nextValue =
              (item.completedLessons + delta).clamp(0, item.totalLessons);

          return item.copyWith(completedLessons: nextValue);
        })
        .toList();
  }

  @override
  Stream<List<StudentProgress>> watchProgress() async* {
    yield _progress;
  }
}
