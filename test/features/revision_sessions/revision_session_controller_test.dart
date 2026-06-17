import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/revision_sessions/application/revision_session_controller.dart';
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';

import '../../fakes/in_memory_revision_sessions_api.dart';

void main() {
  test('starts a revision session with subject only', () async {
    final api = InMemoryRevisionSessionsApi();
    final controller = RevisionSessionController(api);

    final response = await controller.startSession(subjectId: ' subject-1 ');

    expect(response.session.id, 'revision-session-1');
    expect(api.startedSubjectId, 'subject-1');
    expect(api.startedKnowledgeUnitId, isNull);
    expect(api.startCount, 1);
  });

  test(
    'starts a revision session with knowledge unit and preferred action',
    () async {
      final api = InMemoryRevisionSessionsApi();
      final controller = RevisionSessionController(api);

      await controller.startSession(
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
        preferredAction: RevisionSessionPreferredAction.openQuestion,
      );

      expect(api.startedSubjectId, 'subject-1');
      expect(api.startedKnowledgeUnitId, 'unit-1');
      expect(
        api.startedPreferredAction,
        RevisionSessionPreferredAction.openQuestion,
      );
    },
  );

  test('starts a revision session with rich closed preferred action', () async {
    final api = InMemoryRevisionSessionsApi();
    final controller = RevisionSessionController(api);

    await controller.startSession(
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
      preferredAction: RevisionSessionPreferredAction.richClosedExercise,
    );

    expect(api.startedSubjectId, 'subject-1');
    expect(api.startedKnowledgeUnitId, 'unit-1');
    expect(
      api.startedPreferredAction,
      RevisionSessionPreferredAction.richClosedExercise,
    );
  });

  test('loads a revision session by id', () async {
    final api = InMemoryRevisionSessionsApi();
    final controller = RevisionSessionController(api);

    final response = await controller.loadSession(sessionId: ' session-1 ');

    expect(response.session.id, 'revision-session-1');
    expect(api.loadedSessionId, 'session-1');
    expect(api.loadCount, 1);
  });

  test('rejects empty start and load inputs', () async {
    final api = InMemoryRevisionSessionsApi();
    final controller = RevisionSessionController(api);

    expect(() => controller.startSession(subjectId: ' '), throwsArgumentError);
    expect(() => controller.loadSession(sessionId: ' '), throwsArgumentError);
    expect(api.startCount, 0);
    expect(api.loadCount, 0);
  });
}
