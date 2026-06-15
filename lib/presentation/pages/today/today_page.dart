import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/core/routing/route_paths.dart';
import 'package:revision_app/features/today/application/today_notifier.dart';
import 'package:revision_app/features/today/domain/today_plan.dart';
import 'package:revision_app/presentation/theme/app_colors.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_icon_badge.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';
import 'package:revision_app/presentation/widgets/revision_page.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';
import 'package:revision_app/presentation/widgets/revision_progress_bar.dart';
import 'package:revision_app/presentation/widgets/revision_status_pill.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(todayNotifierProvider);
    final notifier = ref.read(todayNotifierProvider.notifier);

    return RevisionPage(
      title: 'Plan du jour',
      subtitle: 'Actions prioritaires pour avancer sans te disperser.',
      trailing: IconButton(
        onPressed: notifier.reload,
        icon: const Icon(Icons.refresh),
        tooltip: 'Recharger',
      ),
      children: [
        plan.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              _TodayErrorState(onRetry: notifier.reload),
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

class _TodayPlanContent extends StatelessWidget {
  const _TodayPlanContent({required this.plan});

  final TodayPlan plan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.itemGap,
      children: [
        RevisionPanel(
          child: Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              RevisionStatusPill(
                label: '${plan.items.length} actions',
                icon: Icons.playlist_add_check,
                color: AppColors.primaryDark,
              ),
              RevisionStatusPill(
                label: '${plan.totalEstimatedMinutes} min',
                icon: Icons.schedule,
                color: AppColors.aqua,
              ),
            ],
          ),
        ),
        for (final item in plan.items) _TodayPlanItemCard(item: item),
      ],
    );
  }
}

class _TodayPlanItemCard extends StatelessWidget {
  const _TodayPlanItemCard({required this.item});

  final TodayPlanItem item;

  @override
  Widget build(BuildContext context) {
    final action = _TodayActionPresentation.from(item.action);
    final canStart = _canStartAction(item);
    final masteryScore = item.masteryScore;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RevisionIconBadge(icon: action.icon, color: action.color),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _targetLabel(item),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            item.reason,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              RevisionStatusPill(
                label: '${item.estimatedMinutes} min',
                icon: Icons.schedule,
                color: AppColors.aqua,
              ),
              RevisionStatusPill(
                label: 'Priorité ${item.priority}',
                icon: Icons.flag,
                color: AppColors.amber,
              ),
              RevisionStatusPill(
                label: _reasonCodeLabel(item.reasonCode),
                icon: Icons.lightbulb_outline,
                color: AppColors.violet,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          if (masteryScore == null)
            Text(
              'Maîtrise non mesurée',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else ...[
            RevisionProgressBar(value: masteryScore),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Maîtrise ${(_clampMastery(masteryScore) * 100).round()} %',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: AppSpacing.l),
          Align(
            alignment: Alignment.centerLeft,
            child: RevisionButton(
              onPressed: canStart ? () => context.go(_routeFor(item)) : null,
              icon: canStart ? action.icon : Icons.lock_outline,
              label: canStart ? action.buttonLabel : 'Action indisponible',
            ),
          ),
        ],
      ),
    );
  }

  bool _canStartAction(TodayPlanItem item) {
    final subjectId = item.startPayload.subjectId.trim();
    if (subjectId.isEmpty) {
      return false;
    }

    if (item.action == TodayPlanActionType.openQuestion) {
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
      TodayPlanActionType.revisionSession => revisionSessionRoutePathFor(
        subjectId: payload.subjectId,
        knowledgeUnitId: payload.knowledgeUnitId,
        preferredAction: _preferredActionValue(payload.preferredAction),
      ),
    };
  }

  String _targetLabel(TodayPlanItem item) {
    final knowledgeUnitTitle = item.knowledgeUnitTitle?.trim();
    if (knowledgeUnitTitle == null || knowledgeUnitTitle.isEmpty) {
      return item.subjectName;
    }

    return '${item.subjectName} • $knowledgeUnitTitle';
  }

  String _reasonCodeLabel(TodayPlanReasonCode reasonCode) {
    return switch (reasonCode) {
      TodayPlanReasonCode.lowMastery => 'Maîtrise fragile',
      TodayPlanReasonCode.stalePractice => 'À entretenir',
      TodayPlanReasonCode.highPrioritySubject => 'Matière prioritaire',
      TodayPlanReasonCode.mixActivityType => 'Format varié',
      TodayPlanReasonCode.startRevisionSession => 'Session guidée',
      TodayPlanReasonCode.continueProgress => 'Progression',
    };
  }

  String? _preferredActionValue(TodayPlanPreferredAction? preferredAction) {
    return switch (preferredAction) {
      TodayPlanPreferredAction.diagnosticQuiz => 'diagnostic_quiz',
      TodayPlanPreferredAction.openQuestion => 'open_question',
      null => null,
    };
  }

  double _clampMastery(double score) {
    return score.clamp(0, 1).toDouble();
  }
}

class _TodayActionPresentation {
  const _TodayActionPresentation({
    required this.title,
    required this.buttonLabel,
    required this.icon,
    required this.color,
  });

  final String title;
  final String buttonLabel;
  final IconData icon;
  final Color color;

  static _TodayActionPresentation from(TodayPlanActionType action) {
    return switch (action) {
      TodayPlanActionType.diagnosticQuiz => const _TodayActionPresentation(
        title: 'QCM ciblé',
        buttonLabel: 'Démarrer le QCM',
        icon: Icons.quiz,
        color: AppColors.primaryDark,
      ),
      TodayPlanActionType.openQuestion => const _TodayActionPresentation(
        title: 'Question ouverte',
        buttonLabel: 'Répondre à la question',
        icon: Icons.edit_note,
        color: AppColors.aqua,
      ),
      TodayPlanActionType.revisionSession => const _TodayActionPresentation(
        title: 'Session de révision IA',
        buttonLabel: 'Lancer la session',
        icon: Icons.auto_awesome,
        color: AppColors.violet,
      ),
    };
  }
}

class _TodayEmptyState extends StatelessWidget {
  const _TodayEmptyState();

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aucune action prioritaire pour aujourd’hui.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Ajoute une matière, importe un document ou définis un objectif pour générer ton plan.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.l),
          RevisionButton(
            onPressed: () => context.go(subjectsRoutePath),
            icon: Icons.menu_book,
            label: 'Voir mes matières',
            style: RevisionButtonStyle.ghost,
          ),
        ],
      ),
    );
  }
}

class _TodayErrorState extends StatelessWidget {
  const _TodayErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RevisionMessage(
          message: 'Impossible de charger le plan',
          icon: Icons.error_outline,
          color: AppColors.danger,
        ),
        const SizedBox(height: AppSpacing.m),
        RevisionButton(
          onPressed: onRetry,
          icon: Icons.refresh,
          label: 'Réessayer',
          style: RevisionButtonStyle.ghost,
        ),
      ],
    );
  }
}
