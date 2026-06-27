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
    this.mode,
    super.key,
  });

  final String sessionId;
  final RevisionSessionController controller;
  final String? mode;

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
    if (oldWidget.sessionId != widget.sessionId ||
        oldWidget.mode != widget.mode) {
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
                message: 'Préparation du bilan de la session.',
              ),
            ],
          );
        }

        final result = snapshot.data;
        if (snapshot.hasError || result == null) {
          return RevisionPageScaffold(
            children: [
              Text('Bilan de session', style: RevisionTypography.pageTitle),
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
    if (widget.mode?.trim().toLowerCase() == 'exam') {
      return widget.controller.loadExamPreparationResult(
        sessionId: widget.sessionId,
      );
    }

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
    final hasMissedCorrections = missedCorrections.isNotEmpty;
    final hasKnowledgeUnitSummary = mastered.isNotEmpty || toReview.isNotEmpty;

    final showConfetti = result.summary.score >= 0.85;

    return Stack(
      children: [
        RevisionPageScaffold(
          children: [
            RevisionPageHeader(
              title: result.session.mode == RevisionSessionMode.exam
                  ? 'Préparation examen terminée'
                  : 'Session terminée',
              subtitle: 'Voilà ce qui progresse et ce qui mérite une reprise.',
            ),
            _ResultHeroCard(result: result),
            if (hasKnowledgeUnitSummary)
              _ResultHighlights(
                masteredCount: mastered.length,
                toReviewCount: toReview.length,
              ),
            if (mastered.isNotEmpty)
              _ResultSection(
                title: 'Notions consolidées',
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
            if (missedCorrections.isEmpty) const _NoCorrectionsCard(),
            _NextStepCard(
              courseId: courseId,
              hasMissedCorrections: hasMissedCorrections,
            ),
          ],
        ),
        if (showConfetti)
          const Positioned.fill(child: RevisionConfettiOverlay()),
      ],
    );
  }
}

class _ResultHeroCard extends StatelessWidget {
  const _ResultHeroCard({required this.result});

  final RevisionSessionResult result;

  @override
  Widget build(BuildContext context) {
    final score = result.summary.score;

    return RevisionGlassCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [RevisionColors.glassStrong, RevisionColors.ink2],
      ),
      child: Row(
        children: [
          RevisionMasteryRing(
            value: score,
            label: '${(score * 100).round()}%',
            caption: 'score',
            size: 104,
            color: _scoreColor(score),
          ),
          const SizedBox(width: RevisionSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _resultMessage(score),
                  style: RevisionTypography.sectionTitle,
                ),
                const SizedBox(height: RevisionSpacing.s),
                Text(
                  _scoreLabel(result.summary),
                  style: RevisionTypography.body.copyWith(
                    color: RevisionColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(
                  'L’essentiel maintenant : comprendre l’erreur et choisir la suite.',
                  style: RevisionTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultHighlights extends StatelessWidget {
  const _ResultHighlights({
    required this.masteredCount,
    required this.toReviewCount,
  });

  final int masteredCount;
  final int toReviewCount;

  @override
  Widget build(BuildContext context) {
    final highlights = <Widget>[
      _ResultHighlightTile(
        value: masteredCount,
        label: masteredCount > 1 ? 'notions consolidées' : 'notion consolidée',
        color: RevisionColors.green,
      ),
      _ResultHighlightTile(
        value: toReviewCount,
        label: toReviewCount > 1
            ? 'notions à retravailler'
            : 'notion à retravailler',
        color: RevisionColors.amber,
      ),
    ];

    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.m),
      child: Row(
        children: [
          for (final tile in highlights) ...[
            Expanded(child: tile),
            if (tile != highlights.last)
              const SizedBox(
                height: 52,
                child: VerticalDivider(color: RevisionColors.border),
              ),
          ],
        ],
      ),
    );
  }
}

class _ResultHighlightTile extends StatelessWidget {
  const _ResultHighlightTile({
    required this.value,
    required this.label,
    required this.color,
  });

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: RevisionTypography.pageTitle.copyWith(color: color),
        ),
        const SizedBox(height: RevisionSpacing.xs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: RevisionTypography.caption,
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
                'Corrections utiles',
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
              label: 'Bonne réponse',
              value: _answersLabel(correction.correctAnswers),
              color: RevisionColors.green,
            ),
            if (correction.explanation != null) ...[
              const SizedBox(height: RevisionSpacing.s),
              Text(
                'À retenir',
                style: RevisionTypography.caption.copyWith(
                  color: RevisionColors.textMuted,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: RevisionSpacing.xs),
              Text(correction.explanation!, style: RevisionTypography.body),
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

class _NoCorrectionsCard extends StatelessWidget {
  const _NoCorrectionsCard();

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: RevisionColors.green),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Text(
              'Aucune erreur à corriger pour cette session.',
              style: RevisionTypography.body.copyWith(
                color: RevisionColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextStepCard extends StatelessWidget {
  const _NextStepCard({
    required this.courseId,
    required this.hasMissedCorrections,
  });

  final String? courseId;
  final bool hasMissedCorrections;

  @override
  Widget build(BuildContext context) {
    final courseId = this.courseId;

    return RevisionGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Prochaine étape', style: RevisionTypography.sectionTitle),
          const SizedBox(height: RevisionSpacing.s),
          Text(_nextStepMessage(), style: RevisionTypography.body),
          const SizedBox(height: RevisionSpacing.m),
          if (courseId != null) ...[
            RevisionGradientButton(
              label: hasMissedCorrections ? 'Voir la fiche' : 'Retour au cours',
              icon: hasMissedCorrections
                  ? Icons.description_rounded
                  : Icons.arrow_back_rounded,
              expanded: true,
              onPressed: () => hasMissedCorrections
                  ? context.push(AppRoutes.courseSheet(courseId))
                  : context.go(AppRoutes.course(courseId)),
            ),
            const SizedBox(height: RevisionSpacing.m),
            RevisionGradientButton(
              label: hasMissedCorrections ? 'Retour au cours' : 'Voir la fiche',
              icon: hasMissedCorrections
                  ? Icons.arrow_back_rounded
                  : Icons.description_rounded,
              expanded: true,
              gradient: const LinearGradient(
                colors: [RevisionColors.glassStrong, RevisionColors.ink3],
              ),
              onPressed: () => hasMissedCorrections
                  ? context.go(AppRoutes.course(courseId))
                  : context.push(AppRoutes.courseSheet(courseId)),
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
    );
  }

  String _nextStepMessage() {
    if (courseId == null) {
      return 'Reviens à tes révisions pour choisir la suite.';
    }

    if (hasMissedCorrections) {
      return 'Commence par revoir la fiche du cours, puis reprends la notion à froid.';
    }

    return 'Tu peux retourner au cours et choisir la prochaine notion à consolider.';
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

  return 'On sait quoi retravailler.';
}

String _scoreLabel(RevisionSessionResultSummary summary) {
  return '${summary.correctAnswers} / ${summary.totalQuestions} bonnes réponses';
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

String _errorTitle(Object? _) {
  return 'Impossible de charger le résultat.';
}

String _errorMessage(Object? error) {
  if (error is RevisionSessionNotFoundException) {
    return 'Cette session n’est pas accessible.';
  }
  if (error is RevisionSessionResultNotReadyException) {
    return 'Le bilan sera disponible dès que la session sera finalisée.';
  }

  return 'Le résultat sera affiché après une session finalisée.';
}
