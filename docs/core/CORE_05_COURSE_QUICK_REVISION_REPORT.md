# CORE-05 — Course quick revision V0 avec session réelle course-level

## 1. Résumé du lot

CORE-05 rend le bouton `Révision rapide` réel dans le détail d'un cours. Quand le cours possède au moins une source `READY`, l'app appelle `POST /courses/:courseId/revision-sessions/quick`, parse une `RevisionSessionResponse`, puis navigue vers la vraie page de session existante `/activities/session?sessionId=...`.

Aucune fixture métier n'est ajoutée. Le bouton reste désactivé sans source prête, avec des libellés honnêtes.

## 2. Audit initial

- La vraie route de session Flutter est `AppRoutes.revisionSession(...)`, soit `/activities/session` avec `sessionId` en query parameter.
- Les routes `/revision-sessions/:sessionId` et `/revision-sessions/:sessionId/result` restent des pages pending course MVP+.
- `CourseDetailPage` affichait déjà les sources et activait la fiche selon `READY`, mais gardait `Révision rapide bientôt disponible` désactivé.
- `CoursesRepository` avait déjà les méthodes courses/sources/fiches ; il manquait le port course quick revision.
- Le parser `RevisionSessionResponse` vivait dans `HttpRevisionSessionsApi`; il a été rendu réutilisable par le repository courses pour éviter de copier un second parser.

## 3. Synthèse des sub-agents ou passes

- Passe Audit & architecture : route vraie identifiée comme `/activities/session`; route V2 confirmée pending.
- Passe Backend : endpoint course quick exposé côté API, consommé ici.
- Passe Frontend : port repository, implémentation HTTP, controller Riverpod, bouton et navigation.
- Passe Tests & validation : tests repository/provider/widget/session parser/router/full Flutter.
- Passe Review critique : vérification anti-fixture, anti-`CourseSource`, navigation non-pending, absence d'envoi `subjectId` / `documentId` / `knowledgeUnitId`.

## 4. Choix d'architecture

Le front conserve le flow session existant. `CourseDetailPage` ne construit pas une session locale et ne navigue pas vers une page pending. Le controller `startCourseQuickRevisionControllerProvider` expose seulement l'état local de démarrage, puis la page navigue avec l'id de session retourné par le backend.

Le parser de session est partagé en exposant `RevisionSessionResponseJson`. J'ai évité une extraction physique dans un troisième fichier pour limiter le churn, tout en évitant une duplication de parser dans `features/courses`.

## 5. Détail backend

Côté frontend, le backend est consommé via `POST /courses/:courseId/revision-sessions/quick`. Le client n'envoie aucun `studentId`, `subjectId`, `documentId` ni `knowledgeUnitId`.

## 6. Détail frontend

- `CoursesRepository` ajoute `startCourseQuickRevision`.
- `HttpCoursesRepository` POSTe sans body vers l'endpoint course-level et mappe 404/409 vers exceptions typées.
- `RevisionSession` contient maintenant `courseId` optionnel.
- `CourseDetailPage` active `Révision rapide` seulement si une source est `READY`.
- Labels UI : `Révision rapide`, `Révision disponible après traitement`, `Ajoute une source pour réviser`, `Aucune source prête`.
- La navigation utilise `AppRoutes.revisionSession(sessionId: response.session.id)`.
- `RevisionTopCounters` ne contient plus de fausses valeurs par défaut `12` / `870` ; sans valeurs réelles, il ne rend rien.

## 7. Endpoints ajoutés/réutilisés

- Consommé : `POST /courses/:courseId/revision-sessions/quick`.
- Réutilisé : `/activities/session?sessionId=...` pour afficher la vraie session.
- Non utilisé : `AppRoutes.revisionSessionV2`, car il pointe vers une page pending.

## 8. Fichiers créés/modifiés/supprimés

### Créés

- `docs/core/CORE_05_COURSE_QUICK_REVISION_REPORT.md`

### Modifiés

- `lib/features/courses/application/courses_providers.dart`
- `lib/features/courses/data/http_courses_repository.dart`
- `lib/features/courses/domain/courses_repository.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/features/revision_sessions/data/http_revision_sessions_api.dart`
- `lib/features/revision_sessions/domain/revision_session.dart`
- `lib/presentation/design_system/components/revision_mvp_components.dart`
- `test/fakes/in_memory_courses_repository.dart`
- `test/fakes/in_memory_revision_sessions_api.dart`
- `test/features/courses/course_detail_page_test.dart`
- `test/features/courses/courses_providers_test.dart`
- `test/features/courses/http_courses_repository_test.dart`
- `test/features/revision_sessions/http_revision_sessions_api_test.dart`

### Supprimés

Aucun.

## 9. Tests exécutés

- `dart format lib/features/courses lib/features/revision_sessions test/features/courses test/features/revision_sessions test/app` : 31 fichiers vérifiés, 0 changement.
- `dart analyze lib test` : no issues found.
- `flutter test test/features/courses --reporter compact` : all tests passed.
- `flutter test test/features/revision_sessions --reporter compact` : all tests passed.
- `flutter test test/app/router/app_router_test.dart --reporter compact` : all tests passed.
- `flutter test test/app/revision_app_test.dart --reporter compact` : all tests passed.
- `flutter test test/app --reporter compact` : all tests passed après relance seule. Le premier lancement en parallèle a déclenché un crash Flutter SPM `PathExistsException`, puis la relance isolée a réussi.
- `flutter test --reporter compact` : all tests passed, 402 tests.
- `rg "CourseSource" lib test || true` : aucune occurrence.
- `rg "Loi normale|78%|870|7 jours" lib test || true` : occurrences restantes uniquement dans assertions `findsNothing` et legacy `features/mvp`; rien dans `features/courses` ni le shell réel.
- `git diff --check` : OK, aucune sortie.

## 10. Résultats exacts des commandes

`dart analyze lib test` : `No issues found!`.

`flutter test test/features/courses --reporter compact` : `All tests passed!`.

`flutter test test/features/revision_sessions --reporter compact` : `All tests passed!`.

`flutter test test/app/router/app_router_test.dart --reporter compact` : `All tests passed!`.

`flutter test test/app/revision_app_test.dart --reporter compact` : `All tests passed!`.

`flutter test test/app --reporter compact` : première tentative concurrente KO avec `PathExistsException: Cannot create link ... shared_preferences_foundation-2.5.6`; relance isolée OK, `All tests passed!`.

`flutter test --reporter compact` : `All tests passed!`, 402 tests.

`git diff --check` : terminé avec code 0, aucune sortie.

## 11. Limites connues

- La révision rapide démarre une session réelle, mais la stratégie pédagogique détaillée reste backend V0.
- Aucun affichage de progression course-level n'est ajouté.
- Deep/exam restent désactivés.
- Le legacy `features/mvp` contient encore des fixtures, mais il n'est pas utilisé par le flow Course réel.

## 12. Risques restants

- En cas de 409 backend, l'UI affiche le message dans une snackbar ; il faudra peut-être un état inline plus riche en CORE-06.
- Le parser `RevisionSessionResponseJson` est partagé depuis le fichier API revision sessions plutôt qu'extrait dans un fichier dédié ; c'est acceptable mais pas parfait.
- La page de session réelle dépend toujours du flow historique `activities/session`.

## 13. Review séparée

- Scope : pas de deep/exam, pas de nouvelle page session, pas de fixtures.
- API : POST sans body et sans ids client-owned.
- UI : bouton actif uniquement avec source READY.
- Navigation : vraie route `/activities/session`, pas `revisionSessionV2` pending.
- Anti-fixture : grep course propre ; occurrences restantes uniquement tests anti-fixture et legacy MVP.
- Design system : suppression des compteurs statiques par défaut.
- Tests : repository, provider, widget, parser session, router, app et full Flutter passent.
- Aucun commit Git réalisé.

## 14. Auto-critique

Solide : le front ne choisit pas de source/notion, n'envoie pas `subjectId`/`documentId`, et réutilise la vraie page de session.

Fragile : l'état d'erreur UI du démarrage rapide est minimal et passe par snackbar + texte générique.

Fait au plus simple : le controller Riverpod est local au démarrage quick et ne crée pas de nouvel état global.

À reprendre : meilleure UX d'indisponibilité, progression course-level, modes deep/exam, choix de source/notion plus tard si nécessaire.

CORE-05 ne doit pas encore activer deep/exam car ces modes impliquent des contrats pédagogiques et de progression qui ne sont pas prêts.

## 15. Points discutables du prompt

- Le prompt suggère d'extraire le parser dans un fichier dédié. J'ai privilégié un parser unique public dans le fichier existant pour éviter une migration plus large ; une extraction propre reste possible.
- Le grep anti-fixture global attrape volontairement le legacy `features/mvp`. Je l'ai interprété par périmètre : rien n'est utilisé dans `features/courses` ou le shell réel.
- Supprimer les faux compteurs par défaut dans le design system dépasse légèrement CORE-05, mais cela enlève une fausse valeur durable et respecte la direction CORE-00.


## 16. Contenu complet des fichiers créés, modifiés ou supprimés

Le rapport courant n'est pas inclus dans cette section pour éviter une récursion infinie. Aucun fichier n'a été supprimé.

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
    ref.invalidate(coursesProvider(detail.course.subjectId));

    return uploaded;
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

### lib/features/courses/data/http_courses_repository.dart

```dart
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../domain/course_models.dart';
import '../domain/courses_repository.dart';
import '../../documents/data/revision_sheet_json.dart';
import '../../documents/domain/revision_document.dart';
import '../../revision_sessions/data/http_revision_sessions_api.dart';
import '../../revision_sessions/domain/revision_session.dart';

class HttpCoursesRepository implements CoursesRepository {
  HttpCoursesRepository({
    required Dio dio,
    required Future<String> Function() getIdToken,
  }) : this._(dio, getIdToken);

  const HttpCoursesRepository._(this._dio, this._getIdToken);

  final Dio _dio;
  final Future<String> Function() _getIdToken;

  @override
  Future<List<CourseListItem>> listCourses({required String subjectId}) async {
    final response = await _dio.get<Object?>(
      '/subjects/${Uri.encodeComponent(subjectId)}/courses',
      options: await _authorizedOptions(),
    );
    final rawCourses = response.data;

    if (rawCourses is! List) {
      throw const FormatException('Invalid courses response');
    }

    return rawCourses
        .map((course) => _CourseJson(course).toListItem())
        .toList(growable: false);
  }

  @override
  Future<CourseDetail> getCourse({required String courseId}) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}',
        options: await _authorizedOptions(),
      );

      return _CourseDetailJson(response.data).toDetail();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      rethrow;
    }
  }

  @override
  Future<CourseListItem> createCourse({
    required String subjectId,
    required CreateCourseInput input,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/subjects/${Uri.encodeComponent(subjectId)}/courses',
        data: {
          'title': input.title,
          'description': input.description,
          'chapterLabel': input.chapterLabel,
          'estimatedMinutes': input.estimatedMinutes,
        },
        options: await _authorizedOptions(),
      );

      return _CourseJson(response.data).toListItem();
    } on DioException catch (error) {
      if (error.response?.statusCode == 400) {
        throw const CourseRequestException('Invalid course request');
      }
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course subject not found');
      }
      rethrow;
    }
  }

  @override
  Future<CourseDocument> uploadCoursePdf({
    required String courseId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/source/course-pdf',
        data: FormData.fromMap({
          'file': MultipartFile.fromBytes(
            bytes,
            filename: fileName,
            contentType: DioMediaType('application', 'pdf'),
          ),
        }),
        options: await _authorizedOptions(),
      );

      return _CourseDocumentJson(response.data).toDocument();
    } on DioException catch (error) {
      if (error.response?.statusCode == 400) {
        throw const CourseUploadException('Invalid course PDF upload');
      }
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      rethrow;
    }
  }

  @override
  Future<RevisionSheet?> getCourseRevisionSheet({
    required String courseId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/revision-sheet',
        options: await _authorizedOptions(),
      );

      return RevisionSheetJson(response.data).toRevisionSheet();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        final message = _responseMessage(error);
        if (message == 'Revision sheet not found') {
          return null;
        }

        // CORE-04-bis: an ambiguous 404 is safer as a missing course than as
        // a missing sheet, otherwise a deleted/unknown course looks generatable.
        throw const CourseNotFoundException('Course not found');
      }
      if (error.response?.statusCode == 409) {
        throw const CourseRevisionSheetNotReadyException(
          'Course has no ready source',
        );
      }
      rethrow;
    }
  }

  @override
  Future<RevisionSheet> generateCourseRevisionSheet({
    required String courseId,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/revision-sheet',
        options: await _authorizedOptions(),
      );

      return RevisionSheetJson(response.data).toRevisionSheet();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      if (error.response?.statusCode == 409) {
        throw const CourseRevisionSheetNotReadyException(
          'Course has no ready source',
        );
      }
      rethrow;
    }
  }

  @override
  Future<RevisionSessionResponse> startCourseQuickRevision({
    required String courseId,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/revision-sessions/quick',
        options: await _authorizedOptions(),
      );

      return RevisionSessionResponseJson(response.data).toResponse();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      if (error.response?.statusCode == 409) {
        final message = _responseMessage(error);
        throw CourseQuickRevisionUnavailableException(
          message ?? 'Course quick revision is not available',
        );
      }
      rethrow;
    }
  }

  @override
  Future<CourseProgress> getCourseProgress({required String courseId}) {
    throw UnimplementedError('Progression course réelle hors CORE-02');
  }

  Future<Options> _authorizedOptions() async {
    final token = (await _getIdToken()).trim();

    if (token.isEmpty) {
      throw StateError('A Firebase ID token is required to load courses');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  String? _responseMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, Object?>) {
      final message = data['message'];
      if (message is String) {
        return message;
      }
    }

    return null;
  }
}

class _CourseJson {
  const _CourseJson(this.value);

  final Object? value;

  CourseListItem toListItem() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid course response');
    }

    final id = json['id'];
    final subjectId = json['subjectId'];
    final title = json['title'];
    final description = json['description'];
    final chapterLabel = json['chapterLabel'];
    final estimatedMinutes = json['estimatedMinutes'];
    final displayOrder = json['displayOrder'];
    final sourceCount = json['sourceCount'];
    final readySourceCount = json['readySourceCount'];
    final processingSourceCount = json['processingSourceCount'];
    final failedSourceCount = json['failedSourceCount'];

    if (id is! String ||
        subjectId is! String ||
        title is! String ||
        displayOrder is! int ||
        sourceCount is! int ||
        readySourceCount is! int ||
        processingSourceCount is! int ||
        failedSourceCount is! int) {
      throw const FormatException('Invalid course response');
    }

    return CourseListItem(
      id: id,
      subjectId: subjectId,
      title: title,
      description: description is String ? description : null,
      chapterLabel: chapterLabel is String ? chapterLabel : null,
      estimatedMinutes: estimatedMinutes is int ? estimatedMinutes : null,
      displayOrder: displayOrder,
      createdAt: _parseOptionalDate(json['createdAt']),
      updatedAt: _parseOptionalDate(json['updatedAt']),
      sourceCount: sourceCount,
      readySourceCount: readySourceCount,
      processingSourceCount: processingSourceCount,
      failedSourceCount: failedSourceCount,
    );
  }
}

class _CourseDetailJson {
  const _CourseDetailJson(this.value);

  final Object? value;

  CourseDetail toDetail() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid course detail response');
    }

    final subject = json['subject'];
    final sources = json['sources'];

    if (subject is! Map<String, Object?> || sources is! List) {
      throw const FormatException('Invalid course detail response');
    }

    final subjectId = subject['id'];
    final subjectName = subject['name'];

    if (subjectId is! String || subjectName is! String) {
      throw const FormatException('Invalid course detail response');
    }

    return CourseDetail(
      course: _CourseJson(json['course']).toListItem(),
      subject: CourseSubjectSummary(id: subjectId, name: subjectName),
      sources: sources
          .map((source) => _CourseDocumentJson(source).toDocument())
          .toList(growable: false),
    );
  }
}

class _CourseDocumentJson {
  const _CourseDocumentJson(this.value);

  final Object? value;

  CourseDocument toDocument() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid course source response');
    }

    final id = json['id'];
    final courseId = json['courseId'];
    final documentId = json['documentId'];
    final fileName = json['fileName'];
    final kind = json['kind'];
    final status = json['status'];
    final errorCode = json['errorCode'];

    if (id is! String ||
        courseId is! String ||
        documentId is! String ||
        fileName is! String ||
        kind is! String ||
        status is! String) {
      throw const FormatException('Invalid course source response');
    }

    return CourseDocument(
      id: id,
      courseId: courseId,
      documentId: documentId,
      fileName: fileName,
      kind: kind,
      status: _parseDocumentStatus(status),
      errorCode: errorCode is String ? errorCode : null,
      createdAt: _parseOptionalDate(json['createdAt']),
      updatedAt: _parseOptionalDate(json['updatedAt']),
    );
  }
}

CourseDocumentStatus _parseDocumentStatus(String value) {
  return switch (value) {
    'UPLOADED' => CourseDocumentStatus.uploaded,
    'PROCESSING' => CourseDocumentStatus.processing,
    'READY' => CourseDocumentStatus.ready,
    'FAILED' => CourseDocumentStatus.failed,
    _ => throw const FormatException('Unknown course source status'),
  };
}

DateTime? _parseOptionalDate(Object? value) {
  if (value == null) {
    return null;
  }

  if (value is! String) {
    throw const FormatException('Invalid date response');
  }

  return DateTime.parse(value);
}

```

### lib/features/courses/domain/courses_repository.dart

```dart
import 'dart:typed_data';

import '../../documents/domain/revision_document.dart';
import '../../revision_sessions/domain/revision_session.dart';
import 'course_models.dart';

abstract interface class CoursesRepository {
  Future<List<CourseListItem>> listCourses({required String subjectId});

  Future<CourseDetail> getCourse({required String courseId});

  Future<CourseListItem> createCourse({
    required String subjectId,
    required CreateCourseInput input,
  });

  Future<CourseDocument> uploadCoursePdf({
    required String courseId,
    required String fileName,
    required Uint8List bytes,
  });

  Future<RevisionSheet?> getCourseRevisionSheet({required String courseId});

  Future<RevisionSheet> generateCourseRevisionSheet({required String courseId});

  Future<RevisionSessionResponse> startCourseQuickRevision({
    required String courseId,
  });

  Future<CourseProgress> getCourseProgress({required String courseId});
}

class CreateCourseInput {
  const CreateCourseInput({
    required this.title,
    this.description,
    this.chapterLabel,
    this.estimatedMinutes,
  });

  final String title;
  final String? description;
  final String? chapterLabel;
  final int? estimatedMinutes;
}

class CourseNotFoundException implements Exception {
  const CourseNotFoundException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CourseRequestException implements Exception {
  const CourseRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CourseUploadException implements Exception {
  const CourseUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CourseRevisionSheetNotReadyException implements Exception {
  const CourseRevisionSheetNotReadyException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CourseQuickRevisionUnavailableException implements Exception {
  const CourseQuickRevisionUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
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
        _CourseActions(detail: detail),
        if (_pollTimedOut)
          RevisionGlassCard(
            child: Text(
              'Le traitement continue en arrière-plan. Tu peux revenir plus tard.',
              style: RevisionTypography.body,
            ),
          ),
        _SourcesSection(
          sources: detail.sources,
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

class _SourcesSection extends StatelessWidget {
  const _SourcesSection({required this.sources, required this.onRefresh});

  final List<CourseDocument> sources;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
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
              ],
            ),
          ),
          const SizedBox(height: RevisionSpacing.m),
        ],
      ],
    );
  }
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

### lib/features/revision_sessions/data/http_revision_sessions_api.dart

```dart
import 'package:dio/dio.dart';

import '../../activities/domain/diagnostic_quiz_activity.dart';
import '../../activities/domain/open_question_activity.dart';
import '../domain/revision_session.dart';
import 'revision_sessions_api.dart';

class HttpRevisionSessionsApi implements RevisionSessionsApi {
  HttpRevisionSessionsApi({
    required Dio dio,
    required Future<String> Function() getIdToken,
  }) : this._(dio, getIdToken);

  const HttpRevisionSessionsApi._(this._dio, this._getIdToken);

  final Dio _dio;
  final Future<String> Function() _getIdToken;

  @override
  Future<RevisionSessionResponse> startRevisionSession({
    required String subjectId,
    String? documentId,
    String? knowledgeUnitId,
    RevisionSessionPreferredAction? preferredAction,
  }) async {
    final data = <String, Object?>{'subjectId': subjectId};
    if (documentId != null) {
      data['documentId'] = documentId;
    }
    if (knowledgeUnitId != null) {
      data['knowledgeUnitId'] = knowledgeUnitId;
    }
    if (preferredAction != null) {
      data['preferredAction'] = _preferredActionJson(preferredAction);
    }

    final response = await _dio.post<Object?>(
      '/revision-sessions',
      data: data,
      options: await _authorizedOptions(),
    );

    return RevisionSessionResponseJson(response.data).toResponse();
  }

  @override
  Future<RevisionSessionResponse> getRevisionSession({
    required String sessionId,
  }) async {
    final response = await _dio.get<Object?>(
      '/revision-sessions/$sessionId',
      options: await _authorizedOptions(),
    );

    return RevisionSessionResponseJson(response.data).toResponse();
  }

  Future<Options> _authorizedOptions() async {
    final token = (await _getIdToken()).trim();

    if (token.isEmpty) {
      throw StateError('A Firebase ID token is required for revision sessions');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  String _preferredActionJson(RevisionSessionPreferredAction action) {
    return switch (action) {
      RevisionSessionPreferredAction.diagnosticQuiz => 'diagnostic_quiz',
      RevisionSessionPreferredAction.openQuestion => 'open_question',
      RevisionSessionPreferredAction.richClosedExercise =>
        'rich_closed_exercise',
    };
  }
}

class RevisionSessionResponseJson {
  const RevisionSessionResponseJson(this.value);

  final Object? value;

  RevisionSessionResponse toResponse() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision session response');
    }

    final session = json['session'];
    final currentAction = json['currentAction'];
    final history = json['history'];

    if (session is! Map<String, Object?> || history is! List) {
      throw const FormatException('Invalid revision session response');
    }

    return RevisionSessionResponse(
      session: _RevisionSessionJson(session).toSession(),
      currentAction: currentAction == null
          ? null
          : _RevisionSessionActionJson(
              currentAction,
              allowPayload: true,
            ).toAction(),
      history: history
          .map(
            (action) => _RevisionSessionActionJson(
              action,
              allowPayload: false,
            ).toAction(),
          )
          .toList(growable: false),
    );
  }
}

class _RevisionSessionJson {
  const _RevisionSessionJson(this.value);

  final Map<String, Object?> value;

  RevisionSession toSession() {
    final id = value['id'];
    final status = value['status'];
    final subjectId = value['subjectId'];
    final courseId = value['courseId'];
    final documentId = value['documentId'];
    final knowledgeUnitId = value['knowledgeUnitId'];
    final createdAt = value['createdAt'];
    final completedAt = value['completedAt'];

    if (id is! String ||
        status is! String ||
        subjectId is! String ||
        createdAt is! String) {
      throw const FormatException('Invalid revision session response');
    }

    return RevisionSession(
      id: id,
      status: _sessionStatus(status),
      subjectId: subjectId,
      courseId: courseId is String ? courseId : null,
      documentId: documentId is String ? documentId : null,
      knowledgeUnitId: knowledgeUnitId is String ? knowledgeUnitId : null,
      createdAt: DateTime.parse(createdAt),
      completedAt: completedAt is String ? DateTime.parse(completedAt) : null,
    );
  }

  RevisionSessionStatus _sessionStatus(String status) {
    return switch (status) {
      'STARTED' => RevisionSessionStatus.started,
      'COMPLETED' => RevisionSessionStatus.completed,
      'ABANDONED' => RevisionSessionStatus.abandoned,
      _ => RevisionSessionStatus.unknown,
    };
  }
}

class _RevisionSessionActionJson {
  const _RevisionSessionActionJson(this.value, {required this.allowPayload});

  final Object? value;
  final bool allowPayload;

  RevisionSessionAction toAction() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision session action response');
    }

    final id = json['id'];
    final kind = json['kind'];
    final status = json['status'];
    final displayOrder = json['displayOrder'];
    final activitySessionId = json['activitySessionId'];
    final documentId = json['documentId'];
    final knowledgeUnitId = json['knowledgeUnitId'];

    if (id is! String ||
        kind is! String ||
        status is! String ||
        displayOrder is! int) {
      throw const FormatException('Invalid revision session action response');
    }

    return RevisionSessionAction(
      id: id,
      kind: _actionKind(kind),
      status: _actionStatus(status),
      displayOrder: displayOrder,
      activitySessionId: activitySessionId is String ? activitySessionId : null,
      documentId: documentId is String ? documentId : null,
      knowledgeUnitId: knowledgeUnitId is String ? knowledgeUnitId : null,
      payload: allowPayload
          ? _ActionPayloadJson(json['payload']).toPayload()
          : null,
    );
  }

  RevisionSessionActionKind _actionKind(String kind) {
    return switch (kind) {
      'DIAGNOSTIC_QUIZ' => RevisionSessionActionKind.diagnosticQuiz,
      'OPEN_QUESTION' => RevisionSessionActionKind.openQuestion,
      'RICH_CLOSED_EXERCISE' => RevisionSessionActionKind.richClosedExercise,
      _ => RevisionSessionActionKind.unknown,
    };
  }

  RevisionSessionActionStatus _actionStatus(String status) {
    return switch (status) {
      'READY' => RevisionSessionActionStatus.ready,
      'COMPLETED' => RevisionSessionActionStatus.completed,
      'FAILED' => RevisionSessionActionStatus.failed,
      _ => RevisionSessionActionStatus.unknown,
    };
  }
}

class _ActionPayloadJson {
  const _ActionPayloadJson(this.value);

  final Object? value;

  RevisionSessionActionPayload? toPayload() {
    final json = value;
    if (json == null) {
      return null;
    }

    if (json is! Map<String, Object?>) {
      return const RevisionSessionUnknownPayload();
    }

    final type = json['type'];
    if (type == 'diagnostic_quiz') {
      return _diagnosticQuizPayload(json);
    }
    if (type == 'open_question') {
      return _openQuestionPayload(json);
    }
    if (type == 'rich_closed_exercise') {
      return _richClosedExercisePayload(json);
    }

    return const RevisionSessionUnknownPayload();
  }

  RevisionSessionActionPayload _diagnosticQuizPayload(
    Map<String, Object?> json,
  ) {
    if (json['questions'] is List && json['title'] is String) {
      try {
        return RevisionSessionDiagnosticQuizPayload(
          _DiagnosticQuizActivityJson(json).toActivity(),
        );
      } on FormatException {
        return const RevisionSessionUnknownPayload();
      }
    }

    return RevisionSessionMinimalPayload(
      type: 'diagnostic_quiz',
      sessionId: json['sessionId'] is String
          ? json['sessionId'] as String
          : null,
    );
  }

  RevisionSessionActionPayload _openQuestionPayload(Map<String, Object?> json) {
    if (json['question'] is Map<String, Object?>) {
      try {
        return RevisionSessionOpenQuestionPayload(
          _OpenQuestionActivityJson(json).toActivity(),
        );
      } on FormatException {
        return const RevisionSessionUnknownPayload();
      }
    }

    return RevisionSessionMinimalPayload(
      type: 'open_question',
      sessionId: json['sessionId'] is String
          ? json['sessionId'] as String
          : null,
    );
  }

  RevisionSessionActionPayload _richClosedExercisePayload(
    Map<String, Object?> json,
  ) {
    if (_containsRichClosedExerciseContent(json)) {
      return const RevisionSessionUnknownPayload();
    }

    final subjectId = json['subjectId'];
    final documentId = json['documentId'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final knowledgeUnitTitle = json['knowledgeUnitTitle'];
    final reason = json['reason'];
    final estimatedMinutes = json['estimatedMinutes'];
    final preferredAction = json['preferredAction'];

    if (subjectId is! String || knowledgeUnitId is! String) {
      return const RevisionSessionUnknownPayload();
    }

    return RevisionSessionRichClosedExercisePayload(
      subjectId: subjectId,
      documentId: documentId is String ? documentId : null,
      knowledgeUnitId: knowledgeUnitId,
      knowledgeUnitTitle: knowledgeUnitTitle is String
          ? knowledgeUnitTitle
          : null,
      reason: reason is String ? reason : 'Questions riches recommandées.',
      estimatedMinutes: estimatedMinutes is int ? estimatedMinutes : 8,
      preferredAction: preferredAction is String ? preferredAction : null,
    );
  }

  bool _containsRichClosedExerciseContent(Map<String, Object?> json) {
    return json.containsKey('questions') ||
        json.containsKey('answers') ||
        json.containsKey('correction') ||
        json.containsKey('correctAnswers') ||
        json.containsKey('score');
  }
}

class _DiagnosticQuizActivityJson {
  const _DiagnosticQuizActivityJson(this.value);

  final Map<String, Object?> value;

  DiagnosticQuizActivity toActivity() {
    final sessionId = value['sessionId'];
    final type = value['type'];
    final version = value['version'];
    final title = value['title'];
    final documentId = value['documentId'];
    final subjectId = value['subjectId'];
    final questions = value['questions'];

    if (sessionId is! String || title is! String || questions is! List) {
      throw const FormatException('Invalid revision quiz payload');
    }

    return DiagnosticQuizActivity(
      sessionId: sessionId,
      type: type is String ? type : 'diagnostic_quiz',
      version: version is int ? version : null,
      title: title,
      documentId: documentId is String ? documentId : null,
      subjectId: subjectId is String ? subjectId : null,
      questions: questions
          .map((question) => _DiagnosticQuizQuestionJson(question).toQuestion())
          .toList(growable: false),
    );
  }
}

class _DiagnosticQuizQuestionJson {
  const _DiagnosticQuizQuestionJson(this.value);

  final Object? value;

  DiagnosticQuizQuestion toQuestion() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final id = json['id'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final prompt = json['prompt'];
    final difficulty = json['difficulty'];
    final choices = json['choices'];
    final sources = json['sources'];
    final visuals = json['visuals'];

    if (id is! String || prompt is! String || choices is! List) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final parsedChoices = choices
        .map((choice) => _DiagnosticQuizChoiceJson(choice).toChoice())
        .toList(growable: false);
    final selectionMode = _selectionMode(json['selectionMode']);
    final minSelections = _selectionCount(json['minSelections'], fallback: 1);
    final maxSelections = _selectionCount(
      json['maxSelections'],
      fallback: selectionMode == DiagnosticQuizSelectionMode.multiple
          ? parsedChoices.length
          : 1,
    );

    if (selectionMode == DiagnosticQuizSelectionMode.multiple &&
        (minSelections < 1 ||
            maxSelections < minSelections ||
            maxSelections > parsedChoices.length)) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final parsedVisuals = <DiagnosticQuizVisual>[];
    if (visuals is List) {
      parsedVisuals.addAll([
        for (final (index, visual) in visuals.indexed)
          _DiagnosticQuizVisualJson(visual, index).toVisual(),
      ]);
      parsedVisuals.sort(
        (left, right) => left.displayOrder.compareTo(right.displayOrder),
      );
    }

    return DiagnosticQuizQuestion(
      id: id,
      knowledgeUnitId: knowledgeUnitId is String ? knowledgeUnitId : null,
      prompt: prompt,
      difficulty: difficulty is String ? difficulty : null,
      selectionMode: selectionMode,
      minSelections: selectionMode == DiagnosticQuizSelectionMode.multiple
          ? minSelections
          : 1,
      maxSelections: selectionMode == DiagnosticQuizSelectionMode.multiple
          ? maxSelections
          : 1,
      choices: parsedChoices,
      sources: sources is List
          ? sources
                .map(
                  (source) =>
                      _DiagnosticQuizSourceRefJson(source).toSourceRef(),
                )
                .toList(growable: false)
          : const [],
      visuals: parsedVisuals,
    );
  }

  DiagnosticQuizSelectionMode _selectionMode(Object? value) {
    if (value == null || value == 'single') {
      return DiagnosticQuizSelectionMode.single;
    }

    if (value == 'multiple') {
      return DiagnosticQuizSelectionMode.multiple;
    }

    throw const FormatException('Invalid revision quiz payload');
  }

  int _selectionCount(Object? value, {required int fallback}) {
    if (value == null) {
      return fallback;
    }

    if (value is int) {
      return value;
    }

    throw const FormatException('Invalid revision quiz payload');
  }
}

class _DiagnosticQuizChoiceJson {
  const _DiagnosticQuizChoiceJson(this.value);

  final Object? value;

  DiagnosticQuizChoice toChoice() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final id = json['id'];
    final label = json['label'];

    if (id is! String || label is! String) {
      throw const FormatException('Invalid revision quiz payload');
    }

    return DiagnosticQuizChoice(id: id, label: label);
  }
}

class _DiagnosticQuizVisualJson {
  const _DiagnosticQuizVisualJson(this.value, this.fallbackIndex);

  final Object? value;
  final int fallbackIndex;

  DiagnosticQuizVisual toVisual() {
    final json = value;

    if (json is! Map<String, Object?>) {
      return _unsupported('UNKNOWN');
    }

    final type = json['type'];
    if (type is! String) {
      return _unsupported('UNKNOWN', json: json);
    }

    return switch (type) {
      'CHART' => _chart(json),
      'DIAGRAM' => _diagram(json),
      _ => _unsupported(type, json: json),
    };
  }

  DiagnosticQuizVisual _chart(Map<String, Object?> json) {
    try {
      final id = _id(json);
      final displayOrder = _displayOrder(json);
      final chartType = _chartType(json['chartType']);
      final title = json['title'];
      final description = json['description'];
      final data = json['data'];
      final xKey = json['xKey'];
      final yKeys = json['yKeys'];
      final sources = json['sources'];

      if (title is! String || data is! List) {
        return _unsupported('CHART', json: json);
      }

      return DiagnosticQuizChartVisual(
        id: id,
        displayOrder: displayOrder,
        chartType: chartType,
        title: title,
        description: description is String ? description : null,
        data: data.map(_chartRow).toList(growable: false),
        xKey: xKey is String ? xKey : null,
        yKeys: yKeys is List ? _stringList(yKeys) : const [],
        sources: sources is List ? _sourceRefs(sources) : const [],
      );
    } on FormatException {
      return _unsupported('CHART', json: json);
    }
  }

  DiagnosticQuizVisual _diagram(Map<String, Object?> json) {
    try {
      final id = _id(json);
      final displayOrder = _displayOrder(json);
      final title = json['title'];
      final description = json['description'];
      final nodes = json['nodes'];
      final edges = json['edges'];
      final sources = json['sources'];

      if (title is! String || nodes is! List) {
        return _unsupported('DIAGRAM', json: json);
      }

      return DiagnosticQuizDiagramVisual(
        id: id,
        displayOrder: displayOrder,
        title: title,
        description: description is String ? description : null,
        nodes: nodes.map(_diagramNode).toList(growable: false),
        edges: edges is List
            ? edges.map(_diagramEdge).toList(growable: false)
            : const [],
        sources: sources is List ? _sourceRefs(sources) : const [],
      );
    } on FormatException {
      return _unsupported('DIAGRAM', json: json);
    }
  }

  DiagnosticQuizUnsupportedVisual _unsupported(
    String type, {
    Map<String, Object?>? json,
  }) {
    final sources = json?['sources'];

    return DiagnosticQuizUnsupportedVisual(
      id: json == null ? 'visual-$fallbackIndex' : _safeId(json),
      displayOrder: json == null ? fallbackIndex : _safeDisplayOrder(json),
      type: type,
      sources: sources is List ? _safeSourceRefs(sources) : const [],
    );
  }

  String _id(Map<String, Object?> json) {
    final id = json['id'];
    if (id is String && id.trim().isNotEmpty) {
      return id;
    }

    throw const FormatException('Invalid revision quiz payload');
  }

  String _safeId(Map<String, Object?> json) {
    final id = json['id'];
    return id is String && id.trim().isNotEmpty ? id : 'visual-$fallbackIndex';
  }

  int _displayOrder(Map<String, Object?> json) {
    final displayOrder = json['displayOrder'];
    if (displayOrder == null) {
      return fallbackIndex;
    }

    if (displayOrder is int) {
      return displayOrder;
    }

    throw const FormatException('Invalid revision quiz payload');
  }

  int _safeDisplayOrder(Map<String, Object?> json) {
    final displayOrder = json['displayOrder'];
    return displayOrder is int ? displayOrder : fallbackIndex;
  }

  DiagnosticQuizChartType _chartType(Object? value) {
    return switch (value) {
      'bar' => DiagnosticQuizChartType.bar,
      'line' => DiagnosticQuizChartType.line,
      'pie' => DiagnosticQuizChartType.pie,
      'scatter' => DiagnosticQuizChartType.scatter,
      _ => throw const FormatException('Invalid revision quiz payload'),
    };
  }

  Map<String, Object?> _chartRow(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz payload');
    }

    return json.map((key, value) {
      if (value == null || value is String || value is num) {
        return MapEntry(key, value);
      }

      throw const FormatException('Invalid revision quiz payload');
    });
  }

  DiagnosticQuizDiagramNode _diagramNode(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final id = json['id'];
    final label = json['label'];
    if (id is! String || label is! String) {
      throw const FormatException('Invalid revision quiz payload');
    }

    return DiagnosticQuizDiagramNode(id: id, label: label);
  }

  DiagnosticQuizDiagramEdge _diagramEdge(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final from = json['from'];
    final to = json['to'];
    final label = json['label'];
    if (from is! String || to is! String) {
      throw const FormatException('Invalid revision quiz payload');
    }

    return DiagnosticQuizDiagramEdge(
      from: from,
      to: to,
      label: label is String ? label : null,
    );
  }

  List<String> _stringList(List<Object?> values) {
    return values
        .map((value) {
          if (value is String) {
            return value;
          }

          throw const FormatException('Invalid revision quiz payload');
        })
        .toList(growable: false);
  }

  List<DiagnosticQuizSourceRef> _sourceRefs(List<Object?> values) {
    return values
        .map((source) => _DiagnosticQuizSourceRefJson(source).toSourceRef())
        .toList(growable: false);
  }

  List<DiagnosticQuizSourceRef> _safeSourceRefs(List<Object?> values) {
    try {
      return _sourceRefs(values);
    } on FormatException {
      return const [];
    }
  }
}

class _DiagnosticQuizSourceRefJson {
  const _DiagnosticQuizSourceRefJson(this.value);

  final Object? value;

  DiagnosticQuizSourceRef toSourceRef() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz source payload');
    }

    final chunkId = json['chunkId'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || index is! int) {
      throw const FormatException('Invalid revision quiz source payload');
    }

    return DiagnosticQuizSourceRef(
      chunkId: chunkId,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

class _OpenQuestionActivityJson {
  const _OpenQuestionActivityJson(this.value);

  final Map<String, Object?> value;

  OpenQuestionActivity toActivity() {
    final sessionId = value['sessionId'];
    final type = value['type'];
    final version = value['version'];
    final subjectId = value['subjectId'];
    final documentId = value['documentId'];
    final knowledgeUnitId = value['knowledgeUnitId'];
    final question = value['question'];

    if (sessionId is! String ||
        type != 'open_question' ||
        subjectId is! String ||
        knowledgeUnitId is! String ||
        question is! Map<String, Object?>) {
      throw const FormatException('Invalid revision open question payload');
    }

    return OpenQuestionActivity(
      sessionId: sessionId,
      type: type as String,
      version: version is int ? version : null,
      subjectId: subjectId,
      documentId: documentId is String ? documentId : null,
      knowledgeUnitId: knowledgeUnitId,
      question: _OpenQuestionJson(question).toQuestion(),
    );
  }
}

class _OpenQuestionJson {
  const _OpenQuestionJson(this.value);

  final Map<String, Object?> value;

  OpenQuestion toQuestion() {
    final id = value['id'];
    final prompt = value['prompt'];
    final instructions = value['instructions'];
    final maxAnswerLength = value['maxAnswerLength'];
    final sources = value['sources'];

    if (id is! String || prompt is! String || maxAnswerLength is! int) {
      throw const FormatException('Invalid revision open question payload');
    }

    return OpenQuestion(
      id: id,
      prompt: prompt,
      instructions: instructions is String ? instructions : null,
      maxAnswerLength: maxAnswerLength,
      sources: sources is List
          ? sources
                .map((source) => _OpenQuestionSourceJson(source).toSource())
                .toList(growable: false)
          : const [],
    );
  }
}

class _OpenQuestionSourceJson {
  const _OpenQuestionSourceJson(this.value);

  final Object? value;

  OpenQuestionSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException(
        'Invalid revision open question source payload',
      );
    }

    final chunkId = json['chunkId'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || index is! int) {
      throw const FormatException(
        'Invalid revision open question source payload',
      );
    }

    return OpenQuestionSource(
      chunkId: chunkId,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

```

### lib/features/revision_sessions/domain/revision_session.dart

```dart
import '../../activities/domain/diagnostic_quiz_activity.dart';
import '../../activities/domain/open_question_activity.dart';

class RevisionSession {
  const RevisionSession({
    required this.id,
    required this.status,
    required this.subjectId,
    required this.courseId,
    required this.documentId,
    required this.knowledgeUnitId,
    required this.createdAt,
    required this.completedAt,
  });

  final String id;
  final RevisionSessionStatus status;
  final String subjectId;
  final String? courseId;
  final String? documentId;
  final String? knowledgeUnitId;
  final DateTime createdAt;
  final DateTime? completedAt;
}

enum RevisionSessionStatus { started, completed, abandoned, unknown }

class RevisionSessionAction {
  const RevisionSessionAction({
    required this.id,
    required this.kind,
    required this.status,
    required this.displayOrder,
    required this.activitySessionId,
    required this.documentId,
    required this.knowledgeUnitId,
    required this.payload,
  });

  final String id;
  final RevisionSessionActionKind kind;
  final RevisionSessionActionStatus status;
  final int displayOrder;
  final String? activitySessionId;
  final String? documentId;
  final String? knowledgeUnitId;
  final RevisionSessionActionPayload? payload;
}

enum RevisionSessionActionKind {
  diagnosticQuiz,
  openQuestion,
  richClosedExercise,
  unknown,
}

enum RevisionSessionActionStatus { ready, completed, failed, unknown }

class RevisionSessionResponse {
  const RevisionSessionResponse({
    required this.session,
    required this.currentAction,
    required this.history,
  });

  final RevisionSession session;
  final RevisionSessionAction? currentAction;
  final List<RevisionSessionAction> history;
}

sealed class RevisionSessionActionPayload {
  const RevisionSessionActionPayload();
}

class RevisionSessionDiagnosticQuizPayload
    extends RevisionSessionActionPayload {
  const RevisionSessionDiagnosticQuizPayload(this.activity);

  final DiagnosticQuizActivity activity;
}

class RevisionSessionOpenQuestionPayload extends RevisionSessionActionPayload {
  const RevisionSessionOpenQuestionPayload(this.activity);

  final OpenQuestionActivity activity;
}

class RevisionSessionRichClosedExercisePayload
    extends RevisionSessionActionPayload {
  const RevisionSessionRichClosedExercisePayload({
    required this.subjectId,
    required this.knowledgeUnitId,
    required this.reason,
    required this.estimatedMinutes,
    this.documentId,
    this.knowledgeUnitTitle,
    this.preferredAction,
  });

  final String subjectId;
  final String? documentId;
  final String knowledgeUnitId;
  final String? knowledgeUnitTitle;
  final String reason;
  final int estimatedMinutes;
  final String? preferredAction;
}

class RevisionSessionMinimalPayload extends RevisionSessionActionPayload {
  const RevisionSessionMinimalPayload({required this.type, this.sessionId});

  final String type;
  final String? sessionId;
}

class RevisionSessionUnknownPayload extends RevisionSessionActionPayload {
  const RevisionSessionUnknownPayload();
}

```

### lib/presentation/design_system/components/revision_mvp_components.dart

```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/revision_colors.dart';
import '../tokens/revision_radius.dart';
import '../tokens/revision_shadows.dart';
import '../tokens/revision_spacing.dart';
import '../tokens/revision_typography.dart';

class RevisionPageScaffold extends StatelessWidget {
  const RevisionPageScaffold({
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(
      RevisionSpacing.pageX,
      RevisionSpacing.pageTop,
      RevisionSpacing.pageX,
      110,
    ),
    this.maxWidth = 520,
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: padding,
              sliver: SliverList.list(
                children: [
                  for (final child in children) ...[
                    child,
                    if (child != children.last)
                      const SizedBox(height: RevisionSpacing.l),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RevisionGlassCard extends StatelessWidget {
  const RevisionGlassCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(RevisionSpacing.l),
    this.radius = RevisionRadius.radiusL,
    this.borderColor,
    this.backgroundColor,
    this.gradient,
    this.selected = false,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final BorderRadius radius;
  final Color? borderColor;
  final Color? backgroundColor;
  final Gradient? gradient;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null
            ? backgroundColor ?? RevisionColors.glassSoft
            : null,
        gradient: gradient,
        borderRadius: radius,
        border: Border.all(
          color:
              borderColor ??
              (selected ? RevisionColors.blue : RevisionColors.border),
          width: selected ? 1.4 : 1,
        ),
        boxShadow: selected
            ? RevisionShadows.soft(RevisionColors.blue)
            : RevisionShadows.glass,
      ),
      child: child,
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: radius, onTap: onTap, child: content),
    );
  }
}

class RevisionGradientButton extends StatelessWidget {
  const RevisionGradientButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.expanded = false,
    this.gradient,
    this.foreground = RevisionColors.text,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expanded;
  final Gradient? gradient;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final button = Opacity(
      opacity: enabled ? 1 : 0.55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient:
              gradient ??
              const LinearGradient(
                colors: [RevisionColors.blue, RevisionColors.blueDeep],
              ),
          borderRadius: RevisionRadius.pill,
          boxShadow: RevisionShadows.soft(RevisionColors.blue),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RevisionSpacing.xl,
            vertical: RevisionSpacing.m,
          ),
          child: Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: foreground, size: 19),
                const SizedBox(width: RevisionSpacing.s),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RevisionColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: expanded
            ? SizedBox(width: double.infinity, child: button)
            : button,
      ),
    );
  }
}

class RevisionIconTile extends StatelessWidget {
  const RevisionIconTile({
    required this.icon,
    required this.accent,
    this.size = 52,
    this.iconSize = 28,
    super.key,
  });

  final IconData icon;
  final Color accent;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.95),
            accent.withValues(alpha: 0.35),
          ],
        ),
        borderRadius: RevisionRadius.radiusM,
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: RevisionShadows.soft(accent),
      ),
      child: Icon(icon, color: RevisionColors.text, size: iconSize),
    );
  }
}

class RevisionSubjectSwitcher extends StatelessWidget {
  const RevisionSubjectSwitcher({
    required this.label,
    required this.accent,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String label;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Changer de matiere',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 40, maxWidth: 190),
          padding: const EdgeInsets.symmetric(
            horizontal: RevisionSpacing.m,
            vertical: RevisionSpacing.s,
          ),
          decoration: BoxDecoration(
            color: RevisionColors.glassSoft,
            borderRadius: RevisionRadius.pill,
            border: Border.all(color: accent, width: 1.4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RevisionIconTile(
                icon: icon,
                accent: accent,
                size: 24,
                iconSize: 15,
              ),
              const SizedBox(width: RevisionSpacing.s),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RevisionColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: RevisionSpacing.xs),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: RevisionColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RevisionTopCounters extends StatelessWidget {
  const RevisionTopCounters({this.streakLabel, this.gemsLabel, super.key});

  final String? streakLabel;
  final String? gemsLabel;

  @override
  Widget build(BuildContext context) {
    final counters = <Widget>[
      if (streakLabel != null)
        _CounterPill(
          icon: Icons.local_fire_department_rounded,
          label: streakLabel!,
        ),
      if (gemsLabel != null)
        _CounterPill(
          icon: Icons.diamond_rounded,
          label: gemsLabel!,
          accent: RevisionColors.cyan,
        ),
    ];

    if (counters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, counter) in counters.indexed) ...[
          if (index > 0) const SizedBox(width: RevisionSpacing.s),
          counter,
        ],
      ],
    );
  }
}

class _CounterPill extends StatelessWidget {
  const _CounterPill({
    required this.icon,
    required this.label,
    this.accent = RevisionColors.amber,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RevisionSpacing.s,
        vertical: RevisionSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: RevisionColors.glassSoft,
        borderRadius: RevisionRadius.pill,
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(width: RevisionSpacing.xs),
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class RevisionProgressLine extends StatelessWidget {
  const RevisionProgressLine({
    required this.value,
    this.color = RevisionColors.blue,
    this.height = 5,
    super.key,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 1).toDouble();

    return ClipRRect(
      borderRadius: RevisionRadius.pill,
      child: LinearProgressIndicator(
        value: clamped,
        minHeight: height,
        color: color,
        backgroundColor: RevisionColors.border.withValues(alpha: 0.72),
      ),
    );
  }
}

class RevisionMasteryRing extends StatelessWidget {
  const RevisionMasteryRing({
    required this.value,
    required this.label,
    this.size = 82,
    this.color = RevisionColors.green,
    this.caption,
    super.key,
  });

  final double value;
  final String label;
  final String? caption;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: size,
            child: CircularProgressIndicator(
              value: value.clamp(0, 1).toDouble(),
              strokeWidth: 7,
              strokeCap: StrokeCap.round,
              color: color,
              backgroundColor: RevisionColors.border,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: RevisionColors.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 0,
                ),
              ),
              if (caption != null)
                Text(
                  caption!,
                  textAlign: TextAlign.center,
                  style: RevisionTypography.caption.copyWith(
                    color: RevisionColors.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class RevisionResumeCourseCard extends StatelessWidget {
  const RevisionResumeCourseCard({
    required this.title,
    required this.subtitle,
    required this.progressLabel,
    required this.progress,
    required this.accent,
    required this.icon,
    required this.onContinue,
    super.key,
  });

  final String title;
  final String subtitle;
  final String progressLabel;
  final double progress;
  final Color accent;
  final IconData icon;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.m),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [accent.withValues(alpha: 0.92), RevisionColors.blueDeep],
      ),
      borderColor: Colors.white.withValues(alpha: 0.14),
      child: Row(
        children: [
          RevisionIconTile(
            icon: Icons.play_arrow_rounded,
            accent: RevisionColors.cyan,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: RevisionTypography.caption.copyWith(
                    color: RevisionColors.text.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(title, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.m),
                Row(
                  children: [
                    Expanded(
                      child: RevisionProgressLine(
                        value: progress,
                        color: RevisionColors.cyan,
                      ),
                    ),
                    const SizedBox(width: RevisionSpacing.s),
                    Text(
                      progressLabel,
                      style: RevisionTypography.caption.copyWith(
                        color: RevisionColors.text,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: RevisionSpacing.s),
          TextButton(
            onPressed: onContinue,
            style: TextButton.styleFrom(
              backgroundColor: RevisionColors.text,
              foregroundColor: RevisionColors.blueDeep,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(
                horizontal: RevisionSpacing.m,
                vertical: RevisionSpacing.s,
              ),
            ),
            child: const Text(
              'Continuer',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class RevisionCourseCard extends StatelessWidget {
  const RevisionCourseCard({
    required this.title,
    required this.progressLabel,
    required this.durationLabel,
    required this.progress,
    required this.accent,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String title;
  final String progressLabel;
  final String durationLabel;
  final double progress;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      child: Row(
        children: [
          RevisionIconTile(icon: icon, accent: accent, size: 48, iconSize: 27),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.s),
                Row(
                  children: [
                    Text(
                      progressLabel,
                      style: RevisionTypography.caption.copyWith(color: accent),
                    ),
                    const SizedBox(width: RevisionSpacing.m),
                    Expanded(
                      child: RevisionProgressLine(
                        value: progress,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: RevisionSpacing.m),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: RevisionColors.textMuted,
                size: 15,
              ),
              const SizedBox(width: RevisionSpacing.xs),
              Text(durationLabel, style: RevisionTypography.caption),
            ],
          ),
          const SizedBox(width: RevisionSpacing.s),
          const Icon(
            Icons.chevron_right_rounded,
            color: RevisionColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class RevisionModeCard extends StatelessWidget {
  const RevisionModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [accent.withValues(alpha: 0.78), RevisionColors.glassStrong],
      ),
      borderColor: accent.withValues(alpha: 0.30),
      child: Row(
        children: [
          RevisionIconTile(icon: icon, accent: accent, size: 48),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.xs),
                Text(description, style: RevisionTypography.body),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: RevisionColors.text),
        ],
      ),
    );
  }
}

class RevisionSourceFileCard extends StatelessWidget {
  const RevisionSourceFileCard({
    required this.fileName,
    required this.sizeLabel,
    required this.statusLabel,
    this.onTap,
    super.key,
  });

  final String fileName;
  final String sizeLabel;
  final String statusLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      child: Row(
        children: [
          const RevisionIconTile(
            icon: Icons.picture_as_pdf_rounded,
            accent: RevisionColors.red,
            size: 42,
            iconSize: 23,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: RevisionTypography.sectionTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(
                  '$sizeLabel · $statusLabel',
                  style: RevisionTypography.caption,
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert_rounded, color: RevisionColors.textMuted),
        ],
      ),
    );
  }
}

class RevisionSegmentedControl<T> extends StatelessWidget {
  const RevisionSegmentedControl({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    super.key,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.xxs),
      radius: RevisionRadius.radiusM,
      child: Row(
        children: [
          for (final value in values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    vertical: RevisionSpacing.s,
                  ),
                  decoration: BoxDecoration(
                    gradient: value == selected
                        ? const LinearGradient(
                            colors: [
                              RevisionColors.blue,
                              RevisionColors.blueDeep,
                            ],
                          )
                        : null,
                    borderRadius: RevisionRadius.radiusS,
                  ),
                  child: Text(
                    labelOf(value),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: value == selected
                          ? RevisionColors.text
                          : RevisionColors.textMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RevisionStatTriplet extends StatelessWidget {
  const RevisionStatTriplet({required this.items, super.key});

  final List<RevisionStatItem> items;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            Expanded(child: _StatItemView(item: items[index])),
            if (index != items.length - 1)
              Container(width: 1, height: 44, color: RevisionColors.border),
          ],
        ],
      ),
    );
  }
}

class RevisionStatItem {
  const RevisionStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}

class _StatItemView extends StatelessWidget {
  const _StatItemView({required this.item});

  final RevisionStatItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(item.icon, color: item.color, size: 20),
        const SizedBox(height: RevisionSpacing.xs),
        Text(item.label, style: RevisionTypography.caption),
        const SizedBox(height: RevisionSpacing.xs),
        Text(
          item.value,
          textAlign: TextAlign.center,
          style: RevisionTypography.sectionTitle.copyWith(
            color: item.color,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class RevisionSectionHeader extends StatelessWidget {
  const RevisionSectionHeader({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: RevisionTypography.sectionTitle),
        if (subtitle != null) ...[
          const SizedBox(height: RevisionSpacing.xs),
          Text(subtitle!, style: RevisionTypography.body),
        ],
      ],
    );
  }
}

class RevisionFloatingAddButton extends StatelessWidget {
  const RevisionFloatingAddButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ajouter une source',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [RevisionColors.pink, RevisionColors.pinkDeep],
            ),
            border: Border.all(
              color: RevisionColors.pink.withValues(alpha: 0.55),
              width: 6,
            ),
            boxShadow: RevisionShadows.soft(RevisionColors.pink),
          ),
          child: const Icon(
            Icons.add_rounded,
            color: RevisionColors.text,
            size: 38,
          ),
        ),
      ),
    );
  }
}

class RevisionConfettiStrip extends StatelessWidget {
  const RevisionConfettiStrip({super.key});

  @override
  Widget build(BuildContext context) {
    const colors = [
      RevisionColors.blue,
      RevisionColors.green,
      RevisionColors.pink,
      RevisionColors.amber,
      RevisionColors.violet,
      RevisionColors.mint,
    ];

    return SizedBox(
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var index = 0; index < 18; index++)
            Transform.rotate(
              angle: (index % 5 - 2) * math.pi / 8,
              child: Container(
                width: index.isEven ? 4 : 3,
                height: index.isEven ? 8 : 6,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: RevisionRadius.radiusS,
                ),
              ),
            ),
        ],
      ),
    );
  }
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
  final Map<String, RevisionSheet?> revisionSheetsByCourse = {};
  final Map<String, RevisionSheet> generatedRevisionSheetsByCourse = {};
  final Map<String, Object> revisionSheetErrorsByCourse = {};
  int createCount = 0;
  int getCourseCount = 0;
  int getRevisionSheetCount = 0;
  int generateRevisionSheetCount = 0;
  int uploadCount = 0;
  int startQuickRevisionCount = 0;
  String? lastUploadedCourseId;
  String? lastUploadedFileName;
  Uint8List? lastUploadedBytes;
  String? lastQuickRevisionCourseId;
  Object? uploadError;
  Object? quickRevisionError;
  RevisionSessionResponse? quickRevisionResponse;
  Duration uploadDelay = Duration.zero;
  Duration quickRevisionDelay = Duration.zero;

  @override
  Future<List<CourseListItem>> listCourses({required String subjectId}) async {
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
    throw UnimplementedError('Progression course réelle hors CORE-02');
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

### test/fakes/in_memory_revision_sessions_api.dart

```dart
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:revision_app/features/revision_sessions/domain/revision_session.dart';

class InMemoryRevisionSessionsApi implements RevisionSessionsApi {
  String? startedSubjectId;
  String? startedDocumentId;
  String? startedKnowledgeUnitId;
  RevisionSessionPreferredAction? startedPreferredAction;
  String? loadedSessionId;
  int startCount = 0;
  int loadCount = 0;
  Object? startError;
  Object? loadError;
  RevisionSessionResponse startResponse = openQuestionRevisionSessionResponse();
  RevisionSessionResponse loadResponse = minimalRevisionSessionResponse();

  @override
  Future<RevisionSessionResponse> startRevisionSession({
    required String subjectId,
    String? documentId,
    String? knowledgeUnitId,
    RevisionSessionPreferredAction? preferredAction,
  }) async {
    startCount += 1;
    startedSubjectId = subjectId;
    startedDocumentId = documentId;
    startedKnowledgeUnitId = knowledgeUnitId;
    startedPreferredAction = preferredAction;
    final error = startError;
    if (error != null) {
      throw error;
    }
    return startResponse;
  }

  @override
  Future<RevisionSessionResponse> getRevisionSession({
    required String sessionId,
  }) async {
    loadCount += 1;
    loadedSessionId = sessionId;
    final error = loadError;
    if (error != null) {
      throw error;
    }
    return loadResponse;
  }
}

RevisionSessionResponse diagnosticQuizRevisionSessionResponse() {
  return RevisionSessionResponse(
    session: revisionSession(),
    currentAction: RevisionSessionAction(
      id: 'action-quiz-1',
      kind: RevisionSessionActionKind.diagnosticQuiz,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'quiz-session-1',
      documentId: null,
      knowledgeUnitId: null,
      payload: const RevisionSessionDiagnosticQuizPayload(
        DiagnosticQuizActivity(
          sessionId: 'quiz-session-1',
          title: 'QCM de session',
          subjectId: 'subject-1',
          questions: [
            DiagnosticQuizQuestion(
              id: 'question-1',
              prompt: 'Question test',
              choices: [
                DiagnosticQuizChoice(id: 'choice-1', label: 'Réponse A'),
                DiagnosticQuizChoice(id: 'choice-2', label: 'Réponse B'),
              ],
            ),
          ],
        ),
      ),
    ),
    history: [
      RevisionSessionAction(
        id: 'action-quiz-1',
        kind: RevisionSessionActionKind.diagnosticQuiz,
        status: RevisionSessionActionStatus.ready,
        displayOrder: 0,
        activitySessionId: 'quiz-session-1',
        documentId: null,
        knowledgeUnitId: null,
        payload: null,
      ),
    ],
  );
}

RevisionSessionResponse openQuestionRevisionSessionResponse() {
  return RevisionSessionResponse(
    session: revisionSession(knowledgeUnitId: 'unit-1'),
    currentAction: RevisionSessionAction(
      id: 'action-open-1',
      kind: RevisionSessionActionKind.openQuestion,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'open-session-1',
      documentId: null,
      knowledgeUnitId: 'unit-1',
      payload: const RevisionSessionOpenQuestionPayload(
        OpenQuestionActivity(
          sessionId: 'open-session-1',
          type: 'open_question',
          version: 1,
          subjectId: 'subject-1',
          documentId: null,
          knowledgeUnitId: 'unit-1',
          question: OpenQuestion(
            id: 'open-question-1',
            prompt: 'Question ouverte test',
            instructions: 'Réponds en quelques phrases.',
            maxAnswerLength: 4000,
          ),
        ),
      ),
    ),
    history: [
      RevisionSessionAction(
        id: 'action-open-1',
        kind: RevisionSessionActionKind.openQuestion,
        status: RevisionSessionActionStatus.ready,
        displayOrder: 0,
        activitySessionId: 'open-session-1',
        documentId: null,
        knowledgeUnitId: 'unit-1',
        payload: null,
      ),
    ],
  );
}

RevisionSessionResponse richClosedRevisionSessionResponse() {
  return RevisionSessionResponse(
    session: revisionSession(knowledgeUnitId: 'unit-1'),
    currentAction: const RevisionSessionAction(
      id: 'action-rich-1',
      kind: RevisionSessionActionKind.richClosedExercise,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: null,
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      payload: RevisionSessionRichClosedExercisePayload(
        subjectId: 'subject-1',
        documentId: 'document-1',
        knowledgeUnitId: 'unit-1',
        knowledgeUnitTitle: 'Institutions politiques',
        reason: 'Questions riches recommandées.',
        estimatedMinutes: 8,
        preferredAction: 'rich_closed_exercise',
      ),
    ),
    history: const [
      RevisionSessionAction(
        id: 'action-rich-1',
        kind: RevisionSessionActionKind.richClosedExercise,
        status: RevisionSessionActionStatus.ready,
        displayOrder: 0,
        activitySessionId: null,
        documentId: 'document-1',
        knowledgeUnitId: 'unit-1',
        payload: null,
      ),
    ],
  );
}

RevisionSessionResponse minimalRevisionSessionResponse() {
  return RevisionSessionResponse(
    session: revisionSession(),
    currentAction: const RevisionSessionAction(
      id: 'action-minimal-1',
      kind: RevisionSessionActionKind.openQuestion,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'open-session-1',
      documentId: null,
      knowledgeUnitId: 'unit-1',
      payload: RevisionSessionMinimalPayload(
        type: 'open_question',
        sessionId: 'open-session-1',
      ),
    ),
    history: const [
      RevisionSessionAction(
        id: 'action-minimal-1',
        kind: RevisionSessionActionKind.openQuestion,
        status: RevisionSessionActionStatus.ready,
        displayOrder: 0,
        activitySessionId: 'open-session-1',
        documentId: null,
        knowledgeUnitId: 'unit-1',
        payload: null,
      ),
    ],
  );
}

RevisionSession revisionSession({String? knowledgeUnitId}) {
  return RevisionSession(
    id: 'revision-session-1',
    status: RevisionSessionStatus.started,
    subjectId: 'subject-1',
    courseId: null,
    documentId: null,
    knowledgeUnitId: knowledgeUnitId,
    createdAt: DateTime.parse('2026-06-15T12:00:00.000Z'),
    completedAt: null,
  );
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

    await tester.tap(find.text('Ajouter une source'));
    await tester.pump();

    expect(find.text('Upload en cours...'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(repository.uploadCount, 1);
    expect(repository.lastUploadedCourseId, 'course-1');
    expect(repository.lastUploadedFileName, 'cours.pdf');
    expect(find.text('Source ajoutée'), findsOneWidget);
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

    expect(find.text('broken.pdf'), findsOneWidget);
    expect(find.text('Erreur'), findsOneWidget);
    expect(find.textContaining('PDF_PARSE_FAILED'), findsOneWidget);
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
    await tester.pumpAndSettle();

    expect(repository.getCourseCount, 1);
    expect(find.text('Traitement en cours'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(repository.getCourseCount, greaterThanOrEqualTo(2));
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

    await tester.tap(find.text('Révision rapide'));
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

class FakeCoursePdfPicker implements CoursePdfPicker {
  FakeCoursePdfPicker(this.result);

  final PickedCoursePdf? result;

  @override
  Future<PickedCoursePdf?> pickPdf() async => result;
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
      final repository = InMemoryCoursesRepository();
      final picker = FakeCoursePdfPicker(null);
      final container = ProviderContainer(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(repository),
          coursePdfPickerProvider.overrideWithValue(picker),
        ],
      );
      addTearDown(container.dispose);

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
    },
  );

  test(
    'uploadCourseDocumentController uploads and invalidates course detail',
    () async {
      final repository = InMemoryCoursesRepository()
        ..detailsByCourse['course-1'] = courseDetail();
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
    },
  );

  test('uploadCourseDocumentController exposes upload errors', () async {
    final repository = InMemoryCoursesRepository()
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
  });

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

CourseDetail courseDetail() {
  const course = CourseListItem(
    id: 'course-1',
    subjectId: 'subject-1',
    title: 'Droit constitutionnel',
  );
  return const CourseDetail(
    course: course,
    subject: CourseSubjectSummary(id: 'subject-1', name: 'Droit'),
    sources: [],
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

### test/features/courses/http_courses_repository_test.dart

```dart
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

```

### test/features/revision_sessions/http_revision_sessions_api_test.dart

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/revision_sessions/data/http_revision_sessions_api.dart';
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:revision_app/features/revision_sessions/domain/revision_session.dart';

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
  test('starts a revision session with preferred action payload', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: diagnosticQuizPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.startRevisionSession(
      subjectId: 'subject-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      preferredAction: RevisionSessionPreferredAction.openQuestion,
    );

    expect(adapter.lastOptions?.path, '/revision-sessions');
    expect(adapter.lastOptions?.data, {
      'subjectId': 'subject-1',
      'documentId': 'document-1',
      'knowledgeUnitId': 'unit-1',
      'preferredAction': 'open_question',
    });
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
    expect(response.session.id, 'revision-session-1');
    expect(
      response.currentAction?.kind,
      RevisionSessionActionKind.diagnosticQuiz,
    );
    expect(
      response.currentAction?.payload,
      isA<RevisionSessionDiagnosticQuizPayload>(),
    );
  });

  test('parses courseId for course-level revision sessions', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(
        revisionSessionJson(
          payload: diagnosticQuizPayloadJson(),
          courseId: 'course-1',
        ),
      ),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.getRevisionSession(
      sessionId: 'revision-session-1',
    );

    expect(response.session.courseId, 'course-1');
  });

  test('starts and parses a rich closed launcher payload', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: richClosedPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.startRevisionSession(
      subjectId: 'subject-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      preferredAction: RevisionSessionPreferredAction.richClosedExercise,
    );

    expect(adapter.lastOptions?.data, {
      'subjectId': 'subject-1',
      'documentId': 'document-1',
      'knowledgeUnitId': 'unit-1',
      'preferredAction': 'rich_closed_exercise',
    });
    expect(
      response.currentAction?.kind,
      RevisionSessionActionKind.richClosedExercise,
    );
    expect(response.currentAction?.activitySessionId, isNull);
    final payload = response.currentAction?.payload;
    expect(payload, isA<RevisionSessionRichClosedExercisePayload>());
    final launcher = payload as RevisionSessionRichClosedExercisePayload;
    expect(launcher.subjectId, 'subject-1');
    expect(launcher.documentId, 'document-1');
    expect(launcher.knowledgeUnitId, 'unit-1');
    expect(launcher.knowledgeUnitTitle, 'Institutions politiques');
    expect(launcher.estimatedMinutes, 8);
  });

  test('omits null fields from start request', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: diagnosticQuizPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await api.startRevisionSession(subjectId: 'subject-1');

    expect(adapter.lastOptions?.data, {'subjectId': 'subject-1'});
  });

  test('gets a revision session with minimal payload', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: minimalPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.getRevisionSession(
      sessionId: 'revision-session-1',
    );

    expect(adapter.lastOptions?.path, '/revision-sessions/revision-session-1');
    final payload = response.currentAction?.payload;
    expect(payload, isA<RevisionSessionMinimalPayload>());
    expect((payload as RevisionSessionMinimalPayload).type, 'open_question');
    expect(payload.sessionId, 'open-session-1');
  });

  test(
    'parses an open question full payload without correction leaks',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(revisionSessionJson(payload: openQuestionPayloadJson())),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpRevisionSessionsApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      final response = await api.startRevisionSession(
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      );

      final payload = response.currentAction?.payload;
      expect(payload, isA<RevisionSessionOpenQuestionPayload>());
      final activity = (payload as RevisionSessionOpenQuestionPayload).activity;
      expect(activity.question.prompt, 'Explique la séparation des pouvoirs.');
      expect(activity.question.sources.single.chunkId, 'chunk-1');
    },
  );

  test('parses currentAction null and history', () async {
    final json = revisionSessionJson(payload: null)..['currentAction'] = null;
    final adapter = CapturingHttpClientAdapter(jsonResponse(json));
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.getRevisionSession(
      sessionId: 'revision-session-1',
    );

    expect(response.currentAction, isNull);
    expect(response.history, hasLength(1));
    expect(
      response.history.single.kind,
      RevisionSessionActionKind.openQuestion,
    );
  });

  test('rejects rich closed payloads that contain exercise content', () async {
    final payload = richClosedPayloadJson()
      ..['questions'] = [
        {'id': 'question-1'},
      ]
      ..['correction'] = {'correctChoiceId': 'choice-1'};
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: payload)),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.getRevisionSession(
      sessionId: 'revision-session-1',
    );

    expect(
      response.currentAction?.payload,
      isA<RevisionSessionUnknownPayload>(),
    );
  });

  test('refuses an empty token before network call', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: minimalPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(dio: dio, getIdToken: () async => ' ');

    await expectLater(
      api.getRevisionSession(sessionId: 'revision-session-1'),
      throwsStateError,
    );
    expect(adapter.fetchCallCount, 0);
  });

  test('rejects invalid revision session responses', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({'session': null, 'currentAction': null, 'history': []}),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      api.getRevisionSession(sessionId: 'revision-session-1'),
      throwsFormatException,
    );
  });
}

ResponseBody jsonResponse(Object? payload) {
  return ResponseBody.fromString(
    jsonEncode(payload),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Map<String, Object?> revisionSessionJson({
  required Object? payload,
  String? courseId,
}) {
  final actionKind = payload == null ? 'OPEN_QUESTION' : actionKindFor(payload);
  final isRichClosed = actionKind == 'RICH_CLOSED_EXERCISE';

  return {
    'session': {
      'id': 'revision-session-1',
      'status': 'STARTED',
      'subjectId': 'subject-1',
      'courseId': courseId,
      'documentId': null,
      'knowledgeUnitId': 'unit-1',
      'createdAt': '2026-06-15T12:00:00.000Z',
      'completedAt': null,
    },
    'currentAction': {
      'id': 'action-1',
      'kind': actionKind,
      'status': 'READY',
      'displayOrder': 0,
      'activitySessionId': isRichClosed ? null : 'activity-session-1',
      'documentId': null,
      'knowledgeUnitId': 'unit-1',
      'payload': payload,
    },
    'history': [
      {
        'id': 'action-1',
        'kind': actionKind,
        'status': 'READY',
        'displayOrder': 0,
        'activitySessionId': isRichClosed ? null : 'activity-session-1',
        'documentId': null,
        'knowledgeUnitId': 'unit-1',
      },
    ],
  };
}

String actionKindFor(Object payload) {
  if (payload is Map && payload['type'] == 'diagnostic_quiz') {
    return 'DIAGNOSTIC_QUIZ';
  }
  if (payload is Map && payload['type'] == 'rich_closed_exercise') {
    return 'RICH_CLOSED_EXERCISE';
  }
  return 'OPEN_QUESTION';
}

Map<String, Object?> minimalPayloadJson() {
  return {'type': 'open_question', 'sessionId': 'open-session-1'};
}

Map<String, Object?> diagnosticQuizPayloadJson() {
  return {
    'sessionId': 'quiz-session-1',
    'type': 'diagnostic_quiz',
    'version': 3,
    'title': 'QCM de session',
    'documentId': null,
    'subjectId': 'subject-1',
    'questions': [
      {
        'id': 'question-1',
        'knowledgeUnitId': 'unit-1',
        'prompt': 'Question test',
        'difficulty': 'MEDIUM',
        'correctChoiceId': 'choice-1',
        'explanation': 'Ne doit pas être mappé.',
        'sources': [
          {
            'chunkId': 'chunk-1',
            'pageNumber': null,
            'index': 0,
            'text': 'Texte source complet interdit.',
          },
        ],
        'choices': [
          {'id': 'choice-1', 'label': 'Réponse A', 'feedback': 'Interdit'},
          {'id': 'choice-2', 'label': 'Réponse B'},
        ],
      },
    ],
  };
}

Map<String, Object?> openQuestionPayloadJson() {
  return {
    'sessionId': 'open-session-1',
    'type': 'open_question',
    'version': 1,
    'subjectId': 'subject-1',
    'documentId': null,
    'knowledgeUnitId': 'unit-1',
    'score': 20,
    'feedback': 'Interdit avant submit.',
    'modelAnswer': 'Interdit avant submit.',
    'question': {
      'id': 'open-question-1',
      'prompt': 'Explique la séparation des pouvoirs.',
      'instructions': 'Réponds en quelques phrases.',
      'maxAnswerLength': 4000,
      'sources': [
        {
          'chunkId': 'chunk-1',
          'pageNumber': null,
          'index': 0,
          'text': 'Texte source complet interdit.',
        },
      ],
    },
  };
}

Map<String, Object?> richClosedPayloadJson() {
  return {
    'type': 'rich_closed_exercise',
    'subjectId': 'subject-1',
    'documentId': 'document-1',
    'knowledgeUnitId': 'unit-1',
    'knowledgeUnitTitle': 'Institutions politiques',
    'reason': 'Questions riches recommandées.',
    'estimatedMinutes': 8,
    'preferredAction': 'rich_closed_exercise',
  };
}

```
