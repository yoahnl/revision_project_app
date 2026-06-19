# CORE-06C — Backend 06B alignment + source deletion contract hardening

## 1. Résumé

CORE-06C côté Flutter officialise et verrouille la suppression de source côté app sans refaire l'UI. L'implémentation existait déjà : `deleteCourseDocument` appelle l'endpoint course-scoped, le controller invalide détail/liste/progression cours/progression matière, et le détail cours affiche une confirmation. Le lot ajoute les tests manquants : path encodé + bearer + no body côté HTTP, invalidations et erreur côté provider, snackbar d'erreur côté widget. Le runbook frontend documente maintenant le parcours delete source.

## 2. Audit initial

- `CoursesRepository.deleteCourseDocument` existait déjà.
- `HttpCoursesRepository.deleteCourseDocument` existait déjà et encode `courseId`/`documentId` avec `Uri.encodeComponent`.
- Le test HTTP delete existait, mais utilisait seulement des IDs sûrs (`course-1`, `document-1`) : il ne verrouillait pas explicitement l'encodage.
- `DeleteCourseDocumentController.delete` invalidait déjà `courseDetailProvider`, `courseProgressProvider`, `coursesProvider(subjectId)` et `subjectProgressProvider(subjectId)`.
- Le test provider delete ne vérifiait que le refresh détail ; il ne prouvait pas liste/progression cours/progression matière.
- Le test widget couvrait le succès avec confirmation, snackbar et empty state, mais pas l'erreur de suppression.
- Le runbook frontend ne mentionnait pas encore la suppression de source ni ses refreshs.
- Les valeurs fake `Loi normale`, `78%`, `870`, `7 jours` ne ressortent que dans des assertions `findsNothing`.
- Aucune occurrence `CourseSource` dans `lib/features/courses`, `test/features/courses`, `test/fakes` ou `test/app`.

## 3. Sub-agents/passes utilisées

- Backend Contract Agent : audit read-only côté API, résultat intégré dans le rapport backend.
- Frontend Contract Agent : audit read-only, identification des gaps HTTP/provider/widget.
- Docs Agent : mise à jour runbook et rapport CORE-06B.
- QA Agent : validations locales listées en section 7.
- Reviewer Agent : auto-review finale en section 13.

## 4. Modifications backend

Non applicable dans ce repo. Les changements backend sont documentés dans le rapport API.

## 5. Modifications frontend

- `http_courses_repository_test.dart` : le test delete utilise maintenant des IDs avec espace et slash pour verrouiller l'encodage du path, le bearer token et l'absence de body.
- `courses_providers_test.dart` : le test delete vérifie maintenant que le controller rafraîchit détail, liste de cours, progression cours et progression matière après succès.
- `courses_providers_test.dart` : ajout d'un test d'erreur delete prouvant que l'état passe en erreur et que les providers ne sont pas invalidés comme si la suppression avait réussi.
- `course_detail_page_test.dart` : ajout d'un test widget d'échec de suppression avec snackbar `Impossible de supprimer cette source.` et source toujours affichée.
- `MVP_CORE_ACCEPTANCE_RUNBOOK.md` : ajout du parcours de suppression optionnelle d'une source de test et des règles de refresh associées.
- `CORE_06B_PROGRESS_REFRESH_AND_ACCEPTANCE_HARDENING_REPORT.md` : suppression de la mention obsolète sur `git diff --check`, clarification du commit CORE-06B réalisé après autorisation.

## 6. Tests ajoutés

- HTTP : `deletes a course source through the encoded course-scoped endpoint`.
- Provider : `deleteCourseDocumentController removes a source and refreshes course surfaces` renforcé.
- Provider : `deleteCourseDocumentController exposes errors without refreshing`.
- Widget : `course detail shows an error when source deletion fails`.

## 7. Commandes exécutées et résultats exacts

- `dart format test/features/courses/http_courses_repository_test.dart test/features/courses/courses_providers_test.dart test/features/courses/course_detail_page_test.dart` : OK.
- Premier ciblé `flutter test test/features/courses/http_courses_repository_test.dart test/features/courses/courses_providers_test.dart test/features/courses/course_detail_page_test.dart --reporter compact` : rouge, import `CourseNotFoundException` manquant dans `course_detail_page_test.dart`.
- `dart format test/features/courses/course_detail_page_test.dart` : OK.
- Rerun ciblé `flutter test test/features/courses/http_courses_repository_test.dart test/features/courses/courses_providers_test.dart test/features/courses/course_detail_page_test.dart --reporter compact` : OK, 44 tests.
- `dart analyze lib test` : OK, no issues found.
- `flutter test test/features/courses --reporter compact` : OK, all tests passed.
- `flutter test test/features/revision_sessions --reporter compact` : OK, all tests passed.
- `flutter test test/app/router/app_router_test.dart --reporter compact` : OK, all tests passed.
- `flutter test test/app/revision_app_test.dart --reporter compact` : OK, all tests passed.
- `flutter test test/app --reporter compact` : OK, all tests passed.
- `flutter test --reporter compact` : OK, all tests passed.
- `rg -n "MvpStudyController\.instance|mvpSubjects|mvpSessionQuestions|courseOrFallback|Loi normale|78%|4/5 bonnes|870|7 jours" lib/app lib/features/courses lib/presentation/shell test/app test/features/courses || true` : occurrences uniquement dans des assertions `findsNothing` des tests.
- `rg -n "CourseSource" lib/features/courses test/features/courses test/fakes test/app || true` : aucune occurrence.
- `git diff --check` : OK, relancé après génération du rapport CORE-06C.

## 8. Preuve anti-fixtures

La commande anti-fixtures ne retourne aucune occurrence runtime dans `lib/app`, `lib/features/courses` ou `lib/presentation/shell`. Les occurrences restantes sont exclusivement des assertions négatives `findsNothing` dans les tests app/courses.

## 9. Preuve anti-CourseSource

Commande exécutée : `rg -n "CourseSource" lib/features/courses test/features/courses test/fakes test/app || true`.

Résultat : aucune occurrence.

## 10. Runbook créé ou mis à jour

- `docs/core/MVP_CORE_ACCEPTANCE_RUNBOOK.md` mis à jour pour mentionner ajout source, attente processing, suppression optionnelle, fiche/quick seulement avec source `READY`, refresh après upload/delete/polling, absence de refresh au start quick et à la génération de fiche.

## 11. Limites

- Le lot ne change pas l'UX de suppression : confirmation + snackbar restent volontairement simples.
- Pas de restore/undo de source supprimée.
- Pas de refonte UI ni de page résultat session.

## 12. Risques restants

- Si la suppression devient fréquente, un undo ou une corbeille pourrait être utile plus tard.
- L'invalidation `subjectProgressProvider` depuis un détail de cours reste un peu large, mais elle évite une progression stale visible en MVP.

## 13. Auto-review

- Delete source a un contrat HTTP frontend testé : oui, méthode/path encodé/bearer/no body/404.
- Delete invalide toujours course/subject progress : oui, test provider renforcé.
- Upload invalide toujours course/subject progress : inchangé et déjà couvert par CORE-06B.
- Polling reste borné : inchangé, toujours testé.
- Aucun nouvel endpoint : oui.
- Aucun deep/exam : oui.
- Aucun résultat session final : oui.
- Aucun `CourseSource` : oui.
- Aucune fixture production : oui.
- `git diff --check` relancé après rapport : oui.
- Pas de commit pendant CORE-06C : oui.

## 14. Points discutables du prompt

- CORE-06C est un micro-lot, mais il est justifié par la nécessité d'aligner la documentation et de tester officiellement une capacité déjà présente.
- Le test d'encodage HTTP est plus strict que le bug actuel, mais il protège une classe réelle d'erreurs d'URL.
- La suppression de source pourrait bénéficier d'un undo plus tard, mais ce serait hors périmètre.

## 15. Fichiers créés/modifiés/supprimés

Créés :
- `docs/core/CORE_06C_BACKEND_ALIGNMENT_AND_SOURCE_DELETE_HARDENING_REPORT.md`

Modifiés :
- `test/features/courses/http_courses_repository_test.dart`
- `test/features/courses/courses_providers_test.dart`
- `test/features/courses/course_detail_page_test.dart`
- `docs/core/MVP_CORE_ACCEPTANCE_RUNBOOK.md`
- `docs/core/CORE_06B_PROGRESS_REFRESH_AND_ACCEPTANCE_HARDENING_REPORT.md`

Supprimés : aucun.

## 16. Contenu complet des fichiers créés/modifiés/supprimés

Le rapport courant ne s'inclut pas lui-même pour éviter une récursion infinie.

### test/features/courses/http_courses_repository_test.dart

````````dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/courses/data/http_courses_repository.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/courses/domain/courses_repository.dart';

class CapturingHttpClientAdapter implements HttpClientAdapter {
  CapturingHttpClientAdapter(this.response);

  ResponseBody response;
  int fetchCallCount = 0;
  RequestOptions? lastOptions;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    fetchCallCount += 1;
    lastOptions = options;
    return response;
  }
}

void main() {
  test('lists real courses with source counts and bearer token', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse([courseJson()]));
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final courses = await repository.listCourses(subjectId: 'subject-1');

    expect(courses.single.title, 'Droit constitutionnel');
    expect(courses.single.estimatedMinutes, 30);
    expect(courses.single.sourceCount, 2);
    expect(courses.single.readySourceCount, 1);
    expect(adapter.lastOptions?.path, '/subjects/subject-1/courses');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test('creates a real course with the CORE-02 payload', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(courseJson()));
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final course = await repository.createCourse(
      subjectId: 'subject-1',
      input: const CreateCourseInput(
        title: 'Droit constitutionnel',
        description: 'Institutions',
        chapterLabel: 'Chapitre 1',
        estimatedMinutes: 30,
      ),
    );

    expect(course.id, 'course-1');
    expect(adapter.lastOptions?.method, 'POST');
    expect(adapter.lastOptions?.path, '/subjects/subject-1/courses');
    expect(adapter.lastOptions?.data, {
      'title': 'Droit constitutionnel',
      'description': 'Institutions',
      'chapterLabel': 'Chapitre 1',
      'estimatedMinutes': 30,
    });
  });

  test('loads course detail with subject and sources', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({
        'course': courseJson(sourceCount: 1, readySourceCount: 1),
        'subject': {'id': 'subject-1', 'name': 'Droit'},
        'sources': [sourceJson()],
      }),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final detail = await repository.getCourse(courseId: 'course-1');

    expect(detail.subject.name, 'Droit');
    expect(detail.sources.single.status, CourseDocumentStatus.ready);
    expect(detail.sources.single.errorCode, isNull);
    expect(adapter.lastOptions?.path, '/courses/course-1');
  });

  test('maps backend 404 to CourseNotFoundException', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({'message': 'Course not found'}, statusCode: 404),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      repository.getCourse(courseId: 'unknown'),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test('uploads a course PDF as multipart without subjectId', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(sourceJsonWith(status: 'UPLOADED')),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final source = await repository.uploadCoursePdf(
      courseId: 'course-1',
      fileName: 'cours.pdf',
      bytes: Uint8List.fromList('%PDF-1.7'.codeUnits),
    );

    expect(source.status, CourseDocumentStatus.uploaded);
    expect(adapter.lastOptions?.method, 'POST');
    expect(adapter.lastOptions?.path, '/courses/course-1/source/course-pdf');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );

    final formData = adapter.lastOptions?.data as FormData;
    expect(
      formData.fields.map((field) => field.key),
      isNot(contains('subjectId')),
    );
    expect(
      formData.fields.map((field) => field.key),
      isNot(contains('studentId')),
    );
    expect(formData.files.single.key, 'file');
    expect(formData.files.single.value.filename, 'cours.pdf');
  });

  test('maps upload 400 and 404 to typed course exceptions', () async {
    final badRequest = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({'message': 'Invalid file'}, statusCode: 400),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      badRequest.uploadCoursePdf(
        courseId: 'course-1',
        fileName: 'cours.txt',
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
      throwsA(isA<CourseUploadException>()),
    );

    final notFound = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({'message': 'Course not found'}, statusCode: 404),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      notFound.uploadCoursePdf(
        courseId: 'missing',
        fileName: 'cours.pdf',
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test(
    'deletes a course source through the encoded course-scoped endpoint',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(null, statusCode: 204),
      );
      final repository = HttpCoursesRepository(
        dio: Dio()..httpClientAdapter = adapter,
        getIdToken: () async => 'firebase-id-token',
      );

      await repository.deleteCourseDocument(
        courseId: 'course id/1',
        documentId: 'document id/1',
      );

      expect(adapter.lastOptions?.method, 'DELETE');
      expect(
        adapter.lastOptions?.path,
        '/courses/course%20id%2F1/sources/document%20id%2F1',
      );
      expect(adapter.lastOptions?.data, isNull);
      expect(
        adapter.lastOptions?.headers['Authorization'],
        'Bearer firebase-id-token',
      );
    },
  );

  test('maps course source delete 404 to CourseNotFoundException', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({'message': 'Course source not found'}, statusCode: 404),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      repository.deleteCourseDocument(
        courseId: 'course-1',
        documentId: 'missing-document',
      ),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test(
    'loads a course-level revision sheet from the course endpoint',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(revisionSheetJson()),
      );
      final repository = HttpCoursesRepository(
        dio: Dio()..httpClientAdapter = adapter,
        getIdToken: () async => 'firebase-id-token',
      );

      final sheet = await repository.getCourseRevisionSheet(
        courseId: 'course-1',
      );

      expect(sheet?.title, 'Fiche de cours');
      expect(sheet?.sections.single.title, 'Institutions');
      expect(adapter.lastOptions?.method, 'GET');
      expect(adapter.lastOptions?.path, '/courses/course-1/revision-sheet');
    },
  );

  test(
    'generates a course-level revision sheet without documentId payload',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(revisionSheetJson()),
      );
      final repository = HttpCoursesRepository(
        dio: Dio()..httpClientAdapter = adapter,
        getIdToken: () async => 'firebase-id-token',
      );

      final sheet = await repository.generateCourseRevisionSheet(
        courseId: 'course-1',
      );

      expect(sheet.title, 'Fiche de cours');
      expect(adapter.lastOptions?.method, 'POST');
      expect(adapter.lastOptions?.path, '/courses/course-1/revision-sheet');
      expect(adapter.lastOptions?.data, isNull);
    },
  );

  test(
    'maps course-level revision sheet 404 and 409 to typed outcomes',
    () async {
      final notFoundRepository = HttpCoursesRepository(
        dio: Dio()
          ..httpClientAdapter = CapturingHttpClientAdapter(
            jsonResponse({
              'message': 'Revision sheet not found',
            }, statusCode: 404),
          ),
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        notFoundRepository.getCourseRevisionSheet(courseId: 'course-1'),
        completion(isNull),
      );

      final missingCourseRepository = HttpCoursesRepository(
        dio: Dio()
          ..httpClientAdapter = CapturingHttpClientAdapter(
            jsonResponse({'message': 'Course not found'}, statusCode: 404),
          ),
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        missingCourseRepository.getCourseRevisionSheet(courseId: 'course-1'),
        throwsA(isA<CourseNotFoundException>()),
      );

      final notReadyRepository = HttpCoursesRepository(
        dio: Dio()
          ..httpClientAdapter = CapturingHttpClientAdapter(
            jsonResponse({
              'message': 'Course has no ready source',
            }, statusCode: 409),
          ),
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        notReadyRepository.generateCourseRevisionSheet(courseId: 'course-1'),
        throwsA(isA<CourseRevisionSheetNotReadyException>()),
      );
    },
  );

  test('starts a course quick revision without client-owned ids', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(courseId: 'course-1')),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await repository.startCourseQuickRevision(
      courseId: 'course-1',
    );

    expect(response.session.id, 'revision-session-1');
    expect(response.session.courseId, 'course-1');
    expect(response.currentAction?.kind.name, 'diagnosticQuiz');
    expect(adapter.lastOptions?.method, 'POST');
    expect(
      adapter.lastOptions?.path,
      '/courses/course-1/revision-sessions/quick',
    );
    expect(adapter.lastOptions?.data, isNull);
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test('loads course progress from the course progress endpoint', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(courseProgressJson()),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final progress = await repository.getCourseProgress(courseId: 'course-1');

    expect(progress.knowledgeUnitCount, 12);
    expect(progress.practicedKnowledgeUnitCount, 3);
    expect(progress.coverage, 0.25);
    expect(progress.mastery, 0.72);
    expect(progress.estimatedGlobalMastery, 0.18);
    expect(progress.state, CourseProgressState.practiced);
    expect(adapter.lastOptions?.method, 'GET');
    expect(adapter.lastOptions?.path, '/courses/course-1/progress');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test('loads subject progress and maps unknown course state safely', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(
        subjectProgressJson(
          courses: [subjectCourseProgressJson(state: 'FUTURE_STATE')],
        ),
      ),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final progress = await repository.getSubjectProgress(
      subjectId: 'subject-1',
    );

    expect(progress.courseCount, 1);
    expect(progress.readyCourseCount, 1);
    expect(progress.courses.single.state, CourseProgressState.unknown);
    expect(adapter.lastOptions?.method, 'GET');
    expect(adapter.lastOptions?.path, '/subjects/subject-1/progress');
  });

  test('parses nullable mastery and progress 404 errors', () async {
    final noMasteryRepository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse(courseProgressJson(mastery: null)),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    final progress = await noMasteryRepository.getCourseProgress(
      courseId: 'course-1',
    );

    expect(progress.mastery, isNull);

    final missingCourseRepository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({'message': 'Course not found'}, statusCode: 404),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      missingCourseRepository.getCourseProgress(courseId: 'missing'),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test('maps course quick revision 404 and 409 to typed exceptions', () async {
    final missingCourseRepository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({'message': 'Course not found'}, statusCode: 404),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      missingCourseRepository.startCourseQuickRevision(courseId: 'missing'),
      throwsA(isA<CourseNotFoundException>()),
    );

    final notReadyRepository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({
            'message': 'Course has no ready knowledge unit',
          }, statusCode: 409),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      notReadyRepository.startCourseQuickRevision(courseId: 'course-1'),
      throwsA(
        isA<CourseQuickRevisionUnavailableException>().having(
          (error) => error.message,
          'message',
          'Course has no ready knowledge unit',
        ),
      ),
    );
  });

  test('rejects unknown source status and invalid shapes', () async {
    final invalidStatus = sourceJson()..['status'] = 'ARCHIVED';
    final repository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({
            'course': courseJson(),
            'subject': {'id': 'subject-1', 'name': 'Droit'},
            'sources': [invalidStatus],
          }),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      repository.getCourse(courseId: 'course-1'),
      throwsFormatException,
    );
  });
}

Map<String, Object?> revisionSessionJson({required String courseId}) {
  return {
    'session': {
      'id': 'revision-session-1',
      'status': 'STARTED',
      'subjectId': 'subject-1',
      'courseId': courseId,
      'documentId': 'document-1',
      'knowledgeUnitId': 'knowledge-unit-1',
      'createdAt': '2026-06-18T10:00:00.000Z',
      'completedAt': null,
    },
    'currentAction': {
      'id': 'action-1',
      'kind': 'DIAGNOSTIC_QUIZ',
      'status': 'READY',
      'displayOrder': 0,
      'activitySessionId': 'activity-session-1',
      'documentId': 'document-1',
      'knowledgeUnitId': 'knowledge-unit-1',
      'payload': null,
    },
    'history': [],
  };
}

Map<String, Object?> courseJson({
  int sourceCount = 2,
  int readySourceCount = 1,
}) {
  return {
    'id': 'course-1',
    'subjectId': 'subject-1',
    'title': 'Droit constitutionnel',
    'description': 'Institutions',
    'chapterLabel': 'Chapitre 1',
    'estimatedMinutes': 30,
    'displayOrder': 0,
    'createdAt': '2026-06-18T10:00:00.000Z',
    'updatedAt': '2026-06-18T10:00:00.000Z',
    'sourceCount': sourceCount,
    'readySourceCount': readySourceCount,
    'processingSourceCount': 1,
    'failedSourceCount': 0,
  };
}

Map<String, Object?> sourceJson() {
  return sourceJsonWith(status: 'READY');
}

Map<String, Object?> sourceJsonWith({required String status}) {
  return {
    'id': 'document-1',
    'courseId': 'course-1',
    'documentId': 'document-1',
    'fileName': 'cours.pdf',
    'kind': 'COURSE_PDF',
    'status': status,
    'errorCode': null,
    'createdAt': '2026-06-18T10:00:00.000Z',
    'updatedAt': '2026-06-18T10:00:00.000Z',
  };
}

Map<String, Object?> courseProgressJson({Object? mastery = 0.72}) {
  return {
    'courseId': 'course-1',
    'subjectId': 'subject-1',
    'knowledgeUnitCount': 12,
    'practicedKnowledgeUnitCount': 3,
    'coverage': 0.25,
    'mastery': mastery,
    'estimatedGlobalMastery': 0.18,
    'readySourceCount': 1,
    'processingSourceCount': 0,
    'failedSourceCount': 0,
    'lastPracticedAt': '2026-06-18T12:00:00.000Z',
    'state': 'PRACTICED',
  };
}

Map<String, Object?> subjectProgressJson({
  List<Map<String, Object?>>? courses,
}) {
  return {
    'subjectId': 'subject-1',
    'knowledgeUnitCount': 12,
    'practicedKnowledgeUnitCount': 3,
    'coverage': 0.25,
    'mastery': 0.72,
    'estimatedGlobalMastery': 0.18,
    'courseCount': 1,
    'readyCourseCount': 1,
    'lastPracticedAt': '2026-06-18T12:00:00.000Z',
    'courses': courses ?? [subjectCourseProgressJson()],
  };
}

Map<String, Object?> subjectCourseProgressJson({String state = 'PRACTICED'}) {
  return {
    'courseId': 'course-1',
    'title': 'Droit constitutionnel',
    'knowledgeUnitCount': 12,
    'practicedKnowledgeUnitCount': 3,
    'coverage': 0.25,
    'mastery': 0.72,
    'estimatedGlobalMastery': 0.18,
    'state': state,
  };
}

Map<String, Object?> revisionSheetJson() {
  return {
    'id': 'sheet-1',
    'documentId': 'document-1',
    'subjectId': 'subject-1',
    'status': 'READY',
    'title': 'Fiche de cours',
    'introduction': 'Introduction',
    'keyPoints': ['Point clé'],
    'commonMistakes': ['Erreur fréquente'],
    'mustKnow': ['À savoir'],
    'practiceSuggestions': ['S’entraîner'],
    'errorCode': null,
    'sections': [
      {
        'id': 'section-1',
        'displayOrder': 0,
        'title': 'Institutions',
        'content': 'Le Parlement contrôle le Gouvernement.',
        'sources': [
          {
            'chunkId': 'chunk-1',
            'text': 'Extrait source',
            'pageNumber': 1,
            'index': 0,
          },
        ],
      },
    ],
  };
}

ResponseBody jsonResponse(Object? body, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

````````

### test/features/courses/courses_providers_test.dart

````````dart
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/courses/application/course_pdf_picker.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/courses/domain/courses_repository.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';

import '../../fakes/in_memory_courses_repository.dart';

void main() {
  test('coursesProvider loads real courses for a subject', () async {
    final repository = InMemoryCoursesRepository()
      ..coursesBySubject['subject-1'] = const [
        CourseListItem(
          id: 'course-1',
          subjectId: 'subject-1',
          title: 'Droit constitutionnel',
          sourceCount: 0,
          readySourceCount: 0,
          processingSourceCount: 0,
          failedSourceCount: 0,
        ),
      ];
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final courses = await container.read(coursesProvider('subject-1').future);

    expect(courses.single.title, 'Droit constitutionnel');
  });

  test('createCourseController invalidates the subject course list', () async {
    final repository = InMemoryCoursesRepository();
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    expect(await container.read(coursesProvider('subject-1').future), isEmpty);

    final created = await container
        .read(createCourseControllerProvider.notifier)
        .create(
          subjectId: 'subject-1',
          input: const CreateCourseInput(title: 'Droit constitutionnel'),
        );

    expect(created.title, 'Droit constitutionnel');
    expect(
      await container.read(coursesProvider('subject-1').future),
      hasLength(1),
    );
  });

  test('course detail repository exposes typed not-found errors', () async {
    final repository = InMemoryCoursesRepository();

    await expectLater(
      repository.getCourse(courseId: 'unknown'),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test(
    'uploadCourseDocumentController does nothing when picking is cancelled',
    () async {
      final repository = InMemoryCoursesRepository()
        ..progressByCourse['course-1'] = courseProgress()
        ..progressBySubject['subject-1'] = subjectProgress();
      final picker = FakeCoursePdfPicker(null);
      final container = ProviderContainer(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(repository),
          coursePdfPickerProvider.overrideWithValue(picker),
        ],
      );
      addTearDown(container.dispose);

      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);
      final initialCourseProgressReads = repository.getCourseProgressCount;
      final initialSubjectProgressReads = repository.getSubjectProgressCount;

      final result = await container
          .read(uploadCourseDocumentControllerProvider.notifier)
          .upload(detail: courseDetail());

      expect(result, isNull);
      expect(picker.pickCount, 1);
      expect(repository.uploadCount, 0);
      expect(
        container.read(uploadCourseDocumentControllerProvider).hasError,
        false,
      );
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);
      expect(repository.getCourseProgressCount, initialCourseProgressReads);
      expect(repository.getSubjectProgressCount, initialSubjectProgressReads);
    },
  );

  test(
    'uploadCourseDocumentController uploads and invalidates detail lists and progress',
    () async {
      final repository = InMemoryCoursesRepository()
        ..coursesBySubject['subject-1'] = const [
          CourseListItem(
            id: 'course-1',
            subjectId: 'subject-1',
            title: 'Droit constitutionnel',
          ),
        ]
        ..detailsByCourse['course-1'] = courseDetail()
        ..progressByCourse['course-1'] = courseProgress()
        ..progressBySubject['subject-1'] = subjectProgress();
      final picker = FakeCoursePdfPicker(
        PickedCoursePdf(
          fileName: 'cours.pdf',
          bytes: Uint8List.fromList('%PDF-1.7'.codeUnits),
        ),
      );
      final container = ProviderContainer(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(repository),
          coursePdfPickerProvider.overrideWithValue(picker),
        ],
      );
      addTearDown(container.dispose);

      expect(
        (await container.read(courseDetailProvider('course-1').future)).sources,
        isEmpty,
      );
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      final initialDetailReads = repository.getCourseCount;
      final initialListReads = repository.listCoursesCount;
      final initialCourseProgressReads = repository.getCourseProgressCount;
      final initialSubjectProgressReads = repository.getSubjectProgressCount;

      final uploaded = await container
          .read(uploadCourseDocumentControllerProvider.notifier)
          .upload(detail: courseDetail());

      expect(uploaded?.fileName, 'cours.pdf');
      expect(repository.uploadCount, 1);
      expect(repository.lastUploadedCourseId, 'course-1');
      expect(
        (await container.read(courseDetailProvider('course-1').future)).sources,
        hasLength(1),
      );
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      expect(repository.getCourseCount, greaterThan(initialDetailReads));
      expect(repository.listCoursesCount, greaterThan(initialListReads));
      expect(
        repository.getCourseProgressCount,
        greaterThan(initialCourseProgressReads),
      );
      expect(
        repository.getSubjectProgressCount,
        greaterThan(initialSubjectProgressReads),
      );
    },
  );

  test('uploadCourseDocumentController exposes upload errors', () async {
    final repository = InMemoryCoursesRepository()
      ..progressByCourse['course-1'] = courseProgress()
      ..progressBySubject['subject-1'] = subjectProgress()
      ..uploadError = const CourseUploadException('Invalid PDF');
    final picker = FakeCoursePdfPicker(
      PickedCoursePdf(fileName: 'cours.pdf', bytes: Uint8List.fromList([1])),
    );
    final container = ProviderContainer(
      overrides: [
        coursesRepositoryProvider.overrideWithValue(repository),
        coursePdfPickerProvider.overrideWithValue(picker),
      ],
    );
    addTearDown(container.dispose);

    await container.read(courseProgressProvider('course-1').future);
    await container.read(subjectProgressProvider('subject-1').future);
    final initialCourseProgressReads = repository.getCourseProgressCount;
    final initialSubjectProgressReads = repository.getSubjectProgressCount;

    await expectLater(
      container
          .read(uploadCourseDocumentControllerProvider.notifier)
          .upload(detail: courseDetail()),
      throwsA(isA<CourseUploadException>()),
    );

    expect(
      container.read(uploadCourseDocumentControllerProvider).hasError,
      true,
    );
    await container.read(courseProgressProvider('course-1').future);
    await container.read(subjectProgressProvider('subject-1').future);
    expect(repository.getCourseProgressCount, initialCourseProgressReads);
    expect(repository.getSubjectProgressCount, initialSubjectProgressReads);
  });

  test(
    'deleteCourseDocumentController removes a source and refreshes course surfaces',
    () async {
      final repository = InMemoryCoursesRepository()
        ..coursesBySubject['subject-1'] = const [
          CourseListItem(
            id: 'course-1',
            subjectId: 'subject-1',
            title: 'Droit constitutionnel',
          ),
        ]
        ..detailsByCourse['course-1'] = courseDetail(
          sources: const [
            CourseDocument(
              id: 'document-1',
              courseId: 'course-1',
              documentId: 'document-1',
              fileName: 'cours.pdf',
              status: CourseDocumentStatus.ready,
            ),
          ],
        )
        ..progressByCourse['course-1'] = courseProgress()
        ..progressBySubject['subject-1'] = subjectProgress();
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      expect(
        (await container.read(courseDetailProvider('course-1').future)).sources,
        hasLength(1),
      );
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      final initialDetailReads = repository.getCourseCount;
      final initialListReads = repository.listCoursesCount;
      final initialCourseProgressReads = repository.getCourseProgressCount;
      final initialSubjectProgressReads = repository.getSubjectProgressCount;

      await container
          .read(deleteCourseDocumentControllerProvider.notifier)
          .delete(
            detail: repository.detailsByCourse['course-1']!,
            documentId: 'document-1',
          );

      expect(repository.deleteDocumentCount, 1);
      expect(repository.lastDeletedCourseId, 'course-1');
      expect(repository.lastDeletedDocumentId, 'document-1');
      expect(
        (await container.read(courseDetailProvider('course-1').future)).sources,
        isEmpty,
      );
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      expect(repository.getCourseCount, greaterThan(initialDetailReads));
      expect(repository.listCoursesCount, greaterThan(initialListReads));
      expect(
        repository.getCourseProgressCount,
        greaterThan(initialCourseProgressReads),
      );
      expect(
        repository.getSubjectProgressCount,
        greaterThan(initialSubjectProgressReads),
      );
    },
  );

  test(
    'deleteCourseDocumentController exposes errors without refreshing',
    () async {
      final repository = InMemoryCoursesRepository()
        ..coursesBySubject['subject-1'] = const [
          CourseListItem(
            id: 'course-1',
            subjectId: 'subject-1',
            title: 'Droit constitutionnel',
          ),
        ]
        ..detailsByCourse['course-1'] = courseDetail(
          sources: const [
            CourseDocument(
              id: 'document-1',
              courseId: 'course-1',
              documentId: 'document-1',
              fileName: 'cours.pdf',
              status: CourseDocumentStatus.ready,
            ),
          ],
        )
        ..progressByCourse['course-1'] = courseProgress()
        ..progressBySubject['subject-1'] = subjectProgress()
        ..deleteDocumentError = const CourseNotFoundException(
          'Course source not found',
        );
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(courseDetailProvider('course-1').future);
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      final initialDetailReads = repository.getCourseCount;
      final initialListReads = repository.listCoursesCount;
      final initialCourseProgressReads = repository.getCourseProgressCount;
      final initialSubjectProgressReads = repository.getSubjectProgressCount;

      await expectLater(
        container
            .read(deleteCourseDocumentControllerProvider.notifier)
            .delete(
              detail: repository.detailsByCourse['course-1']!,
              documentId: 'document-1',
            ),
        throwsA(isA<CourseNotFoundException>()),
      );

      expect(
        container.read(deleteCourseDocumentControllerProvider).hasError,
        true,
      );
      await container.read(courseDetailProvider('course-1').future);
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);
      expect(repository.getCourseCount, initialDetailReads);
      expect(repository.listCoursesCount, initialListReads);
      expect(repository.getCourseProgressCount, initialCourseProgressReads);
      expect(repository.getSubjectProgressCount, initialSubjectProgressReads);
    },
  );

  test(
    'courseRevisionSheetProvider loads an existing course-level sheet',
    () async {
      final repository = InMemoryCoursesRepository()
        ..revisionSheetsByCourse['course-1'] = revisionSheet();
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final sheet = await container.read(
        courseRevisionSheetProvider('course-1').future,
      );

      expect(sheet?.title, 'Fiche de cours');
      expect(repository.getRevisionSheetCount, 1);
    },
  );

  test('courseProgressProvider loads real course progress', () async {
    final repository = InMemoryCoursesRepository()
      ..progressByCourse['course-1'] = courseProgress();
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final progress = await container.read(
      courseProgressProvider('course-1').future,
    );

    expect(progress.state, CourseProgressState.practiced);
    expect(progress.estimatedGlobalMastery, 0.18);
    expect(repository.getCourseProgressCount, 1);
  });

  test('subjectProgressProvider loads real subject progress', () async {
    final repository = InMemoryCoursesRepository()
      ..progressBySubject['subject-1'] = subjectProgress();
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final progress = await container.read(
      subjectProgressProvider('subject-1').future,
    );

    expect(progress.courses.single.title, 'Droit constitutionnel');
    expect(progress.readyCourseCount, 1);
    expect(repository.getSubjectProgressCount, 1);
  });

  test(
    'generateCourseRevisionSheetController generates and invalidates',
    () async {
      final repository = InMemoryCoursesRepository()
        ..revisionSheetsByCourse['course-1'] = revisionSheet();
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(courseRevisionSheetProvider('course-1').future);

      final sheet = await container
          .read(generateCourseRevisionSheetControllerProvider.notifier)
          .generate(courseId: 'course-1');

      expect(sheet.title, 'Fiche de cours');
      expect(repository.generateRevisionSheetCount, 1);
      expect(
        await container.read(courseRevisionSheetProvider('course-1').future),
        isNotNull,
      );
    },
  );

  test(
    'generateCourseRevisionSheetController exposes not-ready errors',
    () async {
      final repository = InMemoryCoursesRepository()
        ..revisionSheetErrorsByCourse['course-1'] =
            const CourseRevisionSheetNotReadyException(
              'Course has no ready source',
            );
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await expectLater(
        container
            .read(generateCourseRevisionSheetControllerProvider.notifier)
            .generate(courseId: 'course-1'),
        throwsA(isA<CourseRevisionSheetNotReadyException>()),
      );

      expect(
        container.read(generateCourseRevisionSheetControllerProvider).hasError,
        true,
      );
    },
  );

  test(
    'startCourseQuickRevisionController starts a real course session',
    () async {
      final repository = InMemoryCoursesRepository()
        ..detailsByCourse['course-1'] = courseDetail();
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final response = await container
          .read(startCourseQuickRevisionControllerProvider.notifier)
          .start(detail: courseDetail());

      expect(response.session.id, 'revision-session-1');
      expect(response.session.courseId, 'course-1');
      expect(repository.startQuickRevisionCount, 1);
      expect(repository.lastQuickRevisionCourseId, 'course-1');
      expect(
        container.read(startCourseQuickRevisionControllerProvider).hasError,
        false,
      );
    },
  );

  test('startCourseQuickRevisionController exposes readiness errors', () async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..quickRevisionError = const CourseQuickRevisionUnavailableException(
        'Course has no ready knowledge unit',
      );
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await expectLater(
      container
          .read(startCourseQuickRevisionControllerProvider.notifier)
          .start(detail: courseDetail()),
      throwsA(isA<CourseQuickRevisionUnavailableException>()),
    );

    expect(
      container.read(startCourseQuickRevisionControllerProvider).hasError,
      true,
    );
  });
}

CourseDetail courseDetail({List<CourseDocument> sources = const []}) {
  const course = CourseListItem(
    id: 'course-1',
    subjectId: 'subject-1',
    title: 'Droit constitutionnel',
  );
  return CourseDetail(
    course: course,
    subject: const CourseSubjectSummary(id: 'subject-1', name: 'Droit'),
    sources: sources,
  );
}

RevisionSheet revisionSheet() {
  return const RevisionSheet(
    id: 'sheet-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Fiche de cours',
    introduction: 'Introduction',
    sections: [
      RevisionSheetSection(
        id: 'section-1',
        displayOrder: 0,
        title: 'Institutions',
        content: 'Le Parlement contrôle le Gouvernement.',
        sources: [],
      ),
    ],
    keyPoints: ['Point clé'],
    commonMistakes: ['Erreur fréquente'],
    mustKnow: ['À savoir'],
    practiceSuggestions: ['S’entraîner'],
    errorCode: null,
  );
}

CourseProgress courseProgress() {
  return CourseProgress(
    courseId: 'course-1',
    subjectId: 'subject-1',
    knowledgeUnitCount: 12,
    practicedKnowledgeUnitCount: 3,
    coverage: 0.25,
    mastery: 0.72,
    estimatedGlobalMastery: 0.18,
    readySourceCount: 1,
    processingSourceCount: 0,
    failedSourceCount: 0,
    lastPracticedAt: DateTime.utc(2026, 6, 18, 12),
    state: CourseProgressState.practiced,
  );
}

SubjectProgress subjectProgress() {
  return SubjectProgress(
    subjectId: 'subject-1',
    knowledgeUnitCount: 12,
    practicedKnowledgeUnitCount: 3,
    coverage: 0.25,
    mastery: 0.72,
    estimatedGlobalMastery: 0.18,
    courseCount: 1,
    readyCourseCount: 1,
    lastPracticedAt: DateTime.utc(2026, 6, 18, 12),
    courses: const [
      SubjectCourseProgressItem(
        courseId: 'course-1',
        title: 'Droit constitutionnel',
        knowledgeUnitCount: 12,
        practicedKnowledgeUnitCount: 3,
        coverage: 0.25,
        mastery: 0.72,
        estimatedGlobalMastery: 0.18,
        state: CourseProgressState.practiced,
      ),
    ],
  );
}

class FakeCoursePdfPicker implements CoursePdfPicker {
  FakeCoursePdfPicker(this.result);

  final PickedCoursePdf? result;
  int pickCount = 0;

  @override
  Future<PickedCoursePdf?> pickPdf() async {
    pickCount += 1;
    return result;
  }
}

````````

### test/features/courses/course_detail_page_test.dart

````````dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/app/router/app_routes.dart';
import 'package:revision_app/features/courses/application/course_pdf_picker.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/courses/domain/courses_repository.dart';
import 'package:revision_app/features/courses/presentation/course_detail_page.dart';
import 'package:revision_app/presentation/design_system/components/revision_mvp_components.dart';

import '../../fakes/in_memory_courses_repository.dart';

void main() {
  testWidgets('course detail uploads a PDF source without fixture content', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..uploadDelay = const Duration(milliseconds: 50);
    final picker = FakeCoursePdfPicker(
      PickedCoursePdf(
        fileName: 'cours.pdf',
        bytes: Uint8List.fromList('%PDF-1.7'.codeUnits),
      ),
    );

    await tester.pumpWidget(testApp(repository: repository, picker: picker));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text('Droit constitutionnel'), findsOneWidget);
    expect(find.text('Ajouter une source'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('870'), findsNothing);
    expect(find.text('7 jours'), findsNothing);

    final uploadButton = find.widgetWithText(
      RevisionGradientButton,
      'Ajouter une source',
    );
    await tester.scrollUntilVisible(uploadButton, 400);
    await tester.tap(uploadButton);
    await tester.pump();

    expect(find.text('Upload en cours...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump();

    expect(repository.uploadCount, 1);
    expect(repository.lastUploadedCourseId, 'course-1');
    expect(repository.lastUploadedFileName, 'cours.pdf');
    expect(find.text('Source ajoutée'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('cours.pdf'), 400);
    expect(find.text('cours.pdf'), findsOneWidget);
    expect(find.text('Téléversée'), findsOneWidget);
  });

  testWidgets('course detail displays failed source errors', (tester) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'broken.pdf',
            status: CourseDocumentStatus.failed,
            errorCode: 'PDF_PARSE_FAILED',
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('broken.pdf'), 400);
    expect(find.text('broken.pdf'), findsOneWidget);
    expect(find.text('Erreur'), findsOneWidget);
    expect(find.textContaining('PDF_PARSE_FAILED'), findsOneWidget);
  });

  testWidgets('course detail deletes a source after confirmation', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'cours.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('cours.pdf'), 400);
    expect(find.text('cours.pdf'), findsOneWidget);

    await tester.tap(find.byTooltip('Supprimer la source cours.pdf'));
    await tester.pumpAndSettle();

    expect(find.text('Supprimer cette source ?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(repository.deleteDocumentCount, 1);
    expect(repository.lastDeletedDocumentId, 'document-1');
    expect(find.text('Source supprimée'), findsOneWidget);
    expect(find.text('Aucune source attachée'), findsOneWidget);
  });

  testWidgets('course detail shows an error when source deletion fails', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'cours.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      )
      ..deleteDocumentError = const CourseNotFoundException(
        'Course source not found',
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('cours.pdf'), 400);
    await tester.tap(find.byTooltip('Supprimer la source cours.pdf'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(repository.deleteDocumentCount, 0);
    expect(find.text('Impossible de supprimer cette source.'), findsOneWidget);
    expect(find.text('cours.pdf'), findsOneWidget);
  });

  testWidgets('course detail displays no-source progress state', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..progressByCourse['course-1'] = courseProgress(
        state: CourseProgressState.noSource,
        knowledgeUnitCount: 0,
        practicedKnowledgeUnitCount: 0,
        coverage: 0,
        mastery: null,
        estimatedGlobalMastery: 0,
        readySourceCount: 0,
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Progression réelle'), findsOneWidget);
    expect(find.text('0/0 notions travaillées'), findsOneWidget);
    expect(find.text('Ajoute une source pour commencer.'), findsOneWidget);
    expect(find.text('78%'), findsNothing);
  });

  testWidgets('course detail displays practiced real progress', (tester) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'ready.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      )
      ..progressByCourse['course-1'] = courseProgress();

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('3/12 notions travaillées'), findsOneWidget);
    expect(find.text('Maîtrise sur notions travaillées : 72%'), findsOneWidget);
    expect(find.text('Estimation globale : 18%'), findsOneWidget);
    expect(
      find.text('Progression réelle basée sur tes réponses.'),
      findsOneWidget,
    );
  });

  testWidgets('processing sources trigger bounded detail refresh polling', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'processing.pdf',
            status: CourseDocumentStatus.processing,
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pump();
    await tester.pump();

    expect(repository.getCourseCount, 1);
    expect(repository.getCourseProgressCount, 1);
    await tester.scrollUntilVisible(find.text('Traitement en cours'), 400);
    expect(find.text('Traitement en cours'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(repository.getCourseCount, greaterThanOrEqualTo(2));
    expect(repository.getCourseProgressCount, greaterThanOrEqualTo(2));
  });

  testWidgets('ready failed and empty sources do not trigger polling', (
    tester,
  ) async {
    for (final sources in [
      const <CourseDocument>[],
      const [
        CourseDocument(
          id: 'document-ready',
          courseId: 'course-1',
          documentId: 'document-ready',
          fileName: 'ready.pdf',
          status: CourseDocumentStatus.ready,
        ),
      ],
      const [
        CourseDocument(
          id: 'document-failed',
          courseId: 'course-1',
          documentId: 'document-failed',
          fileName: 'failed.pdf',
          status: CourseDocumentStatus.failed,
          errorCode: 'KNOWLEDGE_EXTRACTION_FAILED',
        ),
      ],
    ]) {
      final repository = InMemoryCoursesRepository()
        ..detailsByCourse['course-1'] = courseDetail(sources: sources);

      await tester.pumpWidget(
        testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
      );
      await tester.pump();
      await tester.pump();

      final detailReads = repository.getCourseCount;
      final progressReads = repository.getCourseProgressCount;

      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(repository.getCourseCount, detailReads);
      expect(repository.getCourseProgressCount, progressReads);
    }
  });

  testWidgets('course sheet CTA asks for a source when none exists', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail();

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    final emptyButton = tester.widget<RevisionGradientButton>(
      find.widgetWithText(
        RevisionGradientButton,
        'Ajoute une source pour créer une fiche',
      ),
    );
    expect(emptyButton.onPressed, isNull);

    final emptyQuickButton = tester.widget<RevisionGradientButton>(
      find.widgetWithText(
        RevisionGradientButton,
        'Ajoute une source pour réviser',
      ),
    );
    expect(emptyQuickButton.onPressed, isNull);
  });

  testWidgets('course sheet CTA waits while a source is processing', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'processing.pdf',
            status: CourseDocumentStatus.processing,
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    final processingSheetButton = tester.widget<RevisionGradientButton>(
      find.widgetWithText(
        RevisionGradientButton,
        'Fiche disponible après traitement',
      ),
    );
    expect(processingSheetButton.onPressed, isNull);

    final processingQuickButton = tester.widget<RevisionGradientButton>(
      find.widgetWithText(
        RevisionGradientButton,
        'Révision disponible après traitement',
      ),
    );
    expect(processingQuickButton.onPressed, isNull);
  });

  testWidgets('course sheet CTA is enabled when a READY source exists', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'ready.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    final sheetButton = tester.widget<RevisionGradientButton>(
      find.widgetWithText(RevisionGradientButton, 'Fiche de cours'),
    );
    expect(sheetButton.onPressed, isNotNull);

    final quickButton = tester.widget<RevisionGradientButton>(
      find.widgetWithText(RevisionGradientButton, 'Révision rapide'),
    );
    expect(quickButton.onPressed, isNotNull);
  });

  testWidgets('ready quick revision starts the real revision session route', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'ready.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      )
      ..quickRevisionDelay = const Duration(milliseconds: 50);

    await tester.pumpWidget(
      routerTestApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    final quickButton = find.widgetWithText(
      RevisionGradientButton,
      'Révision rapide',
    );
    final quickWidget = tester.widget<RevisionGradientButton>(quickButton);
    quickWidget.onPressed!();
    await tester.pump();

    expect(find.text('Démarrage...'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(repository.startQuickRevisionCount, 1);
    expect(repository.lastQuickRevisionCourseId, 'course-1');
    expect(find.text('Session réelle'), findsOneWidget);
  });
}

Widget testApp({
  required InMemoryCoursesRepository repository,
  required CoursePdfPicker picker,
}) {
  _ensureDefaultProgress(repository);

  return ProviderScope(
    overrides: [
      coursesRepositoryProvider.overrideWithValue(repository),
      coursePdfPickerProvider.overrideWithValue(picker),
    ],
    child: const MaterialApp(
      home: Scaffold(body: CourseDetailPage(courseId: 'course-1')),
    ),
  );
}

Widget routerTestApp({
  required InMemoryCoursesRepository repository,
  required CoursePdfPicker picker,
}) {
  _ensureDefaultProgress(repository);

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: CourseDetailPage(courseId: 'course-1')),
      ),
      GoRoute(
        path: AppRoutes.revisionSessionPath,
        builder: (context, state) => Scaffold(
          body: Text(
            state.uri.queryParameters['sessionId'] == 'revision-session-1'
                ? 'Session réelle'
                : 'Session inconnue',
          ),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      coursesRepositoryProvider.overrideWithValue(repository),
      coursePdfPickerProvider.overrideWithValue(picker),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void _ensureDefaultProgress(InMemoryCoursesRepository repository) {
  repository.progressByCourse.putIfAbsent(
    'course-1',
    () => courseProgress(
      state: CourseProgressState.noSource,
      knowledgeUnitCount: 0,
      practicedKnowledgeUnitCount: 0,
      coverage: 0,
      mastery: null,
      estimatedGlobalMastery: 0,
      readySourceCount: 0,
    ),
  );
}

CourseDetail courseDetail({List<CourseDocument> sources = const []}) {
  const course = CourseListItem(
    id: 'course-1',
    subjectId: 'subject-1',
    title: 'Droit constitutionnel',
    sourceCount: 0,
    readySourceCount: 0,
    processingSourceCount: 0,
    failedSourceCount: 0,
  );
  return CourseDetail(
    course: course,
    subject: const CourseSubjectSummary(id: 'subject-1', name: 'Droit'),
    sources: sources,
  );
}

CourseProgress courseProgress({
  CourseProgressState state = CourseProgressState.practiced,
  int knowledgeUnitCount = 12,
  int practicedKnowledgeUnitCount = 3,
  double coverage = 0.25,
  double? mastery = 0.72,
  double estimatedGlobalMastery = 0.18,
  int readySourceCount = 1,
}) {
  return CourseProgress(
    courseId: 'course-1',
    subjectId: 'subject-1',
    knowledgeUnitCount: knowledgeUnitCount,
    practicedKnowledgeUnitCount: practicedKnowledgeUnitCount,
    coverage: coverage,
    mastery: mastery,
    estimatedGlobalMastery: estimatedGlobalMastery,
    readySourceCount: readySourceCount,
    processingSourceCount: 0,
    failedSourceCount: 0,
    lastPracticedAt: DateTime.utc(2026, 6, 18, 12),
    state: state,
  );
}

class FakeCoursePdfPicker implements CoursePdfPicker {
  FakeCoursePdfPicker(this.result);

  final PickedCoursePdf? result;

  @override
  Future<PickedCoursePdf?> pickPdf() async => result;
}

````````

### docs/core/MVP_CORE_ACCEPTANCE_RUNBOOK.md

````````md
# MVP Core acceptance runbook

Ce runbook vérifie le parcours MVP Core réel côté Flutter, sans fixtures MVP dans le routing réel.

## Parcours utilisateur

1. Ouvrir l'app avec un utilisateur authentifié.
2. Voir les matières réelles.
3. Créer ou ouvrir un cours réel.
4. Ouvrir le détail du cours.
5. Cliquer sur `Ajouter une source`.
6. Choisir un PDF réel.
7. Attendre le traitement jusqu'au statut `Prête`.
8. Supprimer optionnellement une source de test depuis le détail du cours, avec confirmation.
9. Ajouter ou conserver une source `READY`.
10. Ouvrir `Fiche de cours`.
11. Revenir au cours.
12. Démarrer `Révision rapide`.
13. Répondre au QCM.
14. Revenir sur le cours ou l'onglet `Progrès`.
15. Vérifier la progression réelle.

## Vérifications UI attendues

- Le détail cours affiche uniquement les sources réelles de l'API.
- Une source `UPLOADED` ou `PROCESSING` déclenche un polling borné.
- Pendant ce polling, le détail et la progression sont rafraîchis.
- La suppression d'une source demande confirmation, affiche un feedback, puis rafraîchit détail, liste de cours, progression cours et progression matière.
- La fiche n'est activée que si une source `READY` existe.
- La révision rapide n'est activée que si une source `READY` existe.
- `/progress` affiche `SubjectProgressPage`, pas une page pending CORE-06.
- Les compteurs fake `78%`, `870`, `7 jours` et `Loi normale` ne doivent pas apparaître dans le parcours réel.

## Commandes de validation

```bash
dart analyze lib test
flutter test test/features/courses --reporter compact
flutter test test/features/revision_sessions --reporter compact
flutter test test/app/router/app_router_test.dart --reporter compact
flutter test test/app/revision_app_test.dart --reporter compact
flutter test test/app --reporter compact
flutter test --reporter compact
git diff --check
```

## Hors MVP Core

- Révision approfondie.
- Préparation examen.
- Résultat final dédié de session.
- Gamification durable.
- Multi-source avancé.
- `CourseSource`.
- WebSocket/SSE de progression.

## Notes de cohérence

- L'upload réussi invalide le détail, la liste de cours, la progression du cours et la progression matière.
- L'annulation du picker ne déclenche aucun upload ni refresh artificiel.
- L'échec d'upload ne simule pas une source réelle.
- La suppression réussie invalide le détail, la liste de cours, la progression du cours et la progression matière.
- L'échec de suppression affiche une erreur et ne rafraîchit pas la progression comme si la source avait disparu.
- Le démarrage d'une révision rapide ne rafraîchit pas la progression : la mastery change après submit, pas au start.
- La génération d'une fiche ne rafraîchit pas la progression : elle ne modifie ni `MasteryState` ni `Document.status`.

````````

### docs/core/CORE_06B_PROGRESS_REFRESH_AND_ACCEPTANCE_HARDENING_REPORT.md

````````md
# CORE-06B — Progress refresh coherence + MVP Core acceptance hardening

## 1. Résumé

CORE-06B côté Flutter corrige la cohérence de rafraîchissement de la progression après upload et pendant le polling d'une source PDF en traitement. L'upload réussi invalide désormais le détail cours, la liste de cours, la progression cours et la progression matière. Le polling borné du détail cours invalide aussi la progression cours et matière tant qu'une source est `UPLOADED` ou `PROCESSING`. Un runbook MVP Core frontend a été ajouté.

## 2. Audit initial

- `UploadCourseDocumentController.upload` invalidait `courseDetailProvider(courseId)` et `coursesProvider(subjectId)`, mais pas `courseProgressProvider(courseId)` ni `subjectProgressProvider(subjectId)`.
- `_CourseDetailContentState._syncPolling` invalidait seulement `courseDetailProvider(courseId)` toutes les 2 secondes pendant les sources pending.
- `GenerateCourseRevisionSheetController.generate` invalide uniquement `courseRevisionSheetProvider(courseId)`, ce qui reste correct : une fiche ne modifie ni `MasteryState` ni `Document.status`.
- `StartCourseQuickRevisionController.start` ne rafraîchit pas la progression, ce qui reste correct : démarrer une session ne modifie pas la mastery.
- `/progress` est routé vers `SubjectProgressPage`, pas vers une page pending.
- Les valeurs fake `Loi normale`, `78%`, `870`, `7 jours` ne ressortent que dans des assertions anti-fixtures `findsNothing`.

## 3. Sub-agents/passes utilisées

- Audit Agent : inspection read-only, confirmation des écarts upload/polling et des routes backend.
- Frontend State Agent : lancé en review read-only, non revenu avant le délai ; remplacé par review manuelle finale.
- QA Agent : validations locales exécutées par Codex.
- Reviewer Agent : review manuelle finale incluse en section 13.

## 4. Modifications backend

Non applicable dans ce repo. Les modifications backend sont documentées dans le rapport API.

## 5. Modifications frontend

- `UploadCourseDocumentController.upload` invalide maintenant aussi `courseProgressProvider` et `subjectProgressProvider` après succès.
- `DeleteCourseDocumentController.delete` invalide aussi `subjectProgressProvider`, par cohérence avec la suppression de source déjà ajoutée.
- Le polling pending dans `CourseDetailPage` invalide `courseDetailProvider`, `courseProgressProvider` et `subjectProgressProvider` au même rythme de 2 secondes.
- Pas de refresh après génération de fiche.
- Pas de refresh après démarrage de révision rapide.
- Aucun polling global ajouté.

## 6. Tests ajoutés

- Provider upload succès : vérifie le rechargement détail, liste, course progress et subject progress.
- Provider upload annulé : vérifie absence d'upload et absence de refresh progress.
- Provider upload échoué : vérifie état erreur et absence de refresh progress simulé.
- Widget source processing : vérifie polling détail + progression.
- Widget ready/failed/no source : vérifie absence de polling inutile.

## 7. Commandes exécutées

- `dart format lib/features/courses/application/courses_providers.dart lib/features/courses/presentation/course_detail_page.dart test/fakes/in_memory_courses_repository.dart test/features/courses/courses_providers_test.dart test/features/courses/course_detail_page_test.dart` : OK.
- `flutter test test/features/courses/courses_providers_test.dart --reporter compact` : d'abord rouge sur progress non invalidée, puis OK, 14 tests.
- `flutter test test/features/courses/course_detail_page_test.dart --reporter compact` : d'abord rouge sur polling progress, puis OK, 11 tests.
- `dart analyze lib test` : OK, no issues found.
- `flutter test test/features/courses --reporter compact` : OK, all tests passed.
- `flutter test test/features/revision_sessions --reporter compact` : OK, all tests passed.
- `flutter test test/app/router/app_router_test.dart --reporter compact` : OK, all tests passed.
- `flutter test test/app/revision_app_test.dart --reporter compact` : OK, all tests passed.
- `flutter test test/app --reporter compact` : OK, all tests passed.
- `flutter test --reporter compact` : OK, all tests passed.
- `git diff --check` : OK, relancé après génération du rapport final.

## 8. Preuve anti-fixtures

Commande : `rg -n "MvpStudyController\.instance|mvpSubjects|mvpSessionQuestions|courseOrFallback|Loi normale|78%|4/5 bonnes|870|7 jours" lib/app lib/features/courses lib/presentation/shell test/app test/features/courses || true`.

Résultat : aucune occurrence runtime dans `lib/app`, `lib/features/courses`, `lib/presentation/shell`. Les occurrences restantes sont des assertions `findsNothing` dans les tests anti-fixtures.

## 9. Preuve anti-CourseSource

Commande : `rg -n "CourseSource" lib/features/courses test/features/courses test/fakes test/app || true`.

Résultat : aucune occurrence.

## 10. Runbook créé

- `docs/core/MVP_CORE_ACCEPTANCE_RUNBOOK.md` : parcours utilisateur, vérifications UI, commandes, hors MVP Core, notes de cohérence.

## 11. Limites

- Le polling reste un polling local page détail, pas un canal temps réel.
- La progression n'est pas rafraîchie au démarrage quick, volontairement ; elle doit changer après submit d'activité.
- La génération de fiche ne déclenche pas de refresh progression, volontairement.

## 12. Risques restants

- Invalider `subjectProgressProvider` depuis un détail de cours peut être un peu large si beaucoup de cours existent, mais c'est acceptable pour le MVP et évite une progression stale visible.
- À terme, SSE/WebSocket rendra ce mécanisme plus propre.

## 13. Auto-review

- Upload PDF invalide bien `courseProgressProvider` : oui.
- Upload PDF invalide bien `subjectProgressProvider` : oui.
- Upload annulé ne déclenche pas d'upload ni refresh progress : oui.
- Upload échoué ne simule pas une source réelle : oui.
- Polling source pending invalide aussi la progression : oui.
- Polling reste borné : oui, 2 minutes via `_pollTimeout`.
- Pas de polling global : oui.
- Démarrage quick ne refresh pas la progression inutilement : oui.
- Génération fiche ne refresh pas la progression inutilement : oui.
- Aucun deep/exam : oui.
- Aucun résultat session final : oui.
- Aucun `CourseSource` : oui.
- Aucune fixture production : oui.
- Aucun commit n'a été réalisé pendant l'exécution initiale du lot 06B. Le rapport est désormais présent dans le commit `6f8cda1`, réalisé après autorisation explicite de commit.

## 14. Points discutables du prompt

- CORE-06B est petit mais utile : il cible un bug de confiance produit.
- Le polling devrait être remplacé plus tard par SSE/WebSocket, mais ce serait trop large ici.
- Invalider la progression matière depuis un détail est large, mais la donnée est directement impactée par les sources du cours.
- Le runbook dupliqué dans deux repos évite de forcer le lecteur backend ou frontend à changer de repo.
- Passer directement à PLUS-01 aurait ajouté du scope au-dessus d'un état potentiellement stale.

## 15. Fichiers créés/modifiés/supprimés

Créés :
- `docs/core/MVP_CORE_ACCEPTANCE_RUNBOOK.md`
- `docs/core/CORE_06B_PROGRESS_REFRESH_AND_ACCEPTANCE_HARDENING_REPORT.md`

Modifiés :
- `lib/features/courses/application/courses_providers.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `test/fakes/in_memory_courses_repository.dart`
- `test/features/courses/courses_providers_test.dart`
- `test/features/courses/course_detail_page_test.dart`

Supprimés : aucun.

## 16. Contenu complet des fichiers créés/modifiés/supprimés

Le rapport courant n'inclut pas son propre contenu pour éviter une récursion infinie.

### lib/features/courses/application/courses_providers.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../documents/domain/revision_document.dart';
import '../../revision_sessions/domain/revision_session.dart';
import '../data/http_courses_repository.dart';
import '../domain/course_models.dart';
import '../domain/courses_repository.dart';
import 'course_pdf_picker.dart';

final coursesRepositoryProvider = Provider<CoursesRepository>((ref) {
  final dio = ref.read(dioProvider);
  final auth = ref.read(authControllerProvider);
  return HttpCoursesRepository(dio: dio, getIdToken: auth.requireIdToken);
});

final coursesProvider = FutureProvider.family<List<CourseListItem>, String>((
  ref,
  subjectId,
) {
  return ref.read(coursesRepositoryProvider).listCourses(subjectId: subjectId);
});

final courseDetailProvider = FutureProvider.family<CourseDetail, String>((
  ref,
  courseId,
) {
  return ref.read(coursesRepositoryProvider).getCourse(courseId: courseId);
});

final courseProgressProvider = FutureProvider.family<CourseProgress, String>((
  ref,
  courseId,
) {
  return ref
      .read(coursesRepositoryProvider)
      .getCourseProgress(courseId: courseId);
});

final subjectProgressProvider = FutureProvider.family<SubjectProgress, String>((
  ref,
  subjectId,
) {
  return ref
      .read(coursesRepositoryProvider)
      .getSubjectProgress(subjectId: subjectId);
});

final courseRevisionSheetProvider =
    FutureProvider.family<RevisionSheet?, String>((ref, courseId) {
      return ref
          .read(coursesRepositoryProvider)
          .getCourseRevisionSheet(courseId: courseId);
    });

final createCourseControllerProvider =
    NotifierProvider<CreateCourseController, AsyncValue<void>>(
      CreateCourseController.new,
    );

final uploadCourseDocumentControllerProvider =
    NotifierProvider<
      UploadCourseDocumentController,
      AsyncValue<CourseDocument?>
    >(UploadCourseDocumentController.new);

final deleteCourseDocumentControllerProvider =
    NotifierProvider<DeleteCourseDocumentController, AsyncValue<void>>(
      DeleteCourseDocumentController.new,
    );

final generateCourseRevisionSheetControllerProvider =
    NotifierProvider<
      GenerateCourseRevisionSheetController,
      AsyncValue<RevisionSheet?>
    >(GenerateCourseRevisionSheetController.new);

final startCourseQuickRevisionControllerProvider =
    NotifierProvider<
      StartCourseQuickRevisionController,
      AsyncValue<RevisionSessionResponse?>
    >(StartCourseQuickRevisionController.new);

class CreateCourseController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<CourseListItem> create({
    required String subjectId,
    required CreateCourseInput input,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.createCourse(subjectId: subjectId, input: input),
    );
    state = result.whenData((_) {});

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    final course = result.requireValue;
    ref.invalidate(coursesProvider(subjectId));
    ref.invalidate(courseDetailProvider(course.id));

    return course;
  }
}

class UploadCourseDocumentController
    extends Notifier<AsyncValue<CourseDocument?>> {
  @override
  AsyncValue<CourseDocument?> build() => const AsyncData(null);

  Future<CourseDocument?> upload({required CourseDetail detail}) async {
    final picked = await ref.read(coursePdfPickerProvider).pickPdf();

    if (picked == null) {
      state = const AsyncData(null);
      return null;
    }

    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.uploadCoursePdf(
        courseId: detail.course.id,
        fileName: picked.fileName,
        bytes: picked.bytes,
      ),
    );

    state = result.whenData<CourseDocument?>((document) => document);

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    final uploaded = result.requireValue;
    ref.invalidate(courseDetailProvider(detail.course.id));
    ref.invalidate(courseProgressProvider(detail.course.id));
    ref.invalidate(coursesProvider(detail.course.subjectId));
    ref.invalidate(subjectProgressProvider(detail.course.subjectId));

    return uploaded;
  }
}

class DeleteCourseDocumentController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> delete({
    required CourseDetail detail,
    required String documentId,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.deleteCourseDocument(
        courseId: detail.course.id,
        documentId: documentId,
      ),
    );

    state = result;

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    ref.invalidate(courseDetailProvider(detail.course.id));
    ref.invalidate(courseProgressProvider(detail.course.id));
    ref.invalidate(coursesProvider(detail.course.subjectId));
    ref.invalidate(subjectProgressProvider(detail.course.subjectId));
  }
}

class GenerateCourseRevisionSheetController
    extends Notifier<AsyncValue<RevisionSheet?>> {
  @override
  AsyncValue<RevisionSheet?> build() => const AsyncData(null);

  Future<RevisionSheet> generate({required String courseId}) async {
    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.generateCourseRevisionSheet(courseId: courseId),
    );

    state = result.whenData<RevisionSheet?>((sheet) => sheet);

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    final sheet = result.requireValue;
    ref.invalidate(courseRevisionSheetProvider(courseId));

    return sheet;
  }
}

class StartCourseQuickRevisionController
    extends Notifier<AsyncValue<RevisionSessionResponse?>> {
  @override
  AsyncValue<RevisionSessionResponse?> build() => const AsyncData(null);

  Future<RevisionSessionResponse> start({required CourseDetail detail}) async {
    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.startCourseQuickRevision(courseId: detail.course.id),
    );

    state = result.whenData<RevisionSessionResponse?>((response) => response);

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    return result.requireValue;
  }
}

```
### lib/features/courses/presentation/course_detail_page.dart

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/courses_providers.dart';
import '../domain/course_models.dart';
import '../domain/courses_repository.dart';
import 'course_not_found_page.dart';

class CourseDetailPage extends ConsumerWidget {
  const CourseDetailPage({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(courseDetailProvider(courseId));

    return detail.when(
      loading: () => const RevisionPageScaffold(
        children: [RevisionLoadingState(label: 'Chargement du cours réel')],
      ),
      error: (error, stackTrace) {
        if (error is CourseNotFoundException) {
          return CourseNotFoundPage(courseId: courseId);
        }

        return RevisionPageScaffold(
          children: [
            Text('Cours indisponible', style: RevisionTypography.pageTitle),
            RevisionErrorState(
              title: 'Impossible de charger ce cours',
              message:
                  'Aucune fixture ne remplacera ce cours. Réessaie ou retourne à l’accueil.',
              actionLabel: 'Retour à l’accueil',
              onAction: () => context.go(AppRoutes.home),
            ),
          ],
        );
      },
      data: (detail) => _CourseDetailContent(detail: detail),
    );
  }
}

class _CourseDetailContent extends ConsumerStatefulWidget {
  const _CourseDetailContent({required this.detail});

  final CourseDetail detail;

  @override
  ConsumerState<_CourseDetailContent> createState() =>
      _CourseDetailContentState();
}

class _CourseDetailContentState extends ConsumerState<_CourseDetailContent> {
  static const _pollInterval = Duration(seconds: 2);
  static const _pollTimeout = Duration(minutes: 2);

  Timer? _pollTimer;
  DateTime? _pollStartedAt;
  bool _pollTimedOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPolling());
  }

  @override
  void didUpdateWidget(covariant _CourseDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPolling();
  }

  @override
  void dispose() {
    _stopPolling(resetTimeout: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final course = detail.course;
    final progress = ref.watch(courseProgressProvider(course.id));

    return RevisionPageScaffold(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Retour',
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const Spacer(),
          ],
        ),
        RevisionGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(detail.subject.name, style: RevisionTypography.caption),
              const SizedBox(height: RevisionSpacing.xs),
              Text(course.title, style: RevisionTypography.pageTitle),
              if (course.description != null) ...[
                const SizedBox(height: RevisionSpacing.s),
                Text(course.description!, style: RevisionTypography.body),
              ],
              const SizedBox(height: RevisionSpacing.l),
              Wrap(
                spacing: RevisionSpacing.s,
                runSpacing: RevisionSpacing.s,
                children: [
                  _InfoPill(label: _courseMeta(course)),
                  _InfoPill(label: _sourceMeta(course)),
                ],
              ),
            ],
          ),
        ),
        _CourseProgressSection(
          progress: progress,
          onRetry: () => ref.invalidate(courseProgressProvider(course.id)),
        ),
        _CourseActions(detail: detail),
        if (_pollTimedOut)
          RevisionGlassCard(
            child: Text(
              'Le traitement continue en arrière-plan. Tu peux revenir plus tard.',
              style: RevisionTypography.body,
            ),
          ),
        _SourcesSection(
          detail: detail,
          onRefresh: () => ref.invalidate(courseDetailProvider(course.id)),
        ),
      ],
    );
  }

  void _syncPolling() {
    if (!mounted) {
      return;
    }

    final hasPendingSource = widget.detail.sources.any(_isPendingSource);

    if (!hasPendingSource) {
      _stopPolling(resetTimeout: true);
      return;
    }

    _pollStartedAt ??= DateTime.now();
    _pollTimer ??= Timer.periodic(_pollInterval, (_) {
      final startedAt = _pollStartedAt;
      if (startedAt != null &&
          DateTime.now().difference(startedAt) >= _pollTimeout) {
        if (mounted) {
          setState(() => _pollTimedOut = true);
        }
        _stopPolling(resetTimeout: false);
        return;
      }

      ref.invalidate(courseDetailProvider(widget.detail.course.id));
      ref.invalidate(courseProgressProvider(widget.detail.course.id));
      ref.invalidate(subjectProgressProvider(widget.detail.course.subjectId));
    });
  }

  void _stopPolling({required bool resetTimeout}) {
    _pollTimer?.cancel();
    _pollTimer = null;
    _pollStartedAt = null;
    if (resetTimeout && _pollTimedOut && mounted) {
      setState(() => _pollTimedOut = false);
    }
  }
}

class _CourseProgressSection extends StatelessWidget {
  const _CourseProgressSection({required this.progress, required this.onRetry});

  final AsyncValue<CourseProgress> progress;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return progress.when(
      loading: () =>
          const RevisionLoadingState(label: 'Chargement de la progression'),
      error: (error, stackTrace) => RevisionErrorState(
        title: 'Progression indisponible',
        message: 'Les métriques réelles ne sont pas disponibles pour ce cours.',
        actionLabel: 'Réessayer',
        onAction: onRetry,
      ),
      data: (progress) => RevisionGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progression réelle', style: RevisionTypography.sectionTitle),
            const SizedBox(height: RevisionSpacing.m),
            Row(
              children: [
                RevisionMasteryRing(
                  value: progress.estimatedGlobalMastery,
                  label: _percent(progress.estimatedGlobalMastery),
                  caption: 'global',
                  color: _progressColor(progress.state),
                ),
                const SizedBox(width: RevisionSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${progress.practicedKnowledgeUnitCount}/${progress.knowledgeUnitCount} notions travaillées',
                        style: RevisionTypography.body,
                      ),
                      const SizedBox(height: RevisionSpacing.s),
                      RevisionProgressLine(
                        value: progress.coverage,
                        color: _progressColor(progress.state),
                        height: 7,
                      ),
                      const SizedBox(height: RevisionSpacing.s),
                      Text(
                        _masteryLabel(progress),
                        style: RevisionTypography.caption,
                      ),
                      const SizedBox(height: RevisionSpacing.xs),
                      Text(
                        'Estimation globale : ${_percent(progress.estimatedGlobalMastery)}',
                        style: RevisionTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: RevisionSpacing.m),
            Text(
              _progressStateLabel(progress.state),
              style: RevisionTypography.body,
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseActions extends ConsumerWidget {
  const _CourseActions({required this.detail});

  final CourseDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadCourseDocumentControllerProvider);
    final quickRevisionState = ref.watch(
      startCourseQuickRevisionControllerProvider,
    );
    final isUploading = uploadState.isLoading;
    final isStartingQuickRevision = quickRevisionState.isLoading;
    final hasReadySource = detail.sources.any(
      (source) => source.status == CourseDocumentStatus.ready,
    );

    return RevisionGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Actions', style: RevisionTypography.sectionTitle),
          const SizedBox(height: RevisionSpacing.m),
          RevisionGradientButton(
            label: isUploading ? 'Upload en cours...' : 'Ajouter une source',
            icon: Icons.upload_file_rounded,
            expanded: true,
            onPressed: isUploading
                ? null
                : () async {
                    try {
                      final uploaded = await ref
                          .read(uploadCourseDocumentControllerProvider.notifier)
                          .upload(detail: detail);

                      if (!context.mounted || uploaded == null) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Source ajoutée')),
                      );
                    } catch (_) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Impossible d’ajouter cette source PDF.',
                          ),
                        ),
                      );
                    }
                  },
          ),
          if (uploadState.hasError) ...[
            const SizedBox(height: RevisionSpacing.s),
            Text(
              'Upload impossible pour le moment.',
              style: RevisionTypography.caption.copyWith(
                color: RevisionColors.red,
              ),
            ),
          ],
          const SizedBox(height: RevisionSpacing.m),
          RevisionGradientButton(
            label: _sheetActionLabel(detail.sources),
            icon: Icons.article_outlined,
            expanded: true,
            onPressed: hasReadySource
                ? () => context.go(AppRoutes.courseSheet(detail.course.id))
                : null,
          ),
          const SizedBox(height: RevisionSpacing.m),
          RevisionGradientButton(
            label: isStartingQuickRevision
                ? 'Démarrage...'
                : _quickRevisionActionLabel(detail.sources),
            icon: Icons.flash_on_rounded,
            expanded: true,
            onPressed: hasReadySource && !isStartingQuickRevision
                ? () async {
                    try {
                      final response = await ref
                          .read(
                            startCourseQuickRevisionControllerProvider.notifier,
                          )
                          .start(detail: detail);

                      if (!context.mounted) {
                        return;
                      }

                      context.go(
                        AppRoutes.revisionSession(
                          sessionId: response.session.id,
                        ),
                      );
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_quickRevisionErrorLabel(error)),
                        ),
                      );
                    }
                  }
                : null,
          ),
          if (quickRevisionState.hasError) ...[
            const SizedBox(height: RevisionSpacing.s),
            Text(
              'Révision rapide indisponible pour ce cours.',
              style: RevisionTypography.caption.copyWith(
                color: RevisionColors.red,
              ),
            ),
          ],
          const SizedBox(height: RevisionSpacing.s),
          Text(
            'Révision approfondie et préparation examen restent MVP+.',
            style: RevisionTypography.caption,
          ),
        ],
      ),
    );
  }
}

String _sheetActionLabel(List<CourseDocument> sources) {
  if (sources.any((source) => source.status == CourseDocumentStatus.ready)) {
    return 'Fiche de cours';
  }

  if (sources.any(_isPendingSource)) {
    return 'Fiche disponible après traitement';
  }

  if (sources.isNotEmpty &&
      sources.every((source) => source.status == CourseDocumentStatus.failed)) {
    return 'Aucune source prête';
  }

  return 'Ajoute une source pour créer une fiche';
}

String _quickRevisionActionLabel(List<CourseDocument> sources) {
  if (sources.any((source) => source.status == CourseDocumentStatus.ready)) {
    return 'Révision rapide';
  }

  if (sources.any(_isPendingSource)) {
    return 'Révision disponible après traitement';
  }

  if (sources.isNotEmpty &&
      sources.every((source) => source.status == CourseDocumentStatus.failed)) {
    return 'Aucune source prête';
  }

  return 'Ajoute une source pour réviser';
}

String _quickRevisionErrorLabel(Object error) {
  if (error is CourseQuickRevisionUnavailableException) {
    return error.message;
  }

  if (error is CourseNotFoundException) {
    return 'Cours introuvable.';
  }

  return 'Impossible de démarrer la révision rapide.';
}

String _masteryLabel(CourseProgress progress) {
  if (progress.mastery == null) {
    return 'Maîtrise sur notions travaillées : en attente';
  }

  return 'Maîtrise sur notions travaillées : ${_percent(progress.mastery!)}';
}

String _progressStateLabel(CourseProgressState state) {
  return switch (state) {
    CourseProgressState.noSource => 'Ajoute une source pour commencer.',
    CourseProgressState.processing => 'Analyse du PDF en cours.',
    CourseProgressState.failedOnly =>
      'Les sources ont échoué. Ajoute ou corrige une source.',
    CourseProgressState.noKnowledgeUnits =>
      'Source prête, mais aucune notion exploitable.',
    CourseProgressState.readyNotPracticed =>
      'Notions prêtes, pas encore travaillées.',
    CourseProgressState.practiced =>
      'Progression réelle basée sur tes réponses.',
    CourseProgressState.unknown => 'Progression réelle disponible.',
  };
}

Color _progressColor(CourseProgressState state) {
  return switch (state) {
    CourseProgressState.practiced => RevisionColors.green,
    CourseProgressState.readyNotPracticed => RevisionColors.blue,
    CourseProgressState.processing => RevisionColors.amber,
    CourseProgressState.failedOnly => RevisionColors.red,
    CourseProgressState.noKnowledgeUnits => RevisionColors.violet,
    CourseProgressState.noSource => RevisionColors.blue,
    CourseProgressState.unknown => RevisionColors.mint,
  };
}

String _percent(double value) {
  return '${(value.clamp(0, 1) * 100).round()}%';
}

class _SourcesSection extends ConsumerWidget {
  const _SourcesSection({required this.detail, required this.onRefresh});

  final CourseDetail detail;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = detail.sources;
    final deleteState = ref.watch(deleteCourseDocumentControllerProvider);
    final isDeleting = deleteState.isLoading;

    if (sources.isEmpty) {
      return const RevisionEmptyState(
        title: 'Aucune source attachée',
        message:
            'Ajoute un PDF réel pour lancer le traitement documentaire de ce cours.',
        icon: Icons.source_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sources', style: RevisionTypography.sectionTitle),
        const SizedBox(height: RevisionSpacing.m),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Rafraîchir'),
          ),
        ),
        const SizedBox(height: RevisionSpacing.s),
        for (final source in sources) ...[
          RevisionGlassCard(
            child: Row(
              children: [
                RevisionIconTile(
                  icon: Icons.picture_as_pdf_rounded,
                  accent: _statusColor(source.status),
                ),
                const SizedBox(width: RevisionSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(source.fileName, style: RevisionTypography.body),
                      const SizedBox(height: RevisionSpacing.xs),
                      Text(
                        _statusLabel(source.status),
                        style: RevisionTypography.caption,
                      ),
                      if (source.status == CourseDocumentStatus.failed &&
                          source.errorCode != null) ...[
                        const SizedBox(height: RevisionSpacing.xs),
                        Text(
                          'Code erreur : ${source.errorCode}',
                          style: RevisionTypography.caption.copyWith(
                            color: RevisionColors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Supprimer la source ${source.fileName}',
                  onPressed: isDeleting
                      ? null
                      : () async {
                          final confirmed = await _confirmDeleteSource(
                            context,
                            source.fileName,
                          );
                          if (!confirmed || !context.mounted) {
                            return;
                          }

                          try {
                            await ref
                                .read(
                                  deleteCourseDocumentControllerProvider
                                      .notifier,
                                )
                                .delete(
                                  detail: detail,
                                  documentId: source.documentId,
                                );

                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Source supprimée')),
                            );
                          } catch (_) {
                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Impossible de supprimer cette source.',
                                ),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: RevisionSpacing.m),
        ],
      ],
    );
  }
}

Future<bool> _confirmDeleteSource(BuildContext context, String fileName) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Supprimer cette source ?'),
      content: Text(
        'Le PDF "$fileName" sera retiré de ce cours. Tu pourras le rajouter plus tard si besoin.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}

bool _isPendingSource(CourseDocument source) {
  return source.status == CourseDocumentStatus.uploaded ||
      source.status == CourseDocumentStatus.processing;
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RevisionColors.glassSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: RevisionColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RevisionSpacing.m,
          vertical: RevisionSpacing.s,
        ),
        child: Text(label, style: RevisionTypography.caption),
      ),
    );
  }
}

String _courseMeta(CourseListItem course) {
  final parts = <String>[
    if (course.chapterLabel != null) course.chapterLabel!,
    if (course.estimatedMinutes != null) '${course.estimatedMinutes} min',
  ];

  return parts.isEmpty ? 'Cours réel' : parts.join(' · ');
}

String _sourceMeta(CourseListItem course) {
  final sourceLabel = course.sourceCount <= 1 ? 'source' : 'sources';
  final readyLabel = course.readySourceCount <= 1 ? 'prête' : 'prêtes';

  return '${course.sourceCount} $sourceLabel · ${course.readySourceCount} $readyLabel';
}

String _statusLabel(CourseDocumentStatus status) {
  return switch (status) {
    CourseDocumentStatus.uploaded => 'Téléversée',
    CourseDocumentStatus.processing => 'Traitement en cours',
    CourseDocumentStatus.ready => 'Prête',
    CourseDocumentStatus.failed => 'Erreur',
    CourseDocumentStatus.unknown => 'Statut inconnu',
  };
}

Color _statusColor(CourseDocumentStatus status) {
  return switch (status) {
    CourseDocumentStatus.ready => RevisionColors.mint,
    CourseDocumentStatus.processing => RevisionColors.blue,
    CourseDocumentStatus.failed => RevisionColors.red,
    CourseDocumentStatus.uploaded => RevisionColors.amber,
    CourseDocumentStatus.unknown => RevisionColors.violet,
  };
}

```
### test/fakes/in_memory_courses_repository.dart

```dart
import 'dart:typed_data';

import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/courses/domain/courses_repository.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';
import 'package:revision_app/features/revision_sessions/domain/revision_session.dart';

class InMemoryCoursesRepository implements CoursesRepository {
  final Map<String, List<CourseListItem>> coursesBySubject = {};
  final Map<String, CourseDetail> detailsByCourse = {};
  final Map<String, CourseProgress> progressByCourse = {};
  final Map<String, SubjectProgress> progressBySubject = {};
  final Map<String, RevisionSheet?> revisionSheetsByCourse = {};
  final Map<String, RevisionSheet> generatedRevisionSheetsByCourse = {};
  final Map<String, Object> revisionSheetErrorsByCourse = {};
  int createCount = 0;
  int listCoursesCount = 0;
  int getCourseCount = 0;
  int getCourseProgressCount = 0;
  int getSubjectProgressCount = 0;
  int getRevisionSheetCount = 0;
  int generateRevisionSheetCount = 0;
  int uploadCount = 0;
  int deleteDocumentCount = 0;
  int startQuickRevisionCount = 0;
  String? lastUploadedCourseId;
  String? lastUploadedFileName;
  Uint8List? lastUploadedBytes;
  String? lastDeletedCourseId;
  String? lastDeletedDocumentId;
  String? lastQuickRevisionCourseId;
  Object? uploadError;
  Object? deleteDocumentError;
  Object? quickRevisionError;
  RevisionSessionResponse? quickRevisionResponse;
  Duration uploadDelay = Duration.zero;
  Duration quickRevisionDelay = Duration.zero;

  @override
  Future<List<CourseListItem>> listCourses({required String subjectId}) async {
    listCoursesCount += 1;
    return List.unmodifiable(coursesBySubject[subjectId] ?? const []);
  }

  @override
  Future<CourseDetail> getCourse({required String courseId}) async {
    getCourseCount += 1;
    final detail = detailsByCourse[courseId];

    if (detail == null) {
      throw const CourseNotFoundException('Course not found');
    }

    return detail;
  }

  @override
  Future<CourseListItem> createCourse({
    required String subjectId,
    required CreateCourseInput input,
  }) async {
    createCount += 1;
    final course = CourseListItem(
      id: 'course-$createCount',
      subjectId: subjectId,
      title: input.title,
      description: input.description,
      chapterLabel: input.chapterLabel,
      estimatedMinutes: input.estimatedMinutes,
      sourceCount: 0,
      readySourceCount: 0,
      processingSourceCount: 0,
      failedSourceCount: 0,
    );
    coursesBySubject.putIfAbsent(subjectId, () => []).add(course);
    detailsByCourse[course.id] = CourseDetail(
      course: course,
      subject: CourseSubjectSummary(id: subjectId, name: 'Matière réelle'),
      sources: const [],
    );

    return course;
  }

  @override
  Future<CourseDocument> uploadCoursePdf({
    required String courseId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (uploadDelay > Duration.zero) {
      await Future<void>.delayed(uploadDelay);
    }

    final error = uploadError;
    if (error != null) {
      throw error;
    }

    final detail = detailsByCourse[courseId];
    if (detail == null) {
      throw const CourseNotFoundException('Course not found');
    }

    uploadCount += 1;
    lastUploadedCourseId = courseId;
    lastUploadedFileName = fileName;
    lastUploadedBytes = bytes;

    final document = CourseDocument(
      id: 'document-$uploadCount',
      courseId: courseId,
      documentId: 'document-$uploadCount',
      fileName: fileName,
      status: CourseDocumentStatus.uploaded,
      createdAt: DateTime.utc(2026, 6, 18, 12),
      updatedAt: DateTime.utc(2026, 6, 18, 12),
    );
    detailsByCourse[courseId] = CourseDetail(
      course: detail.course,
      subject: detail.subject,
      sources: [...detail.sources, document],
      progress: detail.progress,
    );

    return document;
  }

  @override
  Future<void> deleteCourseDocument({
    required String courseId,
    required String documentId,
  }) async {
    final error = deleteDocumentError;
    if (error != null) {
      throw error;
    }

    final detail = detailsByCourse[courseId];
    if (detail == null) {
      throw const CourseNotFoundException('Course not found');
    }

    final remainingSources = detail.sources
        .where((source) => source.documentId != documentId)
        .toList(growable: false);
    if (remainingSources.length == detail.sources.length) {
      throw const CourseNotFoundException('Course source not found');
    }

    deleteDocumentCount += 1;
    lastDeletedCourseId = courseId;
    lastDeletedDocumentId = documentId;
    detailsByCourse[courseId] = CourseDetail(
      course: detail.course,
      subject: detail.subject,
      sources: remainingSources,
      progress: detail.progress,
    );
  }

  @override
  Future<RevisionSheet?> getCourseRevisionSheet({
    required String courseId,
  }) async {
    getRevisionSheetCount += 1;
    final error = revisionSheetErrorsByCourse[courseId];
    if (error != null) {
      throw error;
    }

    return revisionSheetsByCourse[courseId];
  }

  @override
  Future<RevisionSheet> generateCourseRevisionSheet({
    required String courseId,
  }) async {
    generateRevisionSheetCount += 1;
    final error = revisionSheetErrorsByCourse[courseId];
    if (error != null) {
      throw error;
    }

    final existing = revisionSheetsByCourse[courseId];
    if (existing != null) {
      return existing;
    }

    final generated = generatedRevisionSheetsByCourse[courseId];
    if (generated != null) {
      revisionSheetsByCourse[courseId] = generated;
      return generated;
    }

    throw const CourseRevisionSheetNotReadyException(
      'Course has no ready source',
    );
  }

  @override
  Future<RevisionSessionResponse> startCourseQuickRevision({
    required String courseId,
  }) async {
    if (quickRevisionDelay > Duration.zero) {
      await Future<void>.delayed(quickRevisionDelay);
    }

    final error = quickRevisionError;
    if (error != null) {
      throw error;
    }

    if (!detailsByCourse.containsKey(courseId)) {
      throw const CourseNotFoundException('Course not found');
    }

    startQuickRevisionCount += 1;
    lastQuickRevisionCourseId = courseId;

    return quickRevisionResponse ?? quickRevisionSessionResponse(courseId);
  }

  @override
  Future<CourseProgress> getCourseProgress({required String courseId}) {
    getCourseProgressCount += 1;
    final progress = progressByCourse[courseId];

    if (progress == null) {
      throw const CourseNotFoundException('Course not found');
    }

    return Future.value(progress);
  }

  @override
  Future<SubjectProgress> getSubjectProgress({required String subjectId}) {
    getSubjectProgressCount += 1;
    final progress = progressBySubject[subjectId];

    if (progress == null) {
      throw const CourseNotFoundException('Course subject not found');
    }

    return Future.value(progress);
  }
}

RevisionSessionResponse quickRevisionSessionResponse(String courseId) {
  return RevisionSessionResponse(
    session: RevisionSession(
      id: 'revision-session-1',
      status: RevisionSessionStatus.started,
      subjectId: 'subject-1',
      courseId: courseId,
      documentId: 'document-1',
      knowledgeUnitId: 'knowledge-unit-1',
      createdAt: DateTime.utc(2026, 6, 18, 12),
      completedAt: null,
    ),
    currentAction: const RevisionSessionAction(
      id: 'action-1',
      kind: RevisionSessionActionKind.diagnosticQuiz,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'activity-session-1',
      documentId: 'document-1',
      knowledgeUnitId: 'knowledge-unit-1',
      payload: null,
    ),
    history: const [],
  );
}

```
### test/features/courses/courses_providers_test.dart

```dart
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/courses/application/course_pdf_picker.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/courses/domain/courses_repository.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';

import '../../fakes/in_memory_courses_repository.dart';

void main() {
  test('coursesProvider loads real courses for a subject', () async {
    final repository = InMemoryCoursesRepository()
      ..coursesBySubject['subject-1'] = const [
        CourseListItem(
          id: 'course-1',
          subjectId: 'subject-1',
          title: 'Droit constitutionnel',
          sourceCount: 0,
          readySourceCount: 0,
          processingSourceCount: 0,
          failedSourceCount: 0,
        ),
      ];
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final courses = await container.read(coursesProvider('subject-1').future);

    expect(courses.single.title, 'Droit constitutionnel');
  });

  test('createCourseController invalidates the subject course list', () async {
    final repository = InMemoryCoursesRepository();
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    expect(await container.read(coursesProvider('subject-1').future), isEmpty);

    final created = await container
        .read(createCourseControllerProvider.notifier)
        .create(
          subjectId: 'subject-1',
          input: const CreateCourseInput(title: 'Droit constitutionnel'),
        );

    expect(created.title, 'Droit constitutionnel');
    expect(
      await container.read(coursesProvider('subject-1').future),
      hasLength(1),
    );
  });

  test('course detail repository exposes typed not-found errors', () async {
    final repository = InMemoryCoursesRepository();

    await expectLater(
      repository.getCourse(courseId: 'unknown'),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test(
    'uploadCourseDocumentController does nothing when picking is cancelled',
    () async {
      final repository = InMemoryCoursesRepository()
        ..progressByCourse['course-1'] = courseProgress()
        ..progressBySubject['subject-1'] = subjectProgress();
      final picker = FakeCoursePdfPicker(null);
      final container = ProviderContainer(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(repository),
          coursePdfPickerProvider.overrideWithValue(picker),
        ],
      );
      addTearDown(container.dispose);

      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);
      final initialCourseProgressReads = repository.getCourseProgressCount;
      final initialSubjectProgressReads = repository.getSubjectProgressCount;

      final result = await container
          .read(uploadCourseDocumentControllerProvider.notifier)
          .upload(detail: courseDetail());

      expect(result, isNull);
      expect(picker.pickCount, 1);
      expect(repository.uploadCount, 0);
      expect(
        container.read(uploadCourseDocumentControllerProvider).hasError,
        false,
      );
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);
      expect(repository.getCourseProgressCount, initialCourseProgressReads);
      expect(repository.getSubjectProgressCount, initialSubjectProgressReads);
    },
  );

  test(
    'uploadCourseDocumentController uploads and invalidates detail lists and progress',
    () async {
      final repository = InMemoryCoursesRepository()
        ..coursesBySubject['subject-1'] = const [
          CourseListItem(
            id: 'course-1',
            subjectId: 'subject-1',
            title: 'Droit constitutionnel',
          ),
        ]
        ..detailsByCourse['course-1'] = courseDetail()
        ..progressByCourse['course-1'] = courseProgress()
        ..progressBySubject['subject-1'] = subjectProgress();
      final picker = FakeCoursePdfPicker(
        PickedCoursePdf(
          fileName: 'cours.pdf',
          bytes: Uint8List.fromList('%PDF-1.7'.codeUnits),
        ),
      );
      final container = ProviderContainer(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(repository),
          coursePdfPickerProvider.overrideWithValue(picker),
        ],
      );
      addTearDown(container.dispose);

      expect(
        (await container.read(courseDetailProvider('course-1').future)).sources,
        isEmpty,
      );
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      final initialDetailReads = repository.getCourseCount;
      final initialListReads = repository.listCoursesCount;
      final initialCourseProgressReads = repository.getCourseProgressCount;
      final initialSubjectProgressReads = repository.getSubjectProgressCount;

      final uploaded = await container
          .read(uploadCourseDocumentControllerProvider.notifier)
          .upload(detail: courseDetail());

      expect(uploaded?.fileName, 'cours.pdf');
      expect(repository.uploadCount, 1);
      expect(repository.lastUploadedCourseId, 'course-1');
      expect(
        (await container.read(courseDetailProvider('course-1').future)).sources,
        hasLength(1),
      );
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      expect(repository.getCourseCount, greaterThan(initialDetailReads));
      expect(repository.listCoursesCount, greaterThan(initialListReads));
      expect(
        repository.getCourseProgressCount,
        greaterThan(initialCourseProgressReads),
      );
      expect(
        repository.getSubjectProgressCount,
        greaterThan(initialSubjectProgressReads),
      );
    },
  );

  test('uploadCourseDocumentController exposes upload errors', () async {
    final repository = InMemoryCoursesRepository()
      ..progressByCourse['course-1'] = courseProgress()
      ..progressBySubject['subject-1'] = subjectProgress()
      ..uploadError = const CourseUploadException('Invalid PDF');
    final picker = FakeCoursePdfPicker(
      PickedCoursePdf(fileName: 'cours.pdf', bytes: Uint8List.fromList([1])),
    );
    final container = ProviderContainer(
      overrides: [
        coursesRepositoryProvider.overrideWithValue(repository),
        coursePdfPickerProvider.overrideWithValue(picker),
      ],
    );
    addTearDown(container.dispose);

    await container.read(courseProgressProvider('course-1').future);
    await container.read(subjectProgressProvider('subject-1').future);
    final initialCourseProgressReads = repository.getCourseProgressCount;
    final initialSubjectProgressReads = repository.getSubjectProgressCount;

    await expectLater(
      container
          .read(uploadCourseDocumentControllerProvider.notifier)
          .upload(detail: courseDetail()),
      throwsA(isA<CourseUploadException>()),
    );

    expect(
      container.read(uploadCourseDocumentControllerProvider).hasError,
      true,
    );
    await container.read(courseProgressProvider('course-1').future);
    await container.read(subjectProgressProvider('subject-1').future);
    expect(repository.getCourseProgressCount, initialCourseProgressReads);
    expect(repository.getSubjectProgressCount, initialSubjectProgressReads);
  });

  test(
    'deleteCourseDocumentController removes a source and refreshes detail',
    () async {
      final repository = InMemoryCoursesRepository()
        ..detailsByCourse['course-1'] = courseDetail(
          sources: const [
            CourseDocument(
              id: 'document-1',
              courseId: 'course-1',
              documentId: 'document-1',
              fileName: 'cours.pdf',
              status: CourseDocumentStatus.ready,
            ),
          ],
        )
        ..progressByCourse['course-1'] = courseProgress();
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      expect(
        (await container.read(courseDetailProvider('course-1').future)).sources,
        hasLength(1),
      );

      await container
          .read(deleteCourseDocumentControllerProvider.notifier)
          .delete(
            detail: repository.detailsByCourse['course-1']!,
            documentId: 'document-1',
          );

      expect(repository.deleteDocumentCount, 1);
      expect(repository.lastDeletedCourseId, 'course-1');
      expect(repository.lastDeletedDocumentId, 'document-1');
      expect(
        (await container.read(courseDetailProvider('course-1').future)).sources,
        isEmpty,
      );
    },
  );

  test(
    'courseRevisionSheetProvider loads an existing course-level sheet',
    () async {
      final repository = InMemoryCoursesRepository()
        ..revisionSheetsByCourse['course-1'] = revisionSheet();
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final sheet = await container.read(
        courseRevisionSheetProvider('course-1').future,
      );

      expect(sheet?.title, 'Fiche de cours');
      expect(repository.getRevisionSheetCount, 1);
    },
  );

  test('courseProgressProvider loads real course progress', () async {
    final repository = InMemoryCoursesRepository()
      ..progressByCourse['course-1'] = courseProgress();
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final progress = await container.read(
      courseProgressProvider('course-1').future,
    );

    expect(progress.state, CourseProgressState.practiced);
    expect(progress.estimatedGlobalMastery, 0.18);
    expect(repository.getCourseProgressCount, 1);
  });

  test('subjectProgressProvider loads real subject progress', () async {
    final repository = InMemoryCoursesRepository()
      ..progressBySubject['subject-1'] = subjectProgress();
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final progress = await container.read(
      subjectProgressProvider('subject-1').future,
    );

    expect(progress.courses.single.title, 'Droit constitutionnel');
    expect(progress.readyCourseCount, 1);
    expect(repository.getSubjectProgressCount, 1);
  });

  test(
    'generateCourseRevisionSheetController generates and invalidates',
    () async {
      final repository = InMemoryCoursesRepository()
        ..revisionSheetsByCourse['course-1'] = revisionSheet();
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(courseRevisionSheetProvider('course-1').future);

      final sheet = await container
          .read(generateCourseRevisionSheetControllerProvider.notifier)
          .generate(courseId: 'course-1');

      expect(sheet.title, 'Fiche de cours');
      expect(repository.generateRevisionSheetCount, 1);
      expect(
        await container.read(courseRevisionSheetProvider('course-1').future),
        isNotNull,
      );
    },
  );

  test(
    'generateCourseRevisionSheetController exposes not-ready errors',
    () async {
      final repository = InMemoryCoursesRepository()
        ..revisionSheetErrorsByCourse['course-1'] =
            const CourseRevisionSheetNotReadyException(
              'Course has no ready source',
            );
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await expectLater(
        container
            .read(generateCourseRevisionSheetControllerProvider.notifier)
            .generate(courseId: 'course-1'),
        throwsA(isA<CourseRevisionSheetNotReadyException>()),
      );

      expect(
        container.read(generateCourseRevisionSheetControllerProvider).hasError,
        true,
      );
    },
  );

  test(
    'startCourseQuickRevisionController starts a real course session',
    () async {
      final repository = InMemoryCoursesRepository()
        ..detailsByCourse['course-1'] = courseDetail();
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final response = await container
          .read(startCourseQuickRevisionControllerProvider.notifier)
          .start(detail: courseDetail());

      expect(response.session.id, 'revision-session-1');
      expect(response.session.courseId, 'course-1');
      expect(repository.startQuickRevisionCount, 1);
      expect(repository.lastQuickRevisionCourseId, 'course-1');
      expect(
        container.read(startCourseQuickRevisionControllerProvider).hasError,
        false,
      );
    },
  );

  test('startCourseQuickRevisionController exposes readiness errors', () async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..quickRevisionError = const CourseQuickRevisionUnavailableException(
        'Course has no ready knowledge unit',
      );
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await expectLater(
      container
          .read(startCourseQuickRevisionControllerProvider.notifier)
          .start(detail: courseDetail()),
      throwsA(isA<CourseQuickRevisionUnavailableException>()),
    );

    expect(
      container.read(startCourseQuickRevisionControllerProvider).hasError,
      true,
    );
  });
}

CourseDetail courseDetail({List<CourseDocument> sources = const []}) {
  const course = CourseListItem(
    id: 'course-1',
    subjectId: 'subject-1',
    title: 'Droit constitutionnel',
  );
  return CourseDetail(
    course: course,
    subject: const CourseSubjectSummary(id: 'subject-1', name: 'Droit'),
    sources: sources,
  );
}

RevisionSheet revisionSheet() {
  return const RevisionSheet(
    id: 'sheet-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Fiche de cours',
    introduction: 'Introduction',
    sections: [
      RevisionSheetSection(
        id: 'section-1',
        displayOrder: 0,
        title: 'Institutions',
        content: 'Le Parlement contrôle le Gouvernement.',
        sources: [],
      ),
    ],
    keyPoints: ['Point clé'],
    commonMistakes: ['Erreur fréquente'],
    mustKnow: ['À savoir'],
    practiceSuggestions: ['S’entraîner'],
    errorCode: null,
  );
}

CourseProgress courseProgress() {
  return CourseProgress(
    courseId: 'course-1',
    subjectId: 'subject-1',
    knowledgeUnitCount: 12,
    practicedKnowledgeUnitCount: 3,
    coverage: 0.25,
    mastery: 0.72,
    estimatedGlobalMastery: 0.18,
    readySourceCount: 1,
    processingSourceCount: 0,
    failedSourceCount: 0,
    lastPracticedAt: DateTime.utc(2026, 6, 18, 12),
    state: CourseProgressState.practiced,
  );
}

SubjectProgress subjectProgress() {
  return SubjectProgress(
    subjectId: 'subject-1',
    knowledgeUnitCount: 12,
    practicedKnowledgeUnitCount: 3,
    coverage: 0.25,
    mastery: 0.72,
    estimatedGlobalMastery: 0.18,
    courseCount: 1,
    readyCourseCount: 1,
    lastPracticedAt: DateTime.utc(2026, 6, 18, 12),
    courses: const [
      SubjectCourseProgressItem(
        courseId: 'course-1',
        title: 'Droit constitutionnel',
        knowledgeUnitCount: 12,
        practicedKnowledgeUnitCount: 3,
        coverage: 0.25,
        mastery: 0.72,
        estimatedGlobalMastery: 0.18,
        state: CourseProgressState.practiced,
      ),
    ],
  );
}

class FakeCoursePdfPicker implements CoursePdfPicker {
  FakeCoursePdfPicker(this.result);

  final PickedCoursePdf? result;
  int pickCount = 0;

  @override
  Future<PickedCoursePdf?> pickPdf() async {
    pickCount += 1;
    return result;
  }
}

```
### test/features/courses/course_detail_page_test.dart

```dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/app/router/app_routes.dart';
import 'package:revision_app/features/courses/application/course_pdf_picker.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/courses/presentation/course_detail_page.dart';
import 'package:revision_app/presentation/design_system/components/revision_mvp_components.dart';

import '../../fakes/in_memory_courses_repository.dart';

void main() {
  testWidgets('course detail uploads a PDF source without fixture content', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..uploadDelay = const Duration(milliseconds: 50);
    final picker = FakeCoursePdfPicker(
      PickedCoursePdf(
        fileName: 'cours.pdf',
        bytes: Uint8List.fromList('%PDF-1.7'.codeUnits),
      ),
    );

    await tester.pumpWidget(testApp(repository: repository, picker: picker));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text('Droit constitutionnel'), findsOneWidget);
    expect(find.text('Ajouter une source'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('870'), findsNothing);
    expect(find.text('7 jours'), findsNothing);

    final uploadButton = find.widgetWithText(
      RevisionGradientButton,
      'Ajouter une source',
    );
    await tester.scrollUntilVisible(uploadButton, 400);
    await tester.tap(uploadButton);
    await tester.pump();

    expect(find.text('Upload en cours...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump();

    expect(repository.uploadCount, 1);
    expect(repository.lastUploadedCourseId, 'course-1');
    expect(repository.lastUploadedFileName, 'cours.pdf');
    expect(find.text('Source ajoutée'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('cours.pdf'), 400);
    expect(find.text('cours.pdf'), findsOneWidget);
    expect(find.text('Téléversée'), findsOneWidget);
  });

  testWidgets('course detail displays failed source errors', (tester) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'broken.pdf',
            status: CourseDocumentStatus.failed,
            errorCode: 'PDF_PARSE_FAILED',
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('broken.pdf'), 400);
    expect(find.text('broken.pdf'), findsOneWidget);
    expect(find.text('Erreur'), findsOneWidget);
    expect(find.textContaining('PDF_PARSE_FAILED'), findsOneWidget);
  });

  testWidgets('course detail deletes a source after confirmation', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'cours.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('cours.pdf'), 400);
    expect(find.text('cours.pdf'), findsOneWidget);

    await tester.tap(find.byTooltip('Supprimer la source cours.pdf'));
    await tester.pumpAndSettle();

    expect(find.text('Supprimer cette source ?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(repository.deleteDocumentCount, 1);
    expect(repository.lastDeletedDocumentId, 'document-1');
    expect(find.text('Source supprimée'), findsOneWidget);
    expect(find.text('Aucune source attachée'), findsOneWidget);
  });

  testWidgets('course detail displays no-source progress state', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..progressByCourse['course-1'] = courseProgress(
        state: CourseProgressState.noSource,
        knowledgeUnitCount: 0,
        practicedKnowledgeUnitCount: 0,
        coverage: 0,
        mastery: null,
        estimatedGlobalMastery: 0,
        readySourceCount: 0,
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Progression réelle'), findsOneWidget);
    expect(find.text('0/0 notions travaillées'), findsOneWidget);
    expect(find.text('Ajoute une source pour commencer.'), findsOneWidget);
    expect(find.text('78%'), findsNothing);
  });

  testWidgets('course detail displays practiced real progress', (tester) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'ready.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      )
      ..progressByCourse['course-1'] = courseProgress();

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('3/12 notions travaillées'), findsOneWidget);
    expect(find.text('Maîtrise sur notions travaillées : 72%'), findsOneWidget);
    expect(find.text('Estimation globale : 18%'), findsOneWidget);
    expect(
      find.text('Progression réelle basée sur tes réponses.'),
      findsOneWidget,
    );
  });

  testWidgets('processing sources trigger bounded detail refresh polling', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'processing.pdf',
            status: CourseDocumentStatus.processing,
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pump();
    await tester.pump();

    expect(repository.getCourseCount, 1);
    expect(repository.getCourseProgressCount, 1);
    await tester.scrollUntilVisible(find.text('Traitement en cours'), 400);
    expect(find.text('Traitement en cours'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(repository.getCourseCount, greaterThanOrEqualTo(2));
    expect(repository.getCourseProgressCount, greaterThanOrEqualTo(2));
  });

  testWidgets('ready failed and empty sources do not trigger polling', (
    tester,
  ) async {
    for (final sources in [
      const <CourseDocument>[],
      const [
        CourseDocument(
          id: 'document-ready',
          courseId: 'course-1',
          documentId: 'document-ready',
          fileName: 'ready.pdf',
          status: CourseDocumentStatus.ready,
        ),
      ],
      const [
        CourseDocument(
          id: 'document-failed',
          courseId: 'course-1',
          documentId: 'document-failed',
          fileName: 'failed.pdf',
          status: CourseDocumentStatus.failed,
          errorCode: 'KNOWLEDGE_EXTRACTION_FAILED',
        ),
      ],
    ]) {
      final repository = InMemoryCoursesRepository()
        ..detailsByCourse['course-1'] = courseDetail(sources: sources);

      await tester.pumpWidget(
        testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
      );
      await tester.pump();
      await tester.pump();

      final detailReads = repository.getCourseCount;
      final progressReads = repository.getCourseProgressCount;

      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(repository.getCourseCount, detailReads);
      expect(repository.getCourseProgressCount, progressReads);
    }
  });

  testWidgets('course sheet CTA asks for a source when none exists', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail();

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    final emptyButton = tester.widget<RevisionGradientButton>(
      find.widgetWithText(
        RevisionGradientButton,
        'Ajoute une source pour créer une fiche',
      ),
    );
    expect(emptyButton.onPressed, isNull);

    final emptyQuickButton = tester.widget<RevisionGradientButton>(
      find.widgetWithText(
        RevisionGradientButton,
        'Ajoute une source pour réviser',
      ),
    );
    expect(emptyQuickButton.onPressed, isNull);
  });

  testWidgets('course sheet CTA waits while a source is processing', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'processing.pdf',
            status: CourseDocumentStatus.processing,
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    final processingSheetButton = tester.widget<RevisionGradientButton>(
      find.widgetWithText(
        RevisionGradientButton,
        'Fiche disponible après traitement',
      ),
    );
    expect(processingSheetButton.onPressed, isNull);

    final processingQuickButton = tester.widget<RevisionGradientButton>(
      find.widgetWithText(
        RevisionGradientButton,
        'Révision disponible après traitement',
      ),
    );
    expect(processingQuickButton.onPressed, isNull);
  });

  testWidgets('course sheet CTA is enabled when a READY source exists', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'ready.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    final sheetButton = tester.widget<RevisionGradientButton>(
      find.widgetWithText(RevisionGradientButton, 'Fiche de cours'),
    );
    expect(sheetButton.onPressed, isNotNull);

    final quickButton = tester.widget<RevisionGradientButton>(
      find.widgetWithText(RevisionGradientButton, 'Révision rapide'),
    );
    expect(quickButton.onPressed, isNotNull);
  });

  testWidgets('ready quick revision starts the real revision session route', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'ready.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      )
      ..quickRevisionDelay = const Duration(milliseconds: 50);

    await tester.pumpWidget(
      routerTestApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    final quickButton = find.widgetWithText(
      RevisionGradientButton,
      'Révision rapide',
    );
    final quickWidget = tester.widget<RevisionGradientButton>(quickButton);
    quickWidget.onPressed!();
    await tester.pump();

    expect(find.text('Démarrage...'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(repository.startQuickRevisionCount, 1);
    expect(repository.lastQuickRevisionCourseId, 'course-1');
    expect(find.text('Session réelle'), findsOneWidget);
  });
}

Widget testApp({
  required InMemoryCoursesRepository repository,
  required CoursePdfPicker picker,
}) {
  _ensureDefaultProgress(repository);

  return ProviderScope(
    overrides: [
      coursesRepositoryProvider.overrideWithValue(repository),
      coursePdfPickerProvider.overrideWithValue(picker),
    ],
    child: const MaterialApp(
      home: Scaffold(body: CourseDetailPage(courseId: 'course-1')),
    ),
  );
}

Widget routerTestApp({
  required InMemoryCoursesRepository repository,
  required CoursePdfPicker picker,
}) {
  _ensureDefaultProgress(repository);

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: CourseDetailPage(courseId: 'course-1')),
      ),
      GoRoute(
        path: AppRoutes.revisionSessionPath,
        builder: (context, state) => Scaffold(
          body: Text(
            state.uri.queryParameters['sessionId'] == 'revision-session-1'
                ? 'Session réelle'
                : 'Session inconnue',
          ),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      coursesRepositoryProvider.overrideWithValue(repository),
      coursePdfPickerProvider.overrideWithValue(picker),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void _ensureDefaultProgress(InMemoryCoursesRepository repository) {
  repository.progressByCourse.putIfAbsent(
    'course-1',
    () => courseProgress(
      state: CourseProgressState.noSource,
      knowledgeUnitCount: 0,
      practicedKnowledgeUnitCount: 0,
      coverage: 0,
      mastery: null,
      estimatedGlobalMastery: 0,
      readySourceCount: 0,
    ),
  );
}

CourseDetail courseDetail({List<CourseDocument> sources = const []}) {
  const course = CourseListItem(
    id: 'course-1',
    subjectId: 'subject-1',
    title: 'Droit constitutionnel',
    sourceCount: 0,
    readySourceCount: 0,
    processingSourceCount: 0,
    failedSourceCount: 0,
  );
  return CourseDetail(
    course: course,
    subject: const CourseSubjectSummary(id: 'subject-1', name: 'Droit'),
    sources: sources,
  );
}

CourseProgress courseProgress({
  CourseProgressState state = CourseProgressState.practiced,
  int knowledgeUnitCount = 12,
  int practicedKnowledgeUnitCount = 3,
  double coverage = 0.25,
  double? mastery = 0.72,
  double estimatedGlobalMastery = 0.18,
  int readySourceCount = 1,
}) {
  return CourseProgress(
    courseId: 'course-1',
    subjectId: 'subject-1',
    knowledgeUnitCount: knowledgeUnitCount,
    practicedKnowledgeUnitCount: practicedKnowledgeUnitCount,
    coverage: coverage,
    mastery: mastery,
    estimatedGlobalMastery: estimatedGlobalMastery,
    readySourceCount: readySourceCount,
    processingSourceCount: 0,
    failedSourceCount: 0,
    lastPracticedAt: DateTime.utc(2026, 6, 18, 12),
    state: state,
  );
}

class FakeCoursePdfPicker implements CoursePdfPicker {
  FakeCoursePdfPicker(this.result);

  final PickedCoursePdf? result;

  @override
  Future<PickedCoursePdf?> pickPdf() async => result;
}

```
### docs/core/MVP_CORE_ACCEPTANCE_RUNBOOK.md

```md
# MVP Core acceptance runbook

Ce runbook vérifie le parcours MVP Core réel côté Flutter, sans fixtures MVP dans le routing réel.

## Parcours utilisateur

1. Ouvrir l'app avec un utilisateur authentifié.
2. Voir les matières réelles.
3. Créer ou ouvrir un cours réel.
4. Ouvrir le détail du cours.
5. Cliquer sur `Ajouter une source`.
6. Choisir un PDF réel.
7. Attendre le traitement jusqu'au statut `Prête`.
8. Ouvrir `Fiche de cours`.
9. Revenir au cours.
10. Démarrer `Révision rapide`.
11. Répondre au QCM.
12. Revenir sur le cours ou l'onglet `Progrès`.
13. Vérifier la progression réelle.

## Vérifications UI attendues

- Le détail cours affiche uniquement les sources réelles de l'API.
- Une source `UPLOADED` ou `PROCESSING` déclenche un polling borné.
- Pendant ce polling, le détail et la progression sont rafraîchis.
- La fiche n'est activée que si une source `READY` existe.
- La révision rapide n'est activée que si une source `READY` existe.
- `/progress` affiche `SubjectProgressPage`, pas une page pending CORE-06.
- Les compteurs fake `78%`, `870`, `7 jours` et `Loi normale` ne doivent pas apparaître dans le parcours réel.

## Commandes de validation

```bash
dart analyze lib test
flutter test test/features/courses --reporter compact
flutter test test/features/revision_sessions --reporter compact
flutter test test/app/router/app_router_test.dart --reporter compact
flutter test test/app/revision_app_test.dart --reporter compact
flutter test test/app --reporter compact
flutter test --reporter compact
git diff --check
```

## Hors MVP Core

- Révision approfondie.
- Préparation examen.
- Résultat final dédié de session.
- Gamification durable.
- Multi-source avancé.
- `CourseSource`.
- WebSocket/SSE de progression.

## Notes de cohérence

- L'upload réussi invalide le détail, la liste de cours, la progression du cours et la progression matière.
- L'annulation du picker ne déclenche aucun upload ni refresh artificiel.
- L'échec d'upload ne simule pas une source réelle.
- Le démarrage d'une révision rapide ne rafraîchit pas la progression : la mastery change après submit, pas au start.
- La génération d'une fiche ne rafraîchit pas la progression : elle ne modifie ni `MasteryState` ni `Document.status`.

```

````````
