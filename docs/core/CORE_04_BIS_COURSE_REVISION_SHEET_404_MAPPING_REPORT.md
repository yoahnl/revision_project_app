# CORE-04-bis — Correction mapping 404 course-level revision sheet

## Résumé

CORE-04 était fonctionnel, mais le front confondait deux réponses `404` de `GET /courses/:courseId/revision-sheet` :

- `Course not found` : le cours n'existe pas ou n'appartient pas à l'utilisateur.
- `Revision sheet not found` : le cours existe, une source `READY` existe, mais aucune fiche n'a encore été générée.

Le correctif est limité à Flutter. Le backend a été audité en lecture seule et expose déjà des messages stables qui permettent cette distinction.

## Cause du problème

Dans `HttpCoursesRepository.getCourseRevisionSheet`, tout `404` retournait `null`. La page interprétait donc un cours introuvable comme une fiche simplement non générée, ce qui pouvait afficher `Fiche non générée` sur `/courses/unknown/sheet`.

## Audit backend

Backend inspecté sans modification :

- `src/modules/courses/interfaces/courses.controller.ts`
- `src/modules/courses/application/course-revision-sheet.use-case.ts`
- `src/modules/courses/interfaces/courses.controller.spec.ts`
- `test/critical-paths.e2e-spec.ts`

Constats :

- `GET /courses/:courseId/revision-sheet` renvoie `NotFoundException('Revision sheet not found')` quand la fiche n'existe pas encore.
- Les erreurs métier `Course not found` sont normalisées en `NotFoundException('Course not found')`.
- `409 Course has no ready source` existe déjà pour le cas sans source `READY`.
- Aucun changement backend n'était nécessaire.

Commande d'audit backend :

```bash
rg -n "Revision sheet not found|Course not found|CourseRevisionSheet" src/modules/courses test
```

Résultat utile :

```text
src/modules/courses/interfaces/courses.controller.ts:180:          throw new NotFoundException('Revision sheet not found');
src/modules/courses/interfaces/courses.controller.ts:314:    (error.message === 'Course not found' ||
src/modules/courses/application/course-revision-sheet.use-case.ts:78:    throw new Error('Course not found');
```

## Solution retenue

Dans `HttpCoursesRepository.getCourseRevisionSheet` :

- `404` avec `message == 'Revision sheet not found'` retourne `null`.
- `404` avec `message == 'Course not found'` lève `CourseNotFoundException`.
- `404` ambigu ou sans message reconnu lève aussi `CourseNotFoundException`.

Le choix pour les `404` ambigus est volontairement conservateur : il vaut mieux afficher `Cours introuvable` que proposer de générer une fiche sur une route potentiellement morte.

La page `CourseRevisionSheetPage` avait déjà une branche UI `CourseNotFoundException`. Un test widget a été ajouté pour verrouiller ce comportement.

## Fichiers créés

- `docs/core/CORE_04_BIS_COURSE_REVISION_SHEET_404_MAPPING_REPORT.md`

## Fichiers modifiés

- `lib/features/courses/data/http_courses_repository.dart`
- `test/features/courses/http_courses_repository_test.dart`
- `test/features/courses/course_revision_sheet_page_test.dart`

## Fichiers supprimés

Aucun.

## Tests ajoutés ou renforcés

- Repository HTTP :
  - `404 Revision sheet not found` -> `null`.
  - `404 Course not found` -> `CourseNotFoundException`.
  - `409 Course has no ready source` reste mappé vers `CourseRevisionSheetNotReadyException`.
- Widget :
  - `CourseRevisionSheetPage` affiche `Cours introuvable` et n'affiche pas `Fiche non générée` quand le repository lève `CourseNotFoundException`.

## Commandes exécutées et résultats exacts

### Test rouge avant correction

```bash
flutter test test/features/courses/http_courses_repository_test.dart --reporter compact
```

Résultat : échec attendu.

```text
Expected: throws <Instance of 'CourseNotFoundException'>
  Actual: <Instance of 'Future<RevisionSheet?>'>
   Which: emitted <null>
```

### Formatage ciblé

```bash
dart format lib/features/courses/data/http_courses_repository.dart test/features/courses/http_courses_repository_test.dart test/features/courses/course_revision_sheet_page_test.dart
```

Résultat :

```text
Formatted test/features/courses/http_courses_repository_test.dart
Formatted test/features/courses/course_revision_sheet_page_test.dart
Formatted 3 files (2 changed) in 0.02 seconds.
```

Note : je n'ai pas lancé `dart format lib test` en écriture globale pour éviter de reformater des fichiers hors lot dans un worktree vivant.

### Tests ciblés

```bash
flutter test test/features/courses/course_revision_sheet_page_test.dart --reporter compact
```

Résultat :

```text
All tests passed!
```

```bash
flutter test test/features/courses/http_courses_repository_test.dart --reporter compact
```

Résultat :

```text
All tests passed!
```

Une première tentative en parallèle a échoué sur un verrou/fichier éphémère Flutter, pas sur le code :

```text
Unable to delete file or directory at ".../ios/Flutter/ephemeral/Packages/.packages".
```

La commande a ensuite été relancée seule et a passé.

### Analyse et suites

```bash
dart analyze lib test
```

Résultat :

```text
Analyzing lib, test...
No issues found!
```

```bash
flutter test test/features/courses --reporter compact
```

Résultat :

```text
All tests passed!
```

```bash
flutter test test/app/router/app_router_test.dart --reporter compact
```

Résultat :

```text
All tests passed!
```

```bash
flutter test test/app/revision_app_test.dart --reporter compact
```

Résultat :

```text
All tests passed!
```

```bash
flutter test --reporter compact
```

Résultat :

```text
All tests passed!
```

### Garde-fous

```bash
rg -n "CourseSource" lib test
```

Résultat : aucune occurrence.

```bash
rg -n "Loi normale|78%|870|7 jours" lib test
```

Résultat : occurrences existantes hors flux course réel :

- assertions `findsNothing` dans les tests anti-fixtures ;
- anciens fichiers `features/mvp` ;
- `RevisionTopCounters` legacy avec `870`, déjà existant hors modification de ce bis.

### Diff

```bash
git diff --check -- .
```

Résultat : aucune sortie, pas d'erreur de whitespace.

## Risques restants

- Le front dépend de messages backend exacts (`Course not found`, `Revision sheet not found`). C'est acceptable pour ce bis minimal, mais un futur contrat d'erreurs codées serait plus robuste.
- Les `404` ambigus sont mappés en `CourseNotFoundException`. C'est volontairement conservateur, mais cela peut masquer une future variante backend de fiche absente si le message change sans test contractuel.
- Des occurrences legacy de fixtures restent dans `features/mvp`, hors parcours course réel et hors périmètre de ce bis.

## Auto-review

- Le repository ne mappe plus tous les `404` course sheet en `null`.
- `Revision sheet not found` continue d'afficher `Fiche non générée`.
- `Course not found` affiche maintenant `Cours introuvable`.
- Aucun backend modifié.
- Aucun endpoint ajouté.
- Aucun comportement CORE-05 ajouté.
- Aucun mock métier réintroduit.
- Aucun `CourseSource` ajouté.
- Aucun commit Git réalisé.

## Auto-critique finale

Solide :

- Le bug est couvert au niveau HTTP et au niveau UI.
- Le correctif est très local et ne touche pas au modèle de fiche.
- La stratégie d'ambiguïté privilégie l'honnêteté du parcours utilisateur.

Fragile :

- Le parsing repose sur `message` plutôt que sur un `code` stable.
- Le test backend contractuel n'a pas été renforcé, car le backend était déjà suffisant et non modifié.

Fait au plus simple :

- Ajout d'un helper privé `_responseMessage` dans le repository au lieu d'introduire une couche globale de mapping d'erreurs.

## Points discutables du prompt

- Modifier le backend aurait été disproportionné : le contrat existant suffisait déjà.
- `dart format lib test` en écriture globale est risqué dans un worktree partagé ; j'ai formaté explicitement les fichiers touchés.
- Un contrat d'erreurs par code serait plus propre à terme, mais trop large pour un mini-bis.

## Contenu complet des fichiers modifiés

Le rapport courant n'est pas ré-inclus dans cette section pour éviter une récursion infinie.

### `lib/features/courses/data/http_courses_repository.dart`

```dart
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../domain/course_models.dart';
import '../domain/courses_repository.dart';
import '../../documents/data/revision_sheet_json.dart';
import '../../documents/domain/revision_document.dart';

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

### `test/features/courses/http_courses_repository_test.dart`

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

### `test/features/courses/course_revision_sheet_page_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/courses_repository.dart';
import 'package:revision_app/features/courses/presentation/course_revision_sheet_page.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';

import '../../fakes/in_memory_courses_repository.dart';

void main() {
  testWidgets('course revision sheet page displays an existing sheet', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..revisionSheetsByCourse['course-1'] = revisionSheet();

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Fiche de cours'), findsWidgets);
    expect(find.text('Introduction'), findsOneWidget);
    expect(find.text('Institutions'), findsOneWidget);
    expect(find.text('Le Parlement contrôle le Gouvernement.'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('870'), findsNothing);
    expect(find.text('7 jours'), findsNothing);
  });

  testWidgets('course revision sheet page can generate a missing sheet', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..generatedRevisionSheetsByCourse['course-1'] = revisionSheet();

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Fiche non générée'), findsOneWidget);

    await tester.tap(find.text('Générer la fiche'));
    await tester.pumpAndSettle();

    expect(repository.generateRevisionSheetCount, 1);
    expect(find.text('Institutions'), findsOneWidget);
  });

  testWidgets('course revision sheet page shows no-ready-source errors', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..revisionSheetErrorsByCourse['course-1'] =
          const CourseRevisionSheetNotReadyException(
            'Course has no ready source',
          );

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Aucune source prête'), findsOneWidget);
    expect(find.textContaining('traitée avec succès'), findsOneWidget);
  });

  testWidgets('course revision sheet page shows course not found errors', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..revisionSheetErrorsByCourse['course-1'] = const CourseNotFoundException(
        'Course not found',
      );

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Cours introuvable'), findsOneWidget);
    expect(find.text('Fiche non générée'), findsNothing);
  });
}

Widget testApp(InMemoryCoursesRepository repository) {
  return ProviderScope(
    overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(
      home: Scaffold(body: CourseRevisionSheetPage(courseId: 'course-1')),
    ),
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
```
