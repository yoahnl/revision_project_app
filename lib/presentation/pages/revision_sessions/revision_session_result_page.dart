import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../features/revision_sessions/application/revision_session_controller.dart';
import '../../../features/revision_sessions/data/revision_sessions_api.dart';
import '../../../features/revision_sessions/domain/revision_session.dart';
import '../../design_system/components/revision_mvp_components.dart';
import '../../design_system/components/revision_states.dart';
import '../../design_system/tokens/revision_colors.dart';
import '../../design_system/tokens/revision_spacing.dart';
import '../../design_system/tokens/revision_typography.dart';

class RevisionSessionResultPage extends StatefulWidget {
  const RevisionSessionResultPage({
    required this.sessionId,
    required this.controller,
    super.key,
  });

  final String sessionId;
  final RevisionSessionController controller;

  @override
  State<RevisionSessionResultPage> createState() =>
      _RevisionSessionResultPageState();
}

class _RevisionSessionResultPageState extends State<RevisionSessionResultPage> {
  late Future<RevisionSessionResult> _result;

  @override
  void initState() {
    super.initState();
    _result = _load();
  }

  @override
  void didUpdateWidget(covariant RevisionSessionResultPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionId != widget.sessionId) {
      _result = _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RevisionSessionResult>(
      future: _result,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const RevisionPageScaffold(
            children: [
              RevisionProcessingState(
                title: 'Chargement du résultat',
                message: 'Le backend prépare le bilan réel de la session.',
              ),
            ],
          );
        }

        final result = snapshot.data;
        if (snapshot.hasError || result == null) {
          return RevisionPageScaffold(
            children: [
              Text('Résultat', style: RevisionTypography.pageTitle),
              RevisionErrorState(
                title: _errorTitle(snapshot.error),
                message: _errorMessage(snapshot.error),
                actionLabel: 'Réessayer',
                onAction: () => setState(() => _result = _load()),
              ),
            ],
          );
        }

        return _ResultContent(result: result);
      },
    );
  }

  Future<RevisionSessionResult> _load() {
    return widget.controller.loadResult(sessionId: widget.sessionId);
  }
}

class _ResultContent extends StatelessWidget {
  const _ResultContent({required this.result});

  final RevisionSessionResult result;

  @override
  Widget build(BuildContext context) {
    final mastered = result.knowledgeUnits
        .where(
          (unit) =>
              unit.state == RevisionSessionKnowledgeUnitResultState.mastered,
        )
        .toList(growable: false);
    final toReview = result.knowledgeUnits
        .where(
          (unit) =>
              unit.state == RevisionSessionKnowledgeUnitResultState.toReview,
        )
        .toList(growable: false);
    final missedCorrections = result.corrections
        .where((correction) => !correction.isCorrect)
        .toList(growable: false);
    final courseId = result.session.courseId;

    return RevisionPageScaffold(
      children: [
        if (result.summary.score > 0.70) const RevisionConfettiStrip(),
        Text(
          'Session terminée',
          textAlign: TextAlign.center,
          style: RevisionTypography.sectionTitle,
        ),
        RevisionGlassCard(
          child: Column(
            children: [
              RevisionMasteryRing(
                value: result.summary.score,
                label: '${(result.summary.score * 100).round()}%',
                caption: 'global',
                size: 112,
                color: _scoreColor(result.summary.score),
              ),
              const SizedBox(height: RevisionSpacing.m),
              Text(
                _resultMessage(result.summary.score),
                style: RevisionTypography.sectionTitle,
              ),
              const SizedBox(height: RevisionSpacing.xs),
              Text(
                '${result.summary.correctAnswers}/${result.summary.totalQuestions} bonnes réponses',
                style: RevisionTypography.body,
              ),
            ],
          ),
        ),
        if (mastered.isNotEmpty)
          _ResultSection(
            title: 'Tu maîtrises',
            icon: Icons.check_circle_rounded,
            color: RevisionColors.green,
            units: mastered,
          ),
        if (toReview.isNotEmpty)
          _ResultSection(
            title: 'À retravailler',
            icon: Icons.error_rounded,
            color: RevisionColors.amber,
            units: toReview,
          ),
        if (missedCorrections.isNotEmpty)
          _MissedCorrectionsSection(corrections: missedCorrections),
        RevisionGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Prochaine étape', style: RevisionTypography.sectionTitle),
              const SizedBox(height: RevisionSpacing.m),
              if (courseId != null) ...[
                RevisionGradientButton(
                  label: 'Voir la fiche',
                  icon: Icons.description_rounded,
                  expanded: true,
                  gradient: const LinearGradient(
                    colors: [RevisionColors.glassStrong, RevisionColors.ink3],
                  ),
                  onPressed: () =>
                      context.push(AppRoutes.courseSheet(courseId)),
                ),
                const SizedBox(height: RevisionSpacing.m),
                RevisionGradientButton(
                  label: 'Retour au cours',
                  icon: Icons.arrow_back_rounded,
                  expanded: true,
                  onPressed: () => context.go(AppRoutes.course(courseId)),
                ),
              ] else
                RevisionGradientButton(
                  label: 'Retour aux révisions',
                  icon: Icons.arrow_back_rounded,
                  expanded: true,
                  onPressed: () => context.go(AppRoutes.revisions),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MissedCorrectionsSection extends StatelessWidget {
  const _MissedCorrectionsSection({required this.corrections});

  final List<RevisionSessionQuestionCorrection> corrections;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_rounded, color: RevisionColors.blue),
              const SizedBox(width: RevisionSpacing.s),
              Text(
                'Ce que tu as loupé',
                style: RevisionTypography.sectionTitle,
              ),
            ],
          ),
          const SizedBox(height: RevisionSpacing.m),
          for (final correction in corrections) ...[
            Text(
              correction.prompt,
              style: RevisionTypography.body.copyWith(
                color: RevisionColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: RevisionSpacing.s),
            _CorrectionLine(
              label: 'Ta réponse',
              value: _answersLabel(correction.selectedAnswers),
              color: RevisionColors.red,
            ),
            const SizedBox(height: RevisionSpacing.xs),
            _CorrectionLine(
              label: 'Correction',
              value: _answersLabel(correction.correctAnswers),
              color: RevisionColors.green,
            ),
            if (correction.explanation != null) ...[
              const SizedBox(height: RevisionSpacing.s),
              Text(correction.explanation!, style: RevisionTypography.caption),
            ],
            if (correction != corrections.last)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: RevisionSpacing.m),
                child: Divider(color: RevisionColors.border),
              ),
          ],
        ],
      ),
    );
  }
}

class _CorrectionLine extends StatelessWidget {
  const _CorrectionLine({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 7),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: RevisionSpacing.s),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label : ',
                  style: RevisionTypography.caption.copyWith(
                    color: RevisionColors.textMuted,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: RevisionTypography.body.copyWith(
                    color: RevisionColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.units,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<RevisionSessionKnowledgeUnitResult> units;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: RevisionSpacing.s),
              Text(title, style: RevisionTypography.sectionTitle),
            ],
          ),
          const SizedBox(height: RevisionSpacing.m),
          for (final unit in units)
            Padding(
              padding: const EdgeInsets.only(bottom: RevisionSpacing.s),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      unit.title,
                      style: RevisionTypography.body.copyWith(
                        color: RevisionColors.text,
                      ),
                    ),
                  ),
                  Text(
                    '${(unit.score * 100).round()}%',
                    style: RevisionTypography.caption.copyWith(color: color),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

String _resultMessage(double score) {
  if (score >= 0.85) {
    return 'Très belle maîtrise.';
  }
  if (score >= 0.65) {
    return 'Bonne progression.';
  }
  if (score >= 0.40) {
    return 'Les bases prennent forme.';
  }

  return 'Cette notion mérite une nouvelle passe.';
}

String _answersLabel(List<String> answers) {
  if (answers.isEmpty) {
    return 'Aucune réponse';
  }

  return answers.join(', ');
}

Color _scoreColor(double score) {
  if (score >= 0.8) {
    return RevisionColors.green;
  }
  if (score >= 0.4) {
    return RevisionColors.amber;
  }

  return RevisionColors.red;
}

String _errorTitle(Object? error) {
  if (error is RevisionSessionNotFoundException) {
    return 'Session introuvable';
  }
  if (error is RevisionSessionResultNotReadyException) {
    return 'Résultat indisponible';
  }

  return 'Impossible de charger le résultat';
}

String _errorMessage(Object? error) {
  if (error is RevisionSessionResultNotReadyException) {
    return error.message;
  }

  return 'Le résultat sera affiché uniquement depuis un calcul backend réel.';
}
