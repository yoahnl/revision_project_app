import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/onboarding/application/revision_goals_controller.dart';
import 'package:Neralune/features/onboarding/domain/revision_goal.dart';
import 'package:Neralune/features/subjects/application/subjects_controller.dart';
import 'package:Neralune/features/subjects/domain/subject.dart';
import 'package:Neralune/presentation/pages/onboarding/onboarding_page.dart';

class CapturingSubjectsRepository implements SubjectsRepository {
  Subject? createdSubject;

  @override
  Future<Subject> createSubject({
    required String name,
    required int priority,
    int weeklyMinutes = 0,
  }) async {
    createdSubject = Subject(
      id: 'subject-1',
      name: name,
      priority: priority,
      weeklyMinutes: weeklyMinutes,
    );
    return createdSubject!;
  }

  @override
  Future<void> deleteSubject(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Subject> getSubject(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Subject>> listSubjects() {
    throw UnimplementedError();
  }
}

class CapturingRevisionGoalsRepository implements RevisionGoalsRepository {
  RevisionGoal? savedGoal;

  @override
  Future<void> saveRevisionGoal(RevisionGoal goal) async {
    savedGoal = goal;
  }
}

void main() {
  testWidgets('shows the first subject onboarding action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingPage(
          subjectsController: SubjectsController(CapturingSubjectsRepository()),
          revisionGoalsController: RevisionGoalsController(
            CapturingRevisionGoalsRepository(),
          ),
        ),
      ),
    );

    expect(find.text('Crée ta première matière'), findsOneWidget);
    expect(find.text('Matière'), findsOneWidget);
    expect(find.text('Minutes par semaine'), findsOneWidget);
    expect(find.text('Créer mon plan'), findsOneWidget);
    expect(find.textContaining('MVP+'), findsNothing);
    expect(find.textContaining('backend'), findsNothing);
  });

  testWidgets('validates weekly minutes before creating a subject', (
    tester,
  ) async {
    final subjectsRepository = CapturingSubjectsRepository();
    final goalsRepository = CapturingRevisionGoalsRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingPage(
          subjectsController: SubjectsController(subjectsRepository),
          revisionGoalsController: RevisionGoalsController(goalsRepository),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'Japonais');
    await tester.enterText(find.byType(TextField).at(1), '15');
    await tester.tap(find.text('Créer mon plan'));
    await tester.pump();

    expect(
      find.text('Indique au moins 30 minutes par semaine.'),
      findsOneWidget,
    );
    expect(subjectsRepository.createdSubject, isNull);
    expect(goalsRepository.savedGoal, isNull);
  });
}
