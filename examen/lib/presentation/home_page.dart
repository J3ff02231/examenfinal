import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities.dart';
import 'app_provider.dart';
import 'course_detail_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(progressSimulationProvider);
    final currentPage = ref.watch(currentPageProvider);

    const titles = ['Cursos', 'Progreso', 'Perfil'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[currentPage]),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          ref.read(currentPageProvider.notifier).state = index;
        },
        children: const [
          CoursesSection(),
          ProgressSection(),
          ProfileSection(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPage,
        onDestinationSelected: (index) {
          ref.read(currentPageProvider.notifier).state = index;
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Cursos',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: 'Progreso',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class CoursesSection extends ConsumerWidget {
  const CoursesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    final progressAsync = ref.watch(progressProvider);
    final updateProgress = ref.watch(updateProgressActionProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Filtrar cursos',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              ref.read(courseFilterProvider.notifier).state = value;
            },
          ),
        ),
        Expanded(
          child: coursesAsync.when(
            data: (courses) {
              return progressAsync.when(
                data: (progressList) {
                  if (courses.isEmpty) {
                    return const Center(
                      child: Text('No hay cursos para ese filtro'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      final progress = _findProgress(progressList, course.id);

                      return CourseCard(
                        course: course,
                        progress: progress,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => CourseDetailPage(course: course),
                            ),
                          );
                        },
                        onIncrease: () => updateProgress(course.id, 1),
                        onDecrease: () => updateProgress(course.id, -1),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text('Error al cargar progreso: $error'),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Text('Error al cargar cursos: $error'),
            ),
          ),
        ),
      ],
    );
  }
}

class ProgressSection extends ConsumerWidget {
  const ProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressProvider);
    final coursesAsync = ref.watch(coursesProvider);
    final updateProgress = ref.watch(updateProgressActionProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: progressAsync.when(
        data: (progressList) {
          return coursesAsync.when(
            data: (courses) {
              final average = progressList.isEmpty
                  ? 0.0
                  : progressList
                          .map((item) => item.percentage)
                          .reduce((a, b) => a + b) /
                      progressList.length;

              return ListView(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.insights_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Progreso promedio',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: average),
                            duration: const Duration(milliseconds: 800),
                            builder: (context, value, child) {
                              return Column(
                                children: [
                                  LinearProgressIndicator(
                                    value: value,
                                    minHeight: 12,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  const SizedBox(height: 10),
                                  Text('${(value * 100).round()}% completado'),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sync, size: 18),
                              SizedBox(width: 6),
                              Text('Simulacion automatica cada 5 segundos'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...courses.map((course) {
                    final progress = _findProgress(progressList, course.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 0,
                                end: progress.percentage,
                              ),
                              duration: const Duration(milliseconds: 600),
                              builder: (context, value, child) {
                                return LinearProgressIndicator(
                                  value: value,
                                  minHeight: 10,
                                  borderRadius: BorderRadius.circular(20),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${progress.completedLessons}/${progress.totalLessons} lecciones - ${progress.percentageLabel}%',
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                IconButton.filledTonal(
                                  onPressed: () => updateProgress(course.id, -1),
                                  icon: const Icon(Icons.remove),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filled(
                                  onPressed: () => updateProgress(course.id, 1),
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Text('Error al cargar cursos: $error'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error al cargar progreso: $error'),
        ),
      ),
    );
  }
}

class ProfileSection extends ConsumerWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: progressAsync.when(
        data: (progressList) {
          final completedCourses =
              progressList.where((item) => item.percentage >= 1).length;
          final totalLessons = progressList.fold<int>(
            0,
            (sum, item) => sum + item.totalLessons,
          );
          final completedLessons = progressList.fold<int>(
            0,
            (sum, item) => sum + item.completedLessons,
          );

          return ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: const Icon(Icons.person, size: 34),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Estudiante Demo',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      const Text('Seguimiento academico local con Riverpod'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('Lecciones completadas'),
                  subtitle: Text('$completedLessons de $totalLessons'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.verified_outlined),
                  title: const Text('Cursos completados'),
                  subtitle: Text('$completedCourses finalizados'),
                ),
              ),
              const SizedBox(height: 12),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'El progreso se actualiza con botones y tambien con una simulacion en tiempo real.',
                        ),
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
          child: Text('Error al cargar perfil: $error'),
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.progress,
    required this.onTap,
    required this.onIncrease,
    required this.onDecrease,
  });

  final Course course;
  final StudentProgress progress;
  final VoidCallback onTap;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    child: const Icon(Icons.book_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      course.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                course.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 18),
                  const SizedBox(width: 6),
                  Expanded(child: Text(course.instructor)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(course.duration),
                ],
              ),
              const SizedBox(height: 14),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress.percentage),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(20),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text('Progreso: ${progress.percentageLabel}%'),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: onDecrease,
                    icon: const Icon(Icons.remove),
                    label: const Text('Restar'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: onIncrease,
                    icon: const Icon(Icons.add),
                    label: const Text('Avanzar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

StudentProgress _findProgress(
  List<StudentProgress> progressList,
  int courseId,
) {
  return progressList.firstWhere(
    (item) => item.courseId == courseId,
    orElse: () => const StudentProgress(
      courseId: 0,
      completedLessons: 0,
      totalLessons: 1,
    ),
  );
}
