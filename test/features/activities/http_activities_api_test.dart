import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/data/http_activities_api.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';

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
  test('starts the next activity with subject id and bearer token', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(activityJson()));
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final activity = await api.startNextActivity(subjectId: 'subject-1');

    expect(activity.sessionId, 'session-1');
    expect(adapter.lastOptions?.path, '/activities/next');
    expect(adapter.lastOptions?.data, {'subjectId': 'subject-1'});
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test(
    'parses an enriched pre-submit quiz without correction fields',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(enrichedActivityJsonWithAccidentalCorrection()),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpActivitiesApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      final activity = await api.startNextActivity(subjectId: 'subject-1');
      final question = activity.questions.single;

      expect(activity.version, 2);
      expect(activity.documentId, 'document-1');
      expect(activity.subjectId, 'subject-1');
      expect(question.knowledgeUnitId, 'unit-1');
      expect(question.difficulty, 'MEDIUM');
      expect(question.sources.single.chunkId, 'chunk-1');
      expect(question.sources.single.pageNumber, isNull);
      expect(question.sources.single.index, 0);
      expect(question.choices.single.label, 'Réponse A');
    },
  );

  test(
    'parses a v3 quiz with multiple selection and bounded visuals',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(v3ActivityJsonWithAccidentalCorrection()),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpActivitiesApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      final activity = await api.startNextActivity(subjectId: 'subject-1');
      final question = activity.questions.single;
      final chart = question.visuals
          .whereType<DiagnosticQuizChartVisual>()
          .single;
      final diagram = question.visuals
          .whereType<DiagnosticQuizDiagramVisual>()
          .single;

      expect(activity.version, 3);
      expect(question.selectionMode, DiagnosticQuizSelectionMode.multiple);
      expect(question.minSelections, 1);
      expect(question.maxSelections, 2);
      expect(question.visuals, hasLength(3));
      expect(chart.title, 'Contrôles');
      expect(chart.chartType, DiagnosticQuizChartType.bar);
      expect(chart.data.single['value'], 2);
      expect(chart.sources.single.chunkId, 'chunk-1');
      expect(diagram.nodes.map((node) => node.label), ['Pouvoir', 'Contrôle']);
      expect(diagram.edges.single.label, 'limite');
      expect(
        question.visuals
            .whereType<DiagnosticQuizUnsupportedVisual>()
            .single
            .type,
        'IMAGE',
      );
      expect(question.choices.map((choice) => choice.label), [
        'Contrôle juridictionnel',
        'Pouvoir absolu',
        'Séparation des pouvoirs',
      ]);
    },
  );

  test('submits answers and maps the public score', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({'correctAnswers': 1, 'totalQuestions': 2}),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.submitResult(
      sessionId: 'session-1',
      answers: const [
        DiagnosticQuizAnswer(questionId: 'question-1', choiceId: 'a'),
      ],
    );

    expect(result.correctAnswers, 1);
    expect(result.items, isEmpty);
    expect(adapter.lastOptions?.path, '/activities/session-1/result');
    expect(adapter.lastOptions?.data, {
      'answers': [
        {'questionId': 'question-1', 'choiceId': 'a'},
      ],
    });
  });

  test(
    'submits single and multiple answers with distinct payload shapes',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse({'correctAnswers': 2, 'totalQuestions': 2}),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpActivitiesApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      await api.submitResult(
        sessionId: 'session-1',
        answers: const [
          DiagnosticQuizAnswer(questionId: 'question-single', choiceId: 'a'),
          DiagnosticQuizAnswer(
            questionId: 'question-multiple',
            choiceIds: ['a', 'c'],
          ),
        ],
      );

      expect(adapter.lastOptions?.data, {
        'answers': [
          {'questionId': 'question-single', 'choiceId': 'a'},
          {
            'questionId': 'question-multiple',
            'choiceIds': ['a', 'c'],
          },
        ],
      });
    },
  );

  test(
    'parses enriched correction result with score feedback and sources',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(enrichedResultJson()),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpActivitiesApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      final result = await api.submitResult(
        sessionId: 'session-1',
        answers: const [
          DiagnosticQuizAnswer(questionId: 'question-1', choiceId: 'b'),
        ],
      );
      final item = result.items.single;

      expect(result.correctAnswers, 0);
      expect(result.totalQuestions, 1);
      expect(result.score, 0);
      expect(item.questionId, 'question-1');
      expect(item.knowledgeUnitId, 'unit-1');
      expect(item.selectedChoiceId, 'b');
      expect(item.correctChoiceId, 'a');
      expect(item.isCorrect, isFalse);
      expect(item.explanation, 'Le myocarde assure la contraction.');
      expect(item.choiceFeedback.single.choiceId, 'b');
      expect(item.sources.single.text, 'Le myocarde est le muscle cardiaque.');
    },
  );

  test('parses v3 multiple correction result', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(v3MultipleResultJson()),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.submitResult(
      sessionId: 'session-1',
      answers: const [
        DiagnosticQuizAnswer(
          questionId: 'question-multiple',
          choiceIds: ['a', 'c'],
        ),
      ],
    );
    final item = result.items.single;

    expect(item.selectedChoiceId, isNull);
    expect(item.correctChoiceId, isNull);
    expect(item.selectedChoiceIds, ['a', 'c']);
    expect(item.correctChoiceIds, ['a', 'b']);
    expect(item.partialScore, 0.5);
    expect(item.sources.single.text, 'Source textuelle après submit.');
  });

  test(
    'rejects invalid activity JSON with a controlled format error',
    () async {
      final adapter = CapturingHttpClientAdapter(jsonResponse({'bad': true}));
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpActivitiesApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        api.startNextActivity(subjectId: 'subject-1'),
        throwsFormatException,
      );
    },
  );

  test('rejects blank Firebase ID tokens before calling the API', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(activityJson()));
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(dio: dio, getIdToken: () async => '  ');

    await expectLater(
      api.startNextActivity(subjectId: 'subject-1'),
      throwsStateError,
    );

    expect(adapter.fetchCallCount, 0);
  });
}

Map<String, Object?> activityJson() {
  return {
    'sessionId': 'session-1',
    'type': 'diagnostic_quiz',
    'title': 'Diagnostic rapide',
    'questions': [
      {
        'id': 'question-1',
        'prompt': 'Question test',
        'choices': [
          {'id': 'a', 'label': 'Reponse A'},
          {'id': 'b', 'label': 'Reponse B'},
        ],
      },
    ],
  };
}

Map<String, Object?> enrichedActivityJsonWithAccidentalCorrection() {
  return {
    'sessionId': 'session-1',
    'type': 'diagnostic_quiz',
    'version': 2,
    'documentId': 'document-1',
    'subjectId': 'subject-1',
    'title': 'Diagnostic sourcé',
    'questions': [
      {
        'id': 'question-1',
        'knowledgeUnitId': 'unit-1',
        'prompt': 'Question test',
        'difficulty': 'MEDIUM',
        'correctChoiceId': 'a',
        'isCorrect': true,
        'explanation': 'Ne doit jamais être mappée avant submit.',
        'choices': [
          {
            'id': 'a',
            'label': 'Réponse A',
            'feedback': 'Ne doit jamais être mappé avant submit.',
          },
        ],
        'sources': [
          {
            'chunkId': 'chunk-1',
            'pageNumber': null,
            'index': 0,
            'text': 'Ne doit pas être lu avant submit.',
          },
        ],
      },
    ],
  };
}

Map<String, Object?> v3ActivityJsonWithAccidentalCorrection() {
  return {
    'sessionId': 'session-v3',
    'type': 'diagnostic_quiz',
    'version': 3,
    'documentId': 'document-1',
    'subjectId': 'subject-1',
    'title': 'Diagnostic v3',
    'questions': [
      {
        'id': 'question-multiple',
        'knowledgeUnitId': 'unit-1',
        'prompt': 'Quels éléments contrôlent le pouvoir ?',
        'difficulty': 'MEDIUM',
        'selectionMode': 'multiple',
        'minSelections': 1,
        'maxSelections': 2,
        'correctChoiceIds': ['a', 'c'],
        'explanation': 'Ne doit jamais être mappée avant submit.',
        'choices': [
          {
            'id': 'a',
            'label': 'Contrôle juridictionnel',
            'feedback': 'Ne doit jamais être mappé avant submit.',
          },
          {'id': 'b', 'label': 'Pouvoir absolu'},
          {'id': 'c', 'label': 'Séparation des pouvoirs'},
        ],
        'sources': [
          {
            'chunkId': 'chunk-1',
            'pageNumber': null,
            'index': 0,
            'text': 'Ne doit pas être lu avant submit.',
          },
        ],
        'visuals': [
          {
            'id': 'visual-chart',
            'type': 'CHART',
            'displayOrder': 0,
            'chartType': 'bar',
            'title': 'Contrôles',
            'description': 'Répartition des éléments',
            'data': [
              {'category': 'Contrôle', 'value': 2},
            ],
            'xKey': 'category',
            'yKeys': ['value'],
            'sources': [
              {'chunkId': 'chunk-1', 'pageNumber': null, 'index': 0},
            ],
          },
          {
            'id': 'visual-diagram',
            'type': 'DIAGRAM',
            'displayOrder': 1,
            'title': 'Relations',
            'nodes': [
              {'id': 'n1', 'label': 'Pouvoir'},
              {'id': 'n2', 'label': 'Contrôle'},
            ],
            'edges': [
              {'from': 'n1', 'to': 'n2', 'label': 'limite'},
            ],
            'sources': [
              {'chunkId': 'chunk-1', 'pageNumber': null, 'index': 0},
            ],
          },
          {
            'id': 'visual-image',
            'type': 'IMAGE',
            'displayOrder': 2,
            'sources': [
              {'chunkId': 'chunk-1', 'pageNumber': null, 'index': 0},
            ],
          },
        ],
      },
    ],
  };
}

Map<String, Object?> enrichedResultJson() {
  return {
    'correctAnswers': 0,
    'totalQuestions': 1,
    'score': 0.0,
    'items': [
      {
        'questionId': 'question-1',
        'knowledgeUnitId': 'unit-1',
        'prompt': 'Question test',
        'selectedChoiceId': 'b',
        'correctChoiceId': 'a',
        'isCorrect': false,
        'explanation': 'Le myocarde assure la contraction.',
        'choiceFeedback': [
          {'choiceId': 'b', 'feedback': 'Le péricarde protège le coeur.'},
        ],
        'sources': [
          {
            'chunkId': 'chunk-1',
            'text': 'Le myocarde est le muscle cardiaque.',
            'pageNumber': null,
            'index': 0,
          },
        ],
      },
    ],
  };
}

Map<String, Object?> v3MultipleResultJson() {
  return {
    'correctAnswers': 0,
    'totalQuestions': 1,
    'score': 0.0,
    'items': [
      {
        'questionId': 'question-multiple',
        'knowledgeUnitId': 'unit-1',
        'prompt': 'Quels éléments contrôlent le pouvoir ?',
        'selectedChoiceIds': ['a', 'c'],
        'correctChoiceIds': ['a', 'b'],
        'isCorrect': false,
        'partialScore': 0.5,
        'explanation': 'Explication post-submit.',
        'choiceFeedback': [
          {'choiceId': 'c', 'feedback': 'Feedback post-submit.'},
        ],
        'sources': [
          {
            'chunkId': 'chunk-1',
            'text': 'Source textuelle après submit.',
            'pageNumber': null,
            'index': 0,
          },
        ],
      },
    ],
  };
}

ResponseBody jsonResponse(Object body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}
