import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/app/di/providers.dart';
import 'package:Neralune/app/router/app_routes.dart';
import 'package:Neralune/core/storage/kv_storage_port.dart';
import 'package:Neralune/features/courses/application/course_pdf_picker.dart';
import 'package:Neralune/features/courses/application/courses_providers.dart';
import 'package:Neralune/features/courses/domain/course_models.dart';
import 'package:Neralune/features/courses/domain/courses_repository.dart';
import 'package:Neralune/features/courses/presentation/course_detail_page.dart';
import 'package:Neralune/features/courses/presentation/course_revision_sheet_page.dart';
import 'package:Neralune/features/courses/presentation/courses_home_page.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';
import 'package:Neralune/features/documents/domain/source_lifecycle.dart';
import 'package:Neralune/features/revision_sessions/domain/revision_session.dart';
import 'package:Neralune/features/subjects/application/subjects_controller.dart';
import 'package:Neralune/features/subjects/domain/subject.dart';
import 'package:Neralune/presentation/theme/app_theme.dart';
import 'package:Neralune/presentation/theme/theme_controller.dart';
import 'package:Neralune/presentation/widgets/revision_background.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final subjectsRepository = _PlaywrightSubjectsRepository();
  final coursesRepository = _PlaywrightCoursesRepository();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) =>
            const _PlaywrightFrame(child: CoursesHomePage()),
      ),
      GoRoute(
        path: AppRoutes.coursePath,
        builder: (context, state) => _PlaywrightFrame(
          child: CourseDetailPage(
            courseId: state.pathParameters['courseId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.courseSheetPath,
        builder: (context, state) => _PlaywrightFrame(
          child: CourseRevisionSheetPage(
            courseId: state.pathParameters['courseId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.revisionSessionV2Path,
        builder: (context, state) => _PlaywrightFrame(
          child: Center(
            child: Text(
              'Session de révision',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
      ),
    ],
  );

  runApp(
    ProviderScope(
      overrides: [
        kvStorageProvider.overrideWithValue(const _PlaywrightKvStorage()),
        subjectsRepositoryProvider.overrideWithValue(subjectsRepository),
        coursesRepositoryProvider.overrideWithValue(coursesRepository),
        coursePdfPickerProvider.overrideWithValue(const _NoopCoursePdfPicker()),
      ],
      child: MaterialApp.router(
        title: 'Neralune Playwright',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: router,
      ),
    ),
  );
}

class _PlaywrightFrame extends StatelessWidget {
  const _PlaywrightFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RevisionBackground(child: SafeArea(child: child)),
    );
  }
}

class _PlaywrightSubjectsRepository implements SubjectsRepository {
  final _subjects = const [
    Subject(id: 'subject-1', name: 'Droit', priority: 4),
    Subject(id: 'subject-2', name: 'Économie', priority: 3),
  ];

  @override
  Future<List<Subject>> listSubjects() async => _subjects;

  @override
  Future<Subject> getSubject(String id) async {
    return _subjects.firstWhere((subject) => subject.id == id);
  }

  @override
  Future<Subject> createSubject({
    required String name,
    required int priority,
    int weeklyMinutes = 0,
  }) async {
    return Subject(
      id: 'subject-${name.toLowerCase()}',
      name: name,
      priority: priority,
      weeklyMinutes: weeklyMinutes,
    );
  }

  @override
  Future<void> deleteSubject(String id) async {}

  @override
  Future<Subject> updateSubject({
    required String id,
    required String name,
    required int priority,
  }) async {
    return Subject(id: id, name: name, priority: priority);
  }

  @override
  Future<SubjectLifecycleDecision> getSubjectLifecycle(String id) async {
    return SubjectLifecycleDecision(
      subjectId: id,
      status: SubjectLifecycleStatus.active,
      recommendedAction: SubjectLifecycleRecommendedAction.delete,
      canDelete: true,
      canArchive: false,
      canUpdate: true,
      blockingReasons: const [],
      userMessage: 'Cette matière peut être supprimée.',
    );
  }

  @override
  Future<SubjectLifecycleDecision> archiveSubject(String id) async {
    return SubjectLifecycleDecision(
      subjectId: id,
      status: SubjectLifecycleStatus.archived,
      recommendedAction: SubjectLifecycleRecommendedAction.block,
      canDelete: false,
      canArchive: false,
      canUpdate: false,
      blockingReasons: const ['ALREADY_ARCHIVED'],
      userMessage: 'Cette matière est archivée.',
    );
  }
}

class _PlaywrightCoursesRepository implements CoursesRepository {
  _PlaywrightCoursesRepository();

  static const _mainCourse = CourseListItem(
    id: 'course-1',
    subjectId: 'subject-1',
    title: 'Introduction au droit',
    estimatedMinutes: 35,
    sourceCount: 1,
    readySourceCount: 1,
    processingSourceCount: 0,
    failedSourceCount: 0,
  );
  static const _secondCourse = CourseListItem(
    id: 'course-2',
    subjectId: 'subject-1',
    title: 'Droit administratif',
    estimatedMinutes: 28,
    sourceCount: 1,
    readySourceCount: 1,
    processingSourceCount: 0,
    failedSourceCount: 0,
  );

  @override
  Future<List<CourseListItem>> listCourses({required String subjectId}) async {
    if (subjectId == 'subject-1') {
      return const [_mainCourse, _secondCourse];
    }
    return const [];
  }

  @override
  Future<CourseDetail> getCourse({required String courseId}) async {
    return switch (courseId) {
      'course-1' => const CourseDetail(
        course: _mainCourse,
        subject: CourseSubjectSummary(id: 'subject-1', name: 'Droit'),
        sources: [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'introduction-droit.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      ),
      'course-2' => const CourseDetail(
        course: _secondCourse,
        subject: CourseSubjectSummary(id: 'subject-1', name: 'Droit'),
        sources: [
          CourseDocument(
            id: 'document-2',
            courseId: 'course-2',
            documentId: 'document-2',
            fileName: 'droit-administratif.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      ),
      _ => throw const CourseNotFoundException('Course not found'),
    };
  }

  @override
  Future<CourseProgress> getCourseProgress({required String courseId}) async {
    final mastery = courseId == 'course-1' ? 0.07 : 0.31;
    return CourseProgress(
      courseId: courseId,
      subjectId: 'subject-1',
      knowledgeUnitCount: courseId == 'course-1' ? 15 : 1,
      practicedKnowledgeUnitCount: courseId == 'course-1' ? 1 : 0,
      coverage: courseId == 'course-1' ? 0.12 : 0.24,
      mastery: null,
      estimatedGlobalMastery: mastery,
      readySourceCount: 1,
      processingSourceCount: 0,
      failedSourceCount: 0,
      state: CourseProgressState.readyNotPracticed,
    );
  }

  @override
  Future<CourseLearningPath> getCourseLearningPath({
    required String courseId,
  }) async {
    if (courseId == 'course-2') {
      return _shortLearningPath();
    }
    return _longLearningPath();
  }

  @override
  Future<RevisionSheet?> getCourseRevisionSheet({
    required String courseId,
  }) async {
    return _revisionSheet(courseId);
  }

  @override
  Future<RevisionSheet> generateCourseRevisionSheet({
    required String courseId,
  }) async {
    return _revisionSheet(courseId);
  }

  @override
  Future<CourseQuestionBankReadiness> getQuestionBankReadiness({
    required String courseId,
    int questionCount = 10,
  }) async {
    return CourseQuestionBankReadiness(
      courseId: courseId,
      status: CourseQuestionBankReadinessStatus.ready,
      readyQuestionCount: questionCount,
      targetQuestionCount: questionCount,
      canStartQuickRevision: true,
      canPrepare: false,
      userMessage: 'Les questions sont prêtes.',
    );
  }

  @override
  Future<ResumableCourseRevisionSession?> getResumableCourseRevisionSession({
    required String courseId,
  }) async {
    return null;
  }

  @override
  Future<RevisionSessionResponse> startCourseQuickRevision({
    required String courseId,
    int questionCount = 10,
  }) async {
    return RevisionSessionResponse(
      session: RevisionSession(
        id: 'playwright-session',
        subjectId: 'subject-1',
        courseId: courseId,
        documentId: 'document-1',
        knowledgeUnitId: 'unit-1',
        status: RevisionSessionStatus.started,
        mode: RevisionSessionMode.quick,
        createdAt: DateTime.utc(2026, 6, 28),
        completedAt: null,
      ),
      currentAction: null,
      history: const [],
    );
  }

  @override
  Future<SubjectProgress> getSubjectProgress({
    required String subjectId,
  }) async {
    return const SubjectProgress(
      subjectId: 'subject-1',
      knowledgeUnitCount: 16,
      practicedKnowledgeUnitCount: 1,
      coverage: 0.12,
      mastery: null,
      estimatedGlobalMastery: 0.07,
      courseCount: 2,
      readyCourseCount: 2,
      courses: [
        SubjectCourseProgressItem(
          courseId: 'course-1',
          title: 'Introduction au droit',
          knowledgeUnitCount: 15,
          practicedKnowledgeUnitCount: 1,
          coverage: 0.12,
          mastery: null,
          estimatedGlobalMastery: 0.07,
          state: CourseProgressState.readyNotPracticed,
        ),
        SubjectCourseProgressItem(
          courseId: 'course-2',
          title: 'Droit administratif',
          knowledgeUnitCount: 1,
          practicedKnowledgeUnitCount: 0,
          coverage: 0.24,
          mastery: null,
          estimatedGlobalMastery: 0.31,
          state: CourseProgressState.readyNotPracticed,
        ),
      ],
    );
  }

  @override
  Future<CourseLifecycleDecision> getCourseLifecycle({
    required String courseId,
  }) async {
    return CourseLifecycleDecision(
      courseId: courseId,
      status: LifecycleStatus.active,
      recommendedAction: LifecycleRecommendedAction.delete,
      canDelete: true,
      canArchive: false,
      canUpdate: true,
      blockingReasons: const [],
      userMessage: 'Ce cours peut être supprimé.',
    );
  }

  @override
  Future<SourceLifecycleDecision> getCourseDocumentLifecycle({
    required String courseId,
    required String documentId,
  }) async {
    return SourceLifecycleDecision(
      documentId: documentId,
      courseId: courseId,
      status: SourceLifecycleStatus.active,
      recommendedAction: SourceLifecycleAction.delete,
      canDelete: true,
      canArchive: true,
      blockingReasons: const [],
      userMessage: 'Cette source peut être supprimée.',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('${invocation.memberName} is not used here');
  }
}

CourseLearningPath _longLearningPath() {
  const titles = [
    'Le droit : une discipline omniprésente',
    'Le droit : un outil polyvalent',
    'Le droit : une matière en perpétuelle évolution',
    'Le langage juridique',
    'Publications spécifiques du droit',
    'Fragmentation du droit français (Ancien droit)',
    "Facteurs d'unité du droit (Ancien droit)",
    'Droit intermédiaire : modifications structurelles',
    'Droit intermédiaire : grands principes',
    'Codification napoléonienne',
    'Caractères du Code civil',
    'Grandes divisions du droit français',
    'Droit international et droit interne',
    'Droit public et droit privé',
    'Disciplines mixtes du droit',
  ];

  final nodes = [
    for (final indexed in titles.indexed)
      CourseLearningPathNode(
        id: 'unit-${indexed.$1 + 1}',
        knowledgeUnitId: 'unit-${indexed.$1 + 1}',
        courseId: 'course-1',
        subjectId: 'subject-1',
        documentId: 'document-1',
        title: indexed.$2,
        order: indexed.$1,
        state: indexed.$1 == 0
            ? CourseLearningPathNodeState.inProgress
            : CourseLearningPathNodeState.undiscovered,
        source: const CourseLearningPathNodeSource(
          documentId: 'document-1',
          fileName: 'introduction-droit.pdf',
        ),
        display: CourseLearningPathNodeDisplay(
          title: indexed.$2,
          statusLabel: indexed.$1 == 0 ? 'En cours' : 'À découvrir',
          metaLabel: 'Support 1',
          actionLabel: indexed.$1 == 0 ? 'Continuer' : 'Découvrir',
        ),
      ),
  ];

  return CourseLearningPath(
    generatedAt: DateTime.utc(2026, 6, 28),
    course: const CourseLearningPathCourse(
      id: 'course-1',
      subjectId: 'subject-1',
      subjectName: 'Droit',
      title: 'Introduction au droit',
    ),
    summary: const CourseLearningPathSummary(
      knowledgeUnitCount: 15,
      solidCount: 0,
      inProgressCount: 1,
      toStrengthenCount: 0,
      undiscoveredCount: 14,
      estimatedGlobalMastery: 0.07,
      mastery: null,
      coverage: 0.12,
      readySourceCount: 1,
    ),
    activeNodeId: 'unit-1',
    primaryAction: const CourseLearningPathPrimaryAction(
      kind: CourseLearningPathPrimaryActionKind.reviewActiveNode,
      label: 'Continuer',
      description: 'Reprendre le parcours à la notion recommandée.',
      estimatedMinutes: 8,
      targetKnowledgeUnitId: 'unit-1',
      targetNodeId: 'unit-1',
      enabled: true,
    ),
    nodes: nodes,
  );
}

CourseLearningPath _shortLearningPath() {
  const node = CourseLearningPathNode(
    id: 'admin-unit-1',
    knowledgeUnitId: 'admin-unit-1',
    courseId: 'course-2',
    subjectId: 'subject-1',
    documentId: 'document-2',
    title: 'Le principe de légalité',
    order: 0,
    state: CourseLearningPathNodeState.inProgress,
    display: CourseLearningPathNodeDisplay(
      title: 'Le principe de légalité',
      statusLabel: 'En cours',
      metaLabel: 'Support 1',
      actionLabel: 'Continuer',
    ),
  );

  return CourseLearningPath(
    generatedAt: DateTime.utc(2026, 6, 28),
    course: const CourseLearningPathCourse(
      id: 'course-2',
      subjectId: 'subject-1',
      subjectName: 'Droit',
      title: 'Droit administratif',
    ),
    summary: const CourseLearningPathSummary(
      knowledgeUnitCount: 1,
      solidCount: 0,
      inProgressCount: 1,
      toStrengthenCount: 0,
      undiscoveredCount: 0,
      estimatedGlobalMastery: 0.31,
      mastery: null,
      coverage: 0.24,
      readySourceCount: 1,
    ),
    activeNodeId: node.id,
    primaryAction: const CourseLearningPathPrimaryAction(
      kind: CourseLearningPathPrimaryActionKind.reviewActiveNode,
      label: 'Continuer',
      description: 'Reprendre le parcours à la notion recommandée.',
      estimatedMinutes: 8,
      targetKnowledgeUnitId: 'admin-unit-1',
      targetNodeId: 'admin-unit-1',
      enabled: true,
    ),
    nodes: const [node],
  );
}

RevisionSheet _revisionSheet(String courseId) {
  return RevisionSheet(
    id: 'sheet-$courseId',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Fiche de cours',
    introduction: 'Une synthèse claire pour comprendre avant de réviser.',
    sections: const [
      RevisionSheetSection(
        id: 'section-1',
        displayOrder: 0,
        title: 'Idée principale',
        content: 'Le droit structure les relations sociales et politiques.',
        sources: [],
      ),
    ],
    keyPoints: const ['Définir les notions avant de pratiquer.'],
    commonMistakes: const ['Confondre droit public et droit privé.'],
    mustKnow: const ['Les grandes branches du droit.'],
    practiceSuggestions: const ['Relire la fiche puis lancer une révision.'],
    errorCode: null,
  );
}

class _PlaywrightKvStorage implements KvStoragePort {
  const _PlaywrightKvStorage();

  @override
  Future<String?> readString(String key) async {
    if (key == themeModeStorageKey) {
      return 'dark';
    }
    return null;
  }

  @override
  Future<void> writeString(String key, String value) async {}
}

class _NoopCoursePdfPicker implements CoursePdfPicker {
  const _NoopCoursePdfPicker();

  @override
  Future<PickedCoursePdf?> pickPdf() async => null;
}
