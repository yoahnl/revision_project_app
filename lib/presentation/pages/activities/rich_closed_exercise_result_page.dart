import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/app/router/app_routes.dart';
import 'package:Neralune/features/activities/application/activity_controller.dart';
import 'package:Neralune/features/activities/domain/rich_closed_exercise.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_correction_list.dart';
import 'package:Neralune/presentation/theme/app_spacing.dart';
import 'package:Neralune/presentation/widgets/revision_button.dart';
import 'package:Neralune/presentation/widgets/revision_message.dart';
import 'package:Neralune/presentation/widgets/revision_page.dart';
import 'package:Neralune/presentation/widgets/revision_panel.dart';

class RichClosedExerciseResultPage extends StatefulWidget {
  const RichClosedExerciseResultPage({
    required this.controller,
    required this.sessionId,
    this.courseId,
    super.key,
  });

  final ActivityController controller;
  final String sessionId;
  final String? courseId;

  @override
  State<RichClosedExerciseResultPage> createState() =>
      _RichClosedExerciseResultPageState();
}

class _RichClosedExerciseResultPageState
    extends State<RichClosedExerciseResultPage> {
  late Future<_LoadedRichClosedResult> _result;

  @override
  void initState() {
    super.initState();
    _result = _loadResult();
  }

  @override
  void didUpdateWidget(covariant RichClosedExerciseResultPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.sessionId != widget.sessionId) {
      _result = _loadResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RevisionPage(
      title: 'Résultat questions riches',
      subtitle: 'Correction enregistrée côté serveur.',
      children: [
        FutureBuilder<_LoadedRichClosedResult>(
          future: _result,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const RevisionPanel(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final loaded = snapshot.data;
            if (snapshot.hasError || loaded == null) {
              return _ResultErrorPanel(onRetry: _retry);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichClosedCorrectionList(
                  exercise: loaded.exercise,
                  result: loaded.result,
                ),
                if (_normalized(widget.courseId) != null) ...[
                  const SizedBox(height: AppSpacing.m),
                  RevisionButton(
                    label: 'Retour au cours',
                    icon: Icons.arrow_back,
                    onPressed: () => context.go(
                      AppRoutes.course(_normalized(widget.courseId)!),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Future<_LoadedRichClosedResult> _loadResult() async {
    final sessionId = _normalized(widget.sessionId);
    if (sessionId == null) {
      throw ArgumentError('Activity session id is required');
    }

    final exercise = await widget.controller.getRichClosedExercise(sessionId);
    final result = await widget.controller.getRichClosedExerciseResult(
      sessionId,
    );

    return _LoadedRichClosedResult(exercise: exercise, result: result);
  }

  void _retry() {
    setState(() {
      _result = _loadResult();
    });
  }

  String? _normalized(String? value) {
    final trimmedValue = value?.trim();
    return trimmedValue == null || trimmedValue.isEmpty ? null : trimmedValue;
  }
}

class _LoadedRichClosedResult {
  const _LoadedRichClosedResult({required this.exercise, required this.result});

  final RichClosedExercise exercise;
  final RichClosedExerciseResult result;
}

class _ResultErrorPanel extends StatelessWidget {
  const _ResultErrorPanel({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RevisionMessage(
            message:
                'Impossible de charger ce résultat. Réessaie dans un instant.',
            color: Theme.of(context).colorScheme.error,
            icon: Icons.error_outline,
          ),
          const SizedBox(height: AppSpacing.m),
          RevisionButton(
            label: 'Réessayer',
            icon: Icons.refresh,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
