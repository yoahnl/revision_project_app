import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/core/routing/route_paths.dart';
import 'package:Neralune/features/today/application/today_notifier.dart';
import 'package:Neralune/features/today/domain/today_plan.dart';
import 'package:Neralune/presentation/design_system/components/revision_mvp_components.dart';
import 'package:Neralune/presentation/design_system/components/revision_states.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_colors.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_spacing.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_subject_visuals.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_typography.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(todayNotifierProvider);
    final notifier = ref.read(todayNotifierProvider.notifier);

    return RevisionPageScaffold(
      maxWidth: 760,
      headerChildren: const [_TodayHeader()],
      children: [
        plan.when(
          loading: () => const RevisionLoadingState(
            label: 'Préparation de ta session du jour...',
          ),
          error: (error, stackTrace) => RevisionErrorState(
            title: 'Impossible de charger ta session du jour.',
            message:
                'Réessaie dans un instant pour retrouver la recommandation du jour.',
            actionLabel: 'Réessayer',
            onAction: notifier.reload,
          ),
          data: (plan) {
            if (plan.items.isEmpty) {
              return const _TodayEmptyState();
            }

            return _TodayPlanContent(plan: plan);
          },
        ),
      ],
    );
  }
}

class _TodayHeader extends StatelessWidget {
  const _TodayHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Aujourd’hui', style: RevisionTypography.pageTitle),
              SizedBox(height: RevisionSpacing.xs),
              Text(
                'Une priorité claire pour avancer sans te disperser.',
                style: RevisionTypography.body,
              ),
            ],
          ),
        ),
        const SizedBox(width: RevisionSpacing.m),
        const RevisionIconTile(
          icon: Icons.auto_awesome_rounded,
          accent: RevisionColors.cyan,
          size: 48,
          iconSize: 23,
        ),
      ],
    );
  }
}

class _TodayPlanContent extends StatelessWidget {
  const _TodayPlanContent({required this.plan});

  final TodayPlan plan;

  @override
  Widget build(BuildContext context) {
    final primaryItem = plan.items.first;
    final secondaryItems = plan.items.skip(1).take(2).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PrimarySessionCard(item: primaryItem),
        if (secondaryItems.isNotEmpty) ...[
          const SizedBox(height: RevisionSpacing.l),
          _ContinuationSection(items: secondaryItems),
        ],
      ],
    );
  }
}

class _PrimarySessionCard extends StatelessWidget {
  const _PrimarySessionCard({required this.item});

  final TodayPlanItem item;

  @override
  Widget build(BuildContext context) {
    final visual = revisionSubjectVisualThemeFor(item.subjectName);
    final canStart = _canStartAction(item);
    final route = canStart ? _routeFor(item) : null;

    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.xl),
      borderColor: visual.accent.withValues(alpha: 0.46),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          visual.accent.withValues(alpha: 0.34),
          RevisionColors.blueDeep.withValues(alpha: 0.20),
          RevisionColors.glassStrong,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ta session du jour',
                      style: RevisionTypography.caption.copyWith(
                        color: RevisionColors.text.withValues(alpha: 0.76),
                      ),
                    ),
                    const SizedBox(height: RevisionSpacing.m),
                    _SubjectBadge(item: item, visual: visual),
                  ],
                ),
              ),
              RevisionIconTile(
                icon: visual.icon,
                accent: visual.accent,
                size: 50,
                iconSize: 25,
              ),
            ],
          ),
          const SizedBox(height: RevisionSpacing.xl),
          Text(_targetTitle(item), style: RevisionTypography.pageTitle),
          const SizedBox(height: RevisionSpacing.s),
          Text(
            _sessionMeta(item),
            style: RevisionTypography.body.copyWith(
              color: RevisionColors.text.withValues(alpha: 0.84),
            ),
          ),
          const SizedBox(height: RevisionSpacing.l),
          Text(_recommendationReason(item), style: RevisionTypography.body),
          const SizedBox(height: RevisionSpacing.xl),
          RevisionGradientButton(
            label: canStart ? 'Réviser maintenant' : 'Session indisponible',
            icon: canStart
                ? Icons.play_arrow_rounded
                : Icons.lock_outline_rounded,
            expanded: true,
            onPressed: route == null ? null : () => context.go(route),
          ),
        ],
      ),
    );
  }
}

class _SubjectBadge extends StatelessWidget {
  const _SubjectBadge({required this.item, required this.visual});

  final TodayPlanItem item;
  final RevisionSubjectVisualTheme visual;

  @override
  Widget build(BuildContext context) {
    final subjectName = item.subjectName.trim();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RevisionSpacing.m,
        vertical: RevisionSpacing.s,
      ),
      decoration: BoxDecoration(
        color: RevisionColors.glassStrong.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: visual.accent.withValues(alpha: 0.48)),
      ),
      child: Text(
        subjectName.isEmpty ? 'MATIÈRE' : subjectName.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: RevisionTypography.caption.copyWith(
          color: visual.accent,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ContinuationSection extends StatelessWidget {
  const _ContinuationSection({required this.items});

  final List<TodayPlanItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Continuer', style: RevisionTypography.sectionTitle),
        const SizedBox(height: RevisionSpacing.m),
        for (final item in items) ...[
          _ContinuationTile(item: item),
          if (item != items.last) const SizedBox(height: RevisionSpacing.m),
        ],
      ],
    );
  }
}

class _ContinuationTile extends StatelessWidget {
  const _ContinuationTile({required this.item});

  final TodayPlanItem item;

  @override
  Widget build(BuildContext context) {
    final visual = revisionSubjectVisualThemeFor(item.subjectName);
    final canStart = _canStartAction(item);
    final route = canStart ? _routeFor(item) : null;

    return RevisionActionListTile(
      title: _targetTitle(item),
      subtitle: '${item.subjectName} · ${_shortSessionMeta(item)}',
      icon: visual.icon,
      accent: visual.accent,
      enabled: canStart,
      onTap: route == null ? null : () => context.go(route),
      trailing: Icon(
        canStart ? Icons.arrow_forward_rounded : Icons.lock_outline_rounded,
        color: canStart ? RevisionColors.textMuted : RevisionColors.textFaint,
      ),
    );
  }
}

class _TodayEmptyState extends StatelessWidget {
  const _TodayEmptyState();

  @override
  Widget build(BuildContext context) {
    return RevisionEmptyState(
      title: 'Rien de prêt pour aujourd’hui',
      message:
          'Ajoute un cours ou une source pour que Neralune prépare ta prochaine session.',
      icon: Icons.auto_stories_outlined,
      actionLabel: 'Voir mes cours',
      onAction: () => context.go(homeRoutePath),
    );
  }
}

bool _canStartAction(TodayPlanItem item) {
  final subjectId = item.startPayload.subjectId.trim();
  if (subjectId.isEmpty) {
    return false;
  }

  if (item.action == TodayPlanActionType.openQuestion ||
      item.action == TodayPlanActionType.richClosedExercise) {
    return item.startPayload.knowledgeUnitId?.trim().isNotEmpty ?? false;
  }

  return true;
}

String _routeFor(TodayPlanItem item) {
  final payload = item.startPayload;

  return switch (item.action) {
    TodayPlanActionType.diagnosticQuiz => Uri(
      path: activitiesRoutePath,
      queryParameters: {'subjectId': payload.subjectId},
    ).toString(),
    TodayPlanActionType.openQuestion => Uri(
      path: activitiesRoutePath,
      queryParameters: {
        'subjectId': payload.subjectId,
        'knowledgeUnitId': payload.knowledgeUnitId!,
      },
    ).toString(),
    TodayPlanActionType.richClosedExercise => richClosedExerciseRoutePathFor(
      subjectId: payload.subjectId,
      documentId: payload.documentId ?? item.documentId,
      knowledgeUnitId: payload.knowledgeUnitId,
    ),
    TodayPlanActionType.revisionSession => revisionSessionRoutePathFor(
      subjectId: payload.subjectId,
      documentId: payload.documentId ?? item.documentId,
      knowledgeUnitId: payload.knowledgeUnitId,
      preferredAction: _preferredActionValue(payload.preferredAction),
    ),
  };
}

String _targetTitle(TodayPlanItem item) {
  final knowledgeUnitTitle = item.knowledgeUnitTitle?.trim();
  if (knowledgeUnitTitle != null && knowledgeUnitTitle.isNotEmpty) {
    return knowledgeUnitTitle;
  }

  final subjectName = item.subjectName.trim();
  return subjectName.isEmpty ? 'À travailler aujourd’hui' : subjectName;
}

String _sessionMeta(TodayPlanItem item) {
  final minutes = item.estimatedMinutes;
  if (minutes <= 0) {
    return 'Session guidée';
  }

  return '$minutes min · session guidée';
}

String _shortSessionMeta(TodayPlanItem item) {
  final minutes = item.estimatedMinutes;
  if (minutes <= 0) {
    return 'session guidée';
  }

  return '$minutes min';
}

String _recommendationReason(TodayPlanItem item) {
  return switch (item.reasonCode) {
    TodayPlanReasonCode.lowMastery =>
      'Cette notion semble fragile : la revoir maintenant aidera à consolider tes bases.',
    TodayPlanReasonCode.stalePractice =>
      'Tu ne l’as pas travaillée récemment. C’est un bon moment pour l’entretenir.',
    TodayPlanReasonCode.highPrioritySubject =>
      'Cette matière est prioritaire dans ton plan de révision.',
    TodayPlanReasonCode.mixActivityType =>
      'Changer d’angle peut t’aider à mieux ancrer la notion.',
    TodayPlanReasonCode.richClosedPractice =>
      'Cette notion mérite une session cadrée avec feedback.',
    TodayPlanReasonCode.startRevisionSession =>
      'Neralune a assez de contexte pour te guider sans te disperser.',
    TodayPlanReasonCode.continueProgress =>
      'Tu as déjà commencé ici : reprendre maintenant garde l’élan.',
  };
}

String? _preferredActionValue(TodayPlanPreferredAction? preferredAction) {
  return switch (preferredAction) {
    TodayPlanPreferredAction.diagnosticQuiz => 'diagnostic_quiz',
    TodayPlanPreferredAction.openQuestion => 'open_question',
    null => null,
  };
}
