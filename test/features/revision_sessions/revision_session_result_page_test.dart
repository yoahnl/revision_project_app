import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/revision_sessions/application/revision_session_controller.dart';
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:revision_app/presentation/pages/revision_sessions/revision_session_result_page.dart';

import '../../fakes/in_memory_revision_sessions_api.dart';

void main() {
  testWidgets(
    'displays real revision session result without static MVP score',
    (tester) async {
      final api = InMemoryRevisionSessionsApi();

      await tester.pumpWidget(_Harness(api: api));
      await tester.pumpAndSettle();

      expect(api.loadResultCount, 1);
      expect(api.loadedResultSessionId, 'revision-session-1');
      expect(find.text('Session terminée'), findsOneWidget);
      expect(find.text('67%'), findsWidgets);
      expect(find.text('4/6 bonnes réponses'), findsOneWidget);
      expect(find.text('À retravailler'), findsOneWidget);
      expect(find.text('Séparation des pouvoirs'), findsOneWidget);
      expect(find.text('78%'), findsNothing);
      expect(find.text('4/5 bonnes'), findsNothing);
    },
  );

  testWidgets('displays a not-ready error from backend result contract', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi()
      ..loadResultError = const RevisionSessionResultNotReadyException(
        'Revision session not completed',
      );

    await tester.pumpWidget(_Harness(api: api));
    await tester.pumpAndSettle();

    expect(find.text('Résultat indisponible'), findsOneWidget);
    expect(find.text('Revision session not completed'), findsOneWidget);
    expect(find.text('78%'), findsNothing);
  });
}

class _Harness extends StatelessWidget {
  const _Harness({required this.api});

  final InMemoryRevisionSessionsApi api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RevisionSessionResultPage(
        sessionId: 'revision-session-1',
        controller: RevisionSessionController(api),
      ),
    );
  }
}
