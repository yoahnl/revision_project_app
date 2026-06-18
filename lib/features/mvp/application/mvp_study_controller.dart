import 'package:flutter/foundation.dart';

import '../domain/mvp_study_models.dart';

class MvpStudyController extends ChangeNotifier {
  MvpStudyController._();

  // Adapter temporaire front-only : il donne une experience Course visible
  // pendant que le modele backend Course + Document.courseId est implemente.
  static final MvpStudyController instance = MvpStudyController._();

  String _activeSubjectId = mvpSubjects.first.id;

  List<MvpSubject> get subjects => mvpSubjects;

  MvpSubject get activeSubject {
    return subjects.firstWhere((subject) => subject.id == _activeSubjectId);
  }

  MvpCourse get resumeCourse => activeSubject.courses.first;

  MvpCourse? courseById(String id) {
    for (final subject in subjects) {
      for (final course in subject.courses) {
        if (course.id == id) {
          return course;
        }
      }
    }

    return null;
  }

  MvpCourse courseOrFallback(String id) {
    return courseById(id) ?? resumeCourse;
  }

  Iterable<MvpSourceFile> get activeSources {
    return activeSubject.courses.expand((course) => course.sources);
  }

  double get activeMastery {
    final courses = activeSubject.courses;
    if (courses.isEmpty) {
      return 0;
    }

    final total = courses.fold<double>(
      0,
      (sum, course) => sum + course.mastery,
    );
    return total / courses.length;
  }

  void selectSubject(String id) {
    if (id == _activeSubjectId) {
      return;
    }

    if (!subjects.any((subject) => subject.id == id)) {
      return;
    }

    _activeSubjectId = id;
    notifyListeners();
  }

  void resetForTests() {
    _activeSubjectId = mvpSubjects.first.id;
    notifyListeners();
  }
}
