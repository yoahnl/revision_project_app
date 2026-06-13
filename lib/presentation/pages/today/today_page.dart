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
      subtitle: 'Priorites adaptees a ta progression.',
      trailing: IconButton(
        onPressed: notifier.reload,
        icon: const Icon(Icons.refresh),
        tooltip: 'Recharger',
      ),
      children: [
        plan.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, stackTrace) =>
              _TodayErrorState(onRetry: notifier.reload),
          data: (plan) {
            if (plan.items.isEmpty) {
              return const Text('Aucune revision prioritaire');
            }

            return Column(
              spacing: AppSpacing.itemGap,
              children: [
                for (final item in plan.items) _TodayPlanItemCard(item: item),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TodayPlanItemCard extends StatelessWidget {
  const _TodayPlanItemCard({required this.item});

  final TodayPlanItem item;

  @override
  Widget build(BuildContext context) {
    final scoreLabel = '${(item.masteryScore * 100).round()} %';

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const RevisionIconBadge(
                icon: Icons.auto_awesome,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subjectName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.knowledgeUnitTitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              RevisionStatusPill(
                label: scoreLabel,
                color: AppColors.primaryDark,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          RevisionProgressBar(value: item.masteryScore),
          const SizedBox(height: AppSpacing.s),
          Text('Maitrise $scoreLabel'),
          const SizedBox(height: AppSpacing.l),
          Align(
            alignment: Alignment.centerLeft,
            child: RevisionButton(
              onPressed: () => context.go(
                Uri(
                  path: activitiesRoutePath,
                  queryParameters: {'subjectId': item.subjectId},
                ).toString(),
              ),
              icon: Icons.play_arrow,
              label: 'Demarrer ${item.estimatedMinutes} min',
            ),
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
        Text(
          'Impossible de charger le plan',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        RevisionButton(
          onPressed: onRetry,
          icon: Icons.refresh,
          label: 'Reessayer',
          style: RevisionButtonStyle.ghost,
        ),
      ],
    );
  }
}
