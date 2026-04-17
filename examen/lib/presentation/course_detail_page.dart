import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities.dart';
import 'app_provider.dart';

class CourseDetailPage extends ConsumerWidget {
  const CourseDetailPage({
    super.key,
    required this.course,
  });

  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressProvider);
    final updateProgress = ref.watch(updateProgressActionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del curso'),
      ),
      body: progressAsync.when(
        data: (progressList) {
          final progress = progressList.firstWhere(
            (item) => item.courseId == course.id,
            orElse: () => const StudentProgress(
              courseId: 0,
              completedLessons: 0,
              totalLessons: 1,
            ),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: const Icon(Icons.menu_book_rounded),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              course.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        course.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.person_outline),
                          const SizedBox(width: 8),
                          Text(course.instructor),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined),
                          const SizedBox(width: 8),
                          Text(course.duration),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.label_outline),
                          const SizedBox(width: 8),
                          Text(course.category),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progreso del estudiante',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: progress.percentage),
                          duration: const Duration(milliseconds: 700),
                          builder: (context, value, child) {
                            return SizedBox(
                              height: 110,
                              width: 110,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: value,
                                    strokeWidth: 10,
                                  ),
                                  Text('${(value * 100).round()}%'),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${progress.completedLessons} de ${progress.totalLessons} lecciones completadas',
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => updateProgress(course.id, -1),
                              icon: const Icon(Icons.remove),
                              label: const Text('Restar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => updateProgress(course.id, 1),
                              icon: const Icon(Icons.add),
                              label: const Text('Avanzar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error al cargar el detalle: $error'),
        ),
      ),
    );
  }
}
