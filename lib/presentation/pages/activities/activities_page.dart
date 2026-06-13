import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/genui/diagnostic_quiz_activity_validator.dart';
import 'package:revision_app/features/activities/genui/revision_activity_catalog.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_page.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

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
    return RevisionPage(
      title: 'Activites',
      subtitle: 'Diagnostics rapides et exercices adaptatifs.',
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.68,
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
                      return const Center(child: Text('Activite indisponible'));
                    }

                    return RevisionPanel(
                      padding: const EdgeInsets.all(AppSpacing.l),
                      child: Semantics(
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
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
