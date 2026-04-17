import '../domain/entities.dart';

class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.instructor,
    required super.duration,
    required super.category,
  });

  factory CourseModel.fromMap(Map<String, Object?> map) {
    return CourseModel(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      instructor: map['instructor'] as String,
      duration: map['duration'] as String,
      category: map['category'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructor': instructor,
      'duration': duration,
      'category': category,
    };
  }
}

class StudentProgressModel extends StudentProgress {
  const StudentProgressModel({
    required super.courseId,
    required super.completedLessons,
    required super.totalLessons,
  });

  factory StudentProgressModel.fromMap(Map<String, Object?> map) {
    return StudentProgressModel(
      courseId: map['course_id'] as int,
      completedLessons: map['completed_lessons'] as int,
      totalLessons: map['total_lessons'] as int,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'course_id': courseId,
      'completed_lessons': completedLessons,
      'total_lessons': totalLessons,
    };
  }
}
