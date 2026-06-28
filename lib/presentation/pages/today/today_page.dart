import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/app/router/app_routes.dart';
import 'package:Neralune/core/routing/route_paths.dart';
import 'package:Neralune/features/courses/application/active_subject_provider.dart';
import 'package:Neralune/features/courses/application/courses_providers.dart';
import 'package:Neralune/features/courses/domain/course_models.dart';
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
              return const _TodayCoachFallback();
            }

            return _TodayPlanContent(plan: plan);
          },
        ),
      ],
    );
  }
}

class _TodayCoachFallback extends ConsumerWidget {
  const _TodayCoachFallback();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSubject = ref.watch(activeSubjectProvider);

    return activeSubject.when(
      loading: () => const RevisionLoadingState(
        label: 'Recherche de ta prochaine mission...',
      ),
      error: (error, stackTrace) => _TodayFallbackErrorState(
        onRetry: () => ref.invalidate(activeSubjectProvider),
      ),
      data: (subject) {
        if (subject == null) {
          return const _NoCourseMissionCard();
        }

        final courses = ref.watch(coursesProvider(subject.id));

        return courses.when(
          loading: () => const RevisionLoadingState(
            label: 'Recherche de ta prochaine mission...',
          ),
          error: (error, stackTrace) => _TodayFallbackErrorState(
            onRetry: () => ref.invalidate(coursesProvider(subject.id)),
          ),
          data: (courses) {
            if (courses.isEmpty) {
              return const _NoCourseMissionCard();
            }

            return _CourseMissionFallback(course: _bestFallbackCourse(courses));
          },
        );
      },
    );
  }
}

class _CourseMissionFallback extends StatelessWidget {
  const _CourseMissionFallback({required this.course});

  final CourseListItem course;

  @override
  Widget build(BuildContext context) {
    final visual = revisionSubjectVisualThemeFor(course.title);
    final hasReadySheet = course.readySourceCount > 0;
    final title = hasReadySheet ? 'Ta mission du jour' : 'Continue ton cours';
    final badge = hasReadySheet
        ? 'Questions en préparation'
        : 'Parcours à reprendre';
    final headline = hasReadySheet ? 'Ta fiche est prête' : course.title;
    final message = hasReadySheet
        ? 'Ta fiche est prête. Les questions arrivent bientôt.'
        : 'Reprends le parcours et choisis la prochaine notion.';
    final primaryLabel = hasReadySheet ? 'Lire la fiche' : 'Voir le cours';
    final primaryRoute = hasReadySheet
        ? courseSheetRoutePath(course.id, from: AppRoutes.courseSheetFromToday)
        : courseRoutePath(course.id);
    final secondaryLabel = hasReadySheet
        ? 'Voir le parcours'
        : 'Ouvrir les cours';
    final secondaryRoute = hasReadySheet
        ? courseRoutePath(course.id)
        : homeRoutePath;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RevisionGlassCard(
          padding: const EdgeInsets.all(RevisionSpacing.l),
          borderColor: visual.accent.withValues(alpha: 0.46),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              visual.accent.withValues(alpha: 0.34),
              RevisionColors.blueDeep.withValues(alpha: 0.22),
              RevisionColors.glassStrong,
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: RevisionTypography.sectionTitle),
              const SizedBox(height: RevisionSpacing.s),
              _StatusPill(label: badge, accent: visual.accent),
              const SizedBox(height: RevisionSpacing.l),
              Text(headline, style: RevisionTypography.pageTitle),
              const SizedBox(height: RevisionSpacing.s),
              Text(
                _courseMeta(course),
                style: RevisionTypography.body.copyWith(
                  color: RevisionColors.text.withValues(alpha: 0.82),
                ),
              ),
              const SizedBox(height: RevisionSpacing.m),
              Text(message, style: RevisionTypography.body),
              const SizedBox(height: RevisionSpacing.l),
              RevisionLightButton(
                label: primaryLabel,
                icon: hasReadySheet
                    ? Icons.menu_book_rounded
                    : Icons.route_rounded,
                expanded: true,
                onPressed: () => context.go(primaryRoute),
              ),
              const SizedBox(height: RevisionSpacing.s),
              RevisionGradientButton(
                label: secondaryLabel,
                icon: hasReadySheet
                    ? Icons.timeline_rounded
                    : Icons.folder_open_rounded,
                expanded: true,
                onPressed: () => context.go(secondaryRoute),
              ),
            ],
          ),
        ),
        const SizedBox(height: RevisionSpacing.l),
        const _HonestWeekGoalCard(),
        const SizedBox(height: RevisionSpacing.l),
        _ContinueCourseCard(course: course),
      ],
    );
  }
}

class _NoCourseMissionCard extends StatelessWidget {
  const _NoCourseMissionCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RevisionGlassCard(
          padding: const EdgeInsets.all(RevisionSpacing.l),
          borderColor: RevisionColors.blue.withValues(alpha: 0.38),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ta mission du jour',
                style: RevisionTypography.sectionTitle,
              ),
              const SizedBox(height: RevisionSpacing.l),
              const Text(
                'Prépare ta première matière',
                style: RevisionTypography.pageTitle,
              ),
              const SizedBox(height: RevisionSpacing.s),
              const Text(
                'Ajoute un cours ou une source pour que Neralune crée ta fiche et tes questions.',
                style: RevisionTypography.body,
              ),
              const SizedBox(height: RevisionSpacing.l),
              RevisionGradientButton(
                label: 'Ouvrir les cours',
                icon: Icons.folder_open_rounded,
                expanded: true,
                onPressed: () => context.go(homeRoutePath),
              ),
            ],
          ),
        ),
        const SizedBox(height: RevisionSpacing.l),
        const _HonestWeekGoalCard(),
      ],
    );
  }
}

class _TodayFallbackErrorState extends StatelessWidget {
  const _TodayFallbackErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.l),
      borderColor: RevisionColors.red.withValues(alpha: 0.42),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: RevisionColors.red,
            size: 30,
          ),
          const SizedBox(height: RevisionSpacing.m),
          const Text(
            'Impossible de charger Aujourd’hui',
            style: RevisionTypography.sectionTitle,
          ),
          const SizedBox(height: RevisionSpacing.s),
          const Text(
            'Réessaie ou ouvre tes cours.',
            style: RevisionTypography.body,
          ),
          const SizedBox(height: RevisionSpacing.l),
          RevisionLightButton(
            label: 'Réessayer',
            icon: Icons.refresh_rounded,
            expanded: true,
            onPressed: onRetry,
          ),
          const SizedBox(height: RevisionSpacing.s),
          RevisionGradientButton(
            label: 'Ouvrir les cours',
            icon: Icons.folder_open_rounded,
            expanded: true,
            onPressed: () => context.go(homeRoutePath),
          ),
        ],
      ),
    );
  }
}

class _HonestWeekGoalCard extends StatelessWidget {
  const _HonestWeekGoalCard();

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.l),
      borderColor: RevisionColors.borderBright.withValues(alpha: 0.34),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Objectif de la semaine',
            style: RevisionTypography.sectionTitle,
          ),
          SizedBox(height: RevisionSpacing.s),
          Text('Objectif à définir', style: RevisionTypography.body),
        ],
      ),
    );
  }
}

class _ContinueCourseCard extends StatelessWidget {
  const _ContinueCourseCard({required this.course});

  final CourseListItem course;

  @override
  Widget build(BuildContext context) {
    final visual = revisionSubjectVisualThemeFor(course.title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Continuer un cours',
          style: RevisionTypography.sectionTitle,
        ),
        const SizedBox(height: RevisionSpacing.m),
        RevisionGlassCard(
          onTap: () => context.go(courseRoutePath(course.id)),
          padding: const EdgeInsets.all(RevisionSpacing.m),
          borderColor: visual.accent.withValues(alpha: 0.30),
          child: Row(
            children: [
              RevisionIconTile(
                icon: visual.icon,
                accent: visual.accent,
                size: 48,
                iconSize: 24,
              ),
              const SizedBox(width: RevisionSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title, style: RevisionTypography.sectionTitle),
                    const SizedBox(height: RevisionSpacing.xs),
                    Text(_courseMeta(course), style: RevisionTypography.body),
                  ],
                ),
              ),
              const SizedBox(width: RevisionSpacing.s),
              const Icon(
                Icons.chevron_right_rounded,
                color: RevisionColors.textMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(
        horizontal: RevisionSpacing.s,
        vertical: RevisionSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.42)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: RevisionTypography.caption.copyWith(
          color: RevisionColors.text,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TodayHeader extends StatelessWidget {
  const _TodayHeader();

  @override
  Widget build(BuildContext context) {
    final greeting = _timeGreeting(DateTime.now());

    return RevisionPageHeader(
      title: greeting,
      subtitle: 'Ta session du jour',
      trailing: const _StaticLuna(),
    );
  }
}

class _StaticLuna extends StatelessWidget {
  const _StaticLuna();

  static const _asset = 'assets/brand/neralune_cat.svg';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Luna',
      child: ExcludeSemantics(
        child: SizedBox(
          key: const ValueKey('today-luna-static'),
          width: 86,
          height: 78,
          child: Stack(
            alignment: Alignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      RevisionColors.blue.withValues(alpha: 0.24),
                      RevisionColors.violet.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.52, 1],
                  ),
                ),
                child: const SizedBox.expand(),
              ),
              SvgPicture.asset(_asset, fit: BoxFit.contain),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayPlanContent extends StatelessWidget {
  const _TodayPlanContent({required this.plan});

  final TodayPlan plan;

  @override
  Widget build(BuildContext context) {
    final primaryItem = _primaryItemFor(plan);
    final continuationItem = _continuationItemFor(plan, primaryItem);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PrimarySessionCard(item: primaryItem),
        if (plan.weeklyObjective != null) ...[
          const SizedBox(height: RevisionSpacing.l),
          _WeeklyObjectiveCard(objective: plan.weeklyObjective!),
        ],
        if (continuationItem != null) ...[
          const SizedBox(height: RevisionSpacing.l),
          _ContinuationSection(item: continuationItem),
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
    final unavailableReason =
        _cleanLabel(item.display?.unavailableReason) ??
        'Cette action n’est pas encore prête.';

    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.l),
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
                  children: [_SubjectBadge(item: item, visual: visual)],
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
          const SizedBox(height: RevisionSpacing.l),
          Text(_displayTitle(item), style: RevisionTypography.pageTitle),
          const SizedBox(height: RevisionSpacing.s),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                color: RevisionColors.textMuted,
                size: 18,
              ),
              const SizedBox(width: RevisionSpacing.xs),
              Expanded(
                child: Text(
                  _displayMetaLabel(item),
                  style: RevisionTypography.body.copyWith(
                    color: RevisionColors.text.withValues(alpha: 0.84),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: RevisionSpacing.l),
          Text(_displayRecommendation(item), style: RevisionTypography.body),
          const SizedBox(height: RevisionSpacing.l),
          _PrimarySessionButton(
            label: canStart ? 'Réviser maintenant' : 'Session indisponible',
            icon: canStart
                ? Icons.play_arrow_rounded
                : Icons.lock_outline_rounded,
            onPressed: route == null ? null : () => context.go(route),
          ),
          if (canStart) ...[
            const SizedBox(height: RevisionSpacing.m),
            Center(
              child: TextButton(
                onPressed: () => context.go(homeRoutePath),
                style: TextButton.styleFrom(
                  foregroundColor: RevisionColors.textMuted,
                  textStyle: RevisionTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Changer de cours'),
              ),
            ),
          ] else ...[
            const SizedBox(height: RevisionSpacing.m),
            Text(unavailableReason, style: RevisionTypography.caption),
          ],
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
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(
        horizontal: RevisionSpacing.m,
        vertical: RevisionSpacing.s,
      ),
      decoration: BoxDecoration(
        color: visual.accent.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: visual.accent.withValues(alpha: 0.58)),
      ),
      child: Text(
        _displayBadgeLabel(item),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: RevisionTypography.sectionTitle.copyWith(
          color: RevisionColors.text,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PrimarySessionButton extends StatelessWidget {
  const _PrimarySessionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Opacity(
          opacity: enabled ? 1 : 0.58,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: RevisionColors.text,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: RevisionSpacing.l,
                vertical: RevisionSpacing.m,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: RevisionColors.blueDeep, size: 22),
                  const SizedBox(width: RevisionSpacing.s),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: RevisionColors.blueDeep,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinuationSection extends StatelessWidget {
  const _ContinuationSection({required this.item});

  final TodayPlanItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Continuer', style: RevisionTypography.sectionTitle),
        const SizedBox(height: RevisionSpacing.m),
        _ContinuationTile(item: item),
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
    final masteryScore = item.masteryScore;

    return RevisionGlassCard(
      onTap: route == null ? null : () => context.go(route),
      padding: const EdgeInsets.all(RevisionSpacing.m),
      borderColor: visual.accent.withValues(alpha: 0.30),
      child: AnimatedOpacity(
        opacity: canStart ? 1 : 0.58,
        duration: const Duration(milliseconds: 160),
        child: Row(
          children: [
            RevisionIconTile(
              icon: visual.icon,
              accent: visual.accent,
              size: 48,
              iconSize: 24,
            ),
            const SizedBox(width: RevisionSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayTitle(item),
                    style: RevisionTypography.sectionTitle,
                  ),
                  const SizedBox(height: RevisionSpacing.xs),
                  Text(_continuationMeta(item), style: RevisionTypography.body),
                ],
              ),
            ),
            const SizedBox(width: RevisionSpacing.s),
            if (masteryScore != null)
              RevisionMasteryRing(
                value: masteryScore,
                label: '${(masteryScore.clamp(0, 1) * 100).round()}%',
                size: 54,
                color: visual.accent,
              ),
            const SizedBox(width: RevisionSpacing.xs),
            Icon(
              canStart
                  ? Icons.chevron_right_rounded
                  : Icons.lock_outline_rounded,
              color: canStart
                  ? RevisionColors.textMuted
                  : RevisionColors.textFaint,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyObjectiveCard extends StatelessWidget {
  const _WeeklyObjectiveCard({required this.objective});

  final TodayWeeklyObjective objective;

  @override
  Widget build(BuildContext context) {
    final progressRatio = objective.progressRatio;

    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.l),
      borderColor: RevisionColors.borderBright.withValues(alpha: 0.42),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Objectif de la semaine',
                  style: RevisionTypography.sectionTitle,
                ),
              ),
              if (progressRatio != null)
                Text(
                  '${(progressRatio.clamp(0, 1) * 100).round()}%',
                  style: RevisionTypography.sectionTitle,
                ),
            ],
          ),
          const SizedBox(height: RevisionSpacing.s),
          Text(objective.label, style: RevisionTypography.body),
        ],
      ),
    );
  }
}

TodayPlanItem _primaryItemFor(TodayPlan plan) {
  final primaryItemId = plan.primaryItemId;
  if (primaryItemId == null) {
    return plan.items.first;
  }

  return plan.items.firstWhere(
    (item) => item.id == primaryItemId,
    orElse: () => plan.items.first,
  );
}

TodayPlanItem? _continuationItemFor(TodayPlan plan, TodayPlanItem primaryItem) {
  final candidates = plan.continuationItemIds.isEmpty
      ? plan.items.where((item) => item.id != primaryItem.id)
      : plan.continuationItemIds
            .map((id) => _findItemById(plan.items, id))
            .whereType<TodayPlanItem>();

  for (final item in candidates) {
    if (_isSameVisibleTarget(primaryItem, item)) {
      continue;
    }

    return item;
  }

  return null;
}

TodayPlanItem? _findItemById(List<TodayPlanItem> items, String id) {
  for (final item in items) {
    if (item.id == id) {
      return item;
    }
  }

  return null;
}

CourseListItem _bestFallbackCourse(List<CourseListItem> courses) {
  for (final course in courses) {
    if (course.readySourceCount > 0) {
      return course;
    }
  }

  for (final course in courses) {
    if (course.sourceCount > 0 || course.processingSourceCount > 0) {
      return course;
    }
  }

  return courses.first;
}

String _courseMeta(CourseListItem course) {
  final parts = <String>[];
  if (course.estimatedMinutes != null && course.estimatedMinutes! > 0) {
    parts.add('${course.estimatedMinutes} min');
  }

  if (course.readySourceCount > 0) {
    parts.add('${course.readySourceCount} source prête');
  } else if (course.processingSourceCount > 0) {
    parts.add('Analyse en cours');
  } else if (course.sourceCount > 0) {
    parts.add('${course.sourceCount} source ajoutée');
  } else {
    parts.add('Parcours à préparer');
  }

  return parts.join(' · ');
}

bool _isSameVisibleTarget(TodayPlanItem a, TodayPlanItem b) {
  return _displayTitle(a) == _displayTitle(b) &&
      _displaySubjectLabel(a) == _displaySubjectLabel(b);
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

String _displayTitle(TodayPlanItem item) {
  return _cleanLabel(item.display?.title) ?? _targetTitle(item);
}

String _displaySubjectLabel(TodayPlanItem item) {
  return _cleanLabel(item.display?.subjectLabel) ??
      (item.subjectName.trim().isEmpty ? 'Matière' : item.subjectName.trim());
}

String _displayBadgeLabel(TodayPlanItem item) {
  return _cleanLabel(item.display?.badgeLabel) ??
      _displaySubjectLabel(item).toUpperCase();
}

String _displayMetaLabel(TodayPlanItem item) {
  return _cleanLabel(item.display?.metaLabel) ?? _sessionMeta(item);
}

String _displayRecommendation(TodayPlanItem item) {
  return _cleanLabel(item.display?.recommendation) ??
      _recommendationReason(item);
}

String _continuationMeta(TodayPlanItem item) {
  return _cleanLabel(item.display?.durationLabel) ??
      _cleanLabel(item.display?.metaLabel) ??
      _sessionMeta(item);
}

String? _cleanLabel(String? value) {
  final trimmed = value?.trim();

  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

String _timeGreeting(DateTime now) {
  return now.hour >= 18 ? 'Bonsoir' : 'Bonjour';
}

String? _preferredActionValue(TodayPlanPreferredAction? preferredAction) {
  return switch (preferredAction) {
    TodayPlanPreferredAction.diagnosticQuiz => 'diagnostic_quiz',
    TodayPlanPreferredAction.openQuestion => 'open_question',
    null => null,
  };
}
