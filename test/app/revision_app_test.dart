import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/app/app_root.dart';
import 'package:Neralune/app/di/providers.dart';
import 'package:Neralune/core/storage/kv_storage_port.dart';
import 'package:Neralune/features/activities/application/activity_controller.dart';
import 'package:Neralune/features/auth/application/auth_controller.dart';
import 'package:Neralune/features/auth/domain/auth_session.dart';
import 'package:Neralune/features/auth/domain/authenticated_user.dart';
import 'package:Neralune/features/courses/application/courses_providers.dart';
import 'package:Neralune/features/courses/domain/course_models.dart';
import 'package:Neralune/features/documents/application/documents_controller.dart';
import 'package:Neralune/features/onboarding/application/revision_goals_controller.dart';
import 'package:Neralune/features/subjects/application/subjects_controller.dart';
import 'package:Neralune/features/subjects/domain/subject.dart';
import 'package:Neralune/features/today/application/today_controller.dart';
import 'package:Neralune/presentation/widgets/revision_navigation.dart';

import '../fakes/in_memory_activity_api.dart';
import '../fakes/in_memory_courses_repository.dart';
import '../fakes/in_memory_documents_api.dart';
import '../fakes/in_memory_revision_goals_repository.dart';
import '../fakes/in_memory_subjects_repository.dart';
import '../fakes/in_memory_today_repository.dart';

class SignedInAuthRepository implements AuthRepository {
  @override
  Stream<AuthSession> watchSession() async* {
    yield const AuthSession.signedIn(
      AuthenticatedUser(
        uid: 'firebase-123',
        email: 'student@example.com',
        displayName: 'Karim',
      ),
    );
  }

  @override
  Future<String> requireIdToken() async => 'firebase-id-token';

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}
}

class SignedOutAuthRepository implements AuthRepository {
  @override
  Stream<AuthSession> watchSession() async* {
    yield const AuthSession.signedOut();
  }

  @override
  Future<String> requireIdToken() async {
    throw StateError('A signed-in user is required');
  }

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}
}

class FakeKvStorage implements KvStoragePort {
  @override
  Future<String?> readString(String key) async => null;

  @override
  Future<void> writeString(String key, String value) async {}
}

void main() {
  testWidgets('opens on Today with the V4 three-tab shell', (tester) async {
    final testApp = _createTestApp();

    await tester.pumpWidget(testApp.widget);
    await tester.pumpAndSettle();

    expect(find.text('Aujourd’hui'), findsWidgets);
    expect(find.text('Rien de prêt pour aujourd’hui'), findsOneWidget);
    expect(find.text('Voir mes cours'), findsOneWidget);
    expect(find.text('Aujourd’hui'), findsWidgets);
    expect(find.text('Cours'), findsOneWidget);
    expect(find.text('Progrès'), findsOneWidget);
    expect(find.text('Réviser'), findsNothing);
    expect(find.text('Profil'), findsNothing);
    expect(find.byTooltip('Profil'), findsOneWidget);
    expect(find.text('Math'), findsNothing);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('12'), findsNothing);
    expect(find.text('870'), findsNothing);
    expect(find.text('7 jours'), findsNothing);
    expect(find.text('Sources'), findsNothing);
    expect(find.byType(RevisionBottomNavigation), findsOneWidget);
    final shellScaffold = find.ancestor(
      of: find.byType(RevisionBottomNavigation),
      matching: find.byType(Scaffold),
    );
    expect(shellScaffold, findsOneWidget);
    expect(tester.widget<Scaffold>(shellScaffold).extendBody, isTrue);
    expect(testApp.authController.isSignedIn, isTrue);
  });

  testWidgets('profile stays secondary and opens outside the main tab bar', (
    tester,
  ) async {
    await tester.pumpWidget(_createTestApp().widget);
    await tester.pumpAndSettle();

    expect(find.text('Aujourd’hui'), findsWidgets);
    expect(find.text('Cours'), findsOneWidget);
    expect(find.text('Progrès'), findsOneWidget);
    expect(find.text('Profil'), findsNothing);
    expect(find.byTooltip('Profil'), findsOneWidget);

    final profileButton = find.byKey(const ValueKey('profile-menu-button'));
    expect(profileButton, findsOneWidget);
    final buttonRect = tester.getRect(profileButton);
    final viewSize = tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(buttonRect.right, greaterThan(viewSize.width - 80));
    expect(buttonRect.top, lessThan(80));

    await tester.tap(profileButton);
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.byType(RevisionBottomNavigation), findsOneWidget);
    expect(find.byType(RevisionNavigationRail), findsNothing);

    await tester.tap(find.widgetWithText(ListTile, 'Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Profil'), findsOneWidget);
    expect(
      find.text('Gère ton compte et tes préférences d’affichage.'),
      findsOneWidget,
    );
    expect(find.byType(RevisionBottomNavigation), findsNothing);
    expect(find.byType(RevisionNavigationRail), findsNothing);
  });

  testWidgets('bottom navigation opens honest real-ready pages', (
    tester,
  ) async {
    await tester.pumpWidget(_createTestApp().widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Progrès'));
    await tester.pumpAndSettle();

    expect(
      find.text('Crée une matière pour suivre ta progression.'),
      findsOneWidget,
    );
    expect(find.text('Progression réelle en attente'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.textContaining('CORE-06 branchera'), findsNothing);

    await tester.tap(find.text('Cours'));
    await tester.pumpAndSettle();

    expect(find.text('Commence par créer une matière.'), findsOneWidget);
    expect(find.text('Créer une matière'), findsOneWidget);
    expect(find.textContaining('CORE-05 branchera'), findsNothing);
    expect(find.textContaining('à brancher en CORE-05'), findsNothing);
    expect(find.text('Sources'), findsNothing);
    expect(find.textContaining('CORE-03 branchera'), findsNothing);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('home can list real subjects without inventing courses', (
    tester,
  ) async {
    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(
            id: 'subject-real-1',
            name: 'Droit constitutionnel',
            priority: 4,
          ),
        ],
      ).widget,
    );
    await tester.pumpAndSettle();
    await _openCoursesTab(tester);

    expect(find.text('Droit constitutionnel'), findsWidgets);
    expect(find.text('Aucun cours pour le moment'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('home can create and select a subject from the subject picker', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(430, 932);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(id: 'subject-real-1', name: 'Droits', priority: 4),
        ],
      ).widget,
    );
    await tester.pumpAndSettle();
    await _openCoursesTab(tester);

    await tester.tap(find.text('Droits').first);
    await tester.pumpAndSettle();

    expect(find.text('Choisir une matière'), findsOneWidget);
    expect(find.text('Créer une matière'), findsOneWidget);

    await tester.tap(find.text('Créer une matière'));
    await tester.pumpAndSettle();

    expect(find.text('Créer une matière'), findsOneWidget);
    expect(find.text('Nom de la matière'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'Histoire');
    await tester.tap(find.text('Créer la matière'));
    await tester.pumpAndSettle();

    expect(find.text('Histoire'), findsWidgets);
    expect(find.text('Tes cours de Histoire'), findsOneWidget);
    expect(find.text('Aucun cours pour le moment'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
  });

  testWidgets('home can list real courses for the active subject', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(430, 932);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(
            id: 'subject-real-1',
            name: 'Droit constitutionnel',
            priority: 4,
          ),
        ],
        seedCourses: const [
          CourseListItem(
            id: 'course-real-1',
            subjectId: 'subject-real-1',
            title: 'Institutions de la Ve République',
            chapterLabel: 'Chapitre 2',
            estimatedMinutes: 35,
            sourceCount: 1,
            readySourceCount: 1,
            processingSourceCount: 0,
            failedSourceCount: 0,
          ),
        ],
      ).widget,
    );
    await tester.pumpAndSettle();
    await _openCoursesTab(tester);

    expect(find.text('Institutions de la Ve République'), findsWidgets);
    expect(find.text('Chapitre 2 · 35 min'), findsOneWidget);
    expect(find.text('1 source · 1 prête'), findsWidgets);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('home keeps its premium header fixed while course cards scroll', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(430, 932);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    final courses = List<CourseListItem>.generate(
      12,
      (index) => CourseListItem(
        id: 'course-real-${index + 1}',
        subjectId: 'subject-real-1',
        title: 'Cours ${index + 1}',
        chapterLabel: 'Chapitre ${index + 1}',
        estimatedMinutes: 20 + index,
        sourceCount: 1,
        readySourceCount: 1,
        processingSourceCount: 0,
        failedSourceCount: 0,
      ),
    );

    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(id: 'subject-real-1', name: 'Droits', priority: 4),
        ],
        seedCourses: courses,
      ).widget,
    );
    await tester.pumpAndSettle();
    await _openCoursesTab(tester);

    expect(find.text('Droits'), findsWidgets);
    expect(find.text('Continue ton progrès'), findsOneWidget);
    expect(find.text('Cours prêt à réviser'), findsOneWidget);
    expect(find.text('Reprendre le cours'), findsNothing);
    expect(find.text('Cours 12'), findsNothing);

    final courseListScrollable = find.byType(Scrollable).last;
    final listBottom = tester.getRect(courseListScrollable).bottom;
    final navigationTop = tester
        .getRect(find.byType(RevisionBottomNavigation))
        .top;
    expect(navigationTop - listBottom, lessThanOrEqualTo(32));

    await tester.scrollUntilVisible(
      find.text('Cours 12'),
      600,
      scrollable: courseListScrollable,
    );
    await tester.pumpAndSettle();

    expect(find.text('Droits'), findsWidgets);
    expect(find.text('Continue ton progrès'), findsOneWidget);
    expect(find.text('Cours prêt à réviser'), findsOneWidget);
    expect(find.text('Reprendre le cours'), findsNothing);
    expect(find.text('Cours 12'), findsOneWidget);
  });

  testWidgets('home can create a real course and open its detail', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(430, 932);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(
            id: 'subject-real-1',
            name: 'Droit constitutionnel',
            priority: 4,
          ),
        ],
      ).widget,
    );
    await tester.pumpAndSettle();
    await _openCoursesTab(tester);

    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Créer un cours'),
    );
    await tester.tap(
      find.widgetWithText(FilledButton, 'Créer un cours').hitTestable(),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Droit administratif');
    await tester.tap(find.text('Créer le cours'));
    await tester.pumpAndSettle();

    expect(find.text('Droit administratif'), findsOneWidget);
    expect(find.text('Cours introuvable'), findsNothing);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('course and result routes do not fallback to fixture data', (
    tester,
  ) async {
    await tester.pumpWidget(_createTestApp().widget);
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(RevisionBottomNavigation));
    GoRouter.of(context).go('/courses/unknown');
    await tester.pumpAndSettle();

    expect(find.text('Cours introuvable'), findsOneWidget);
    expect(find.text('Impossible d’ouvrir ce cours'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);

    GoRouter.of(context).go('/revision-sessions/fake/result');
    await tester.pumpAndSettle();

    expect(find.text('Impossible de charger le résultat'), findsOneWidget);
    expect(find.text('78%'), findsNothing);
    expect(find.text('4/5 bonnes'), findsNothing);
  });

  testWidgets('uses route-driven navigation rail on wide layouts', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(1200, 900);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    await tester.pumpWidget(_createTestApp().widget);
    await tester.pumpAndSettle();

    expect(find.byType(RevisionNavigationRail), findsOneWidget);
    expect(find.byType(RevisionBottomNavigation), findsNothing);

    await tester.tap(find.text('Cours'));
    await tester.pumpAndSettle();

    expect(find.text('Commence par créer une matière.'), findsOneWidget);
    expect(find.textContaining('CORE-05 branchera'), findsNothing);
  });

  testWidgets('redirects signed-out users to the sign-in page', (tester) async {
    await tester.pumpWidget(
      _createTestApp(
        authController: AuthController(SignedOutAuthRepository()),
      ).widget,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('NERALUNE'), findsOneWidget);
    expect(find.textContaining('Révise mieux'), findsOneWidget);
    expect(find.text('Continuer avec Google'), findsOneWidget);
    expect(find.text('Continuer avec Apple'), findsOneWidget);
  });
}

AuthController signedInAuthController() {
  return AuthController(SignedInAuthRepository());
}

_RevisionTestApp _createTestApp({
  AuthController? authController,
  List<Subject> seedSubjects = const [],
  List<CourseListItem> seedCourses = const [],
}) {
  final resolvedAuthController = authController ?? signedInAuthController();
  final subjectsRepository = InMemorySubjectsRepository();
  subjectsRepository.subjects.addAll(seedSubjects);
  final coursesRepository = InMemoryCoursesRepository();
  for (final course in seedCourses) {
    coursesRepository.coursesBySubject
        .putIfAbsent(course.subjectId, () => [])
        .add(course);
    coursesRepository.detailsByCourse[course.id] = CourseDetail(
      course: course,
      subject: CourseSubjectSummary(
        id: course.subjectId,
        name: _subjectNameFor(seedSubjects, course.subjectId),
      ),
      sources: const [],
    );
  }
  final revisionGoalsRepository = InMemoryRevisionGoalsRepository();
  final documentsApi = InMemoryDocumentsApi();
  final activityApi = InMemoryActivityApi();
  final todayRepository = InMemoryTodayRepository();

  resolvedAuthController.start();
  addTearDown(resolvedAuthController.dispose);

  final widget = ProviderScope(
    overrides: [
      kvStorageProvider.overrideWithValue(FakeKvStorage()),
      authControllerProvider.overrideWithValue(resolvedAuthController),
      subjectsRepositoryProvider.overrideWithValue(subjectsRepository),
      subjectsControllerProvider.overrideWithValue(
        SubjectsController(subjectsRepository),
      ),
      coursesRepositoryProvider.overrideWithValue(coursesRepository),
      revisionGoalsControllerProvider.overrideWithValue(
        RevisionGoalsController(revisionGoalsRepository),
      ),
      documentsControllerProvider.overrideWithValue(
        DocumentsController(documentsApi),
      ),
      documentsApiProvider.overrideWithValue(documentsApi),
      activityControllerProvider.overrideWithValue(
        ActivityController(activityApi),
      ),
      todayRepositoryProvider.overrideWithValue(todayRepository),
      todayControllerProvider.overrideWithValue(
        TodayController(todayRepository),
      ),
    ],
    child: const AppRoot(),
  );

  return _RevisionTestApp(
    widget: widget,
    authController: resolvedAuthController,
    revisionGoalsRepository: revisionGoalsRepository,
    activityApi: activityApi,
    todayRepository: todayRepository,
  );
}

Future<void> _openCoursesTab(WidgetTester tester) async {
  await tester.tap(find.text('Cours'));
  await tester.pumpAndSettle();
}

String _subjectNameFor(List<Subject> subjects, String subjectId) {
  for (final subject in subjects) {
    if (subject.id == subjectId) {
      return subject.name;
    }
  }

  return 'Matière réelle';
}

class _RevisionTestApp {
  const _RevisionTestApp({
    required this.widget,
    required this.authController,
    required this.revisionGoalsRepository,
    required this.activityApi,
    required this.todayRepository,
  });

  final Widget widget;
  final AuthController authController;
  final InMemoryRevisionGoalsRepository revisionGoalsRepository;
  final InMemoryActivityApi activityApi;
  final InMemoryTodayRepository todayRepository;
}
