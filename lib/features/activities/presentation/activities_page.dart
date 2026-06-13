import 'package:flutter/material.dart';

import '../application/activity_controller.dart';
import '../domain/diagnostic_quiz_activity.dart';
import '../genui/diagnostic_quiz_activity_validator.dart';
import '../genui/revision_activity_catalog.dart';
import 'diagnostic_quiz_page.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({
    required this.controller,
    required this.subjectId,
    super.key,
  });

  final ActivityController controller;
  final String? subjectId;

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  Future<DiagnosticQuizActivity>? _activity;
  final _catalog = buildRevisionActivityCatalog();

  @override
  void initState() {
    super.initState();
    final subjectId = widget.subjectId;
    if (subjectId != null && subjectId.trim().isNotEmpty) {
      _activity = widget.controller.startNextActivity(subjectId: subjectId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Activites', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Expanded(
            child: _activity == null
                ? const Center(child: Text('Aucune activite selectionnee'))
                : FutureBuilder<DiagnosticQuizActivity>(
                    future: _activity,
                    builder: (context, snapshot) {
                      final activity = snapshot.data;

                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError || activity == null) {
                        return const Center(
                          child: Text("Impossible de charger l'activite"),
                        );
                      }

                      if (!isDiagnosticQuizActivityCatalogSafe(activity)) {
                        return const Center(
                          child: Text('Activite indisponible'),
                        );
                      }

                      return Semantics(
                        label: _catalog.catalogId,
                        child: DiagnosticQuizPage(
                          activity: activity,
                          onSubmit: (answers) {
                            return widget.controller.submitResult(
                              sessionId: activity.sessionId,
                              answers: answers,
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
