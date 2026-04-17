class Course {
  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.duration,
    required this.category,
  });

  final int id;
  final String title;
  final String description;
  final String instructor;
  final String duration;
  final String category;
}

class StudentProgress {
  const StudentProgress({
    required this.courseId,
    required this.completedLessons,
    required this.totalLessons,
  });

  final int courseId;
  final int completedLessons;
  final int totalLessons;

  double get percentage {
    if (totalLessons == 0) {
      return 0;
    }

    return completedLessons / totalLessons;
  }

  int get percentageLabel => (percentage * 100).round();

  StudentProgress copyWith({
    int? courseId,
    int? completedLessons,
    int? totalLessons,
  }) {
    return StudentProgress(
      courseId: courseId ?? this.courseId,
      completedLessons: completedLessons ?? this.completedLessons,
      totalLessons: totalLessons ?? this.totalLessons,
    );
  }
}
