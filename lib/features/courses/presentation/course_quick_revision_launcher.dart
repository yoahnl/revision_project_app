import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/courses_providers.dart';
import '../domain/course_models.dart';
import '../domain/courses_repository.dart';

Future<void> startCourseQuickRevisionFlow({
  required BuildContext context,
  required WidgetRef ref,
  required String courseId,
  required int questionCount,
}) async {
  var loadingDialogShown = false;
  try {
    loadingDialogShown = true;
    unawaited(showQuickRevisionLoadingDialog(context));
    final response = await ref
        .read(startCourseQuickRevisionControllerProvider.notifier)
        .start(courseId: courseId, questionCount: questionCount);

    if (!context.mounted) {
      return;
    }

    if (loadingDialogShown) {
      Navigator.of(context, rootNavigator: true).pop();
      loadingDialogShown = false;
    }
    context.go(
      AppRoutes.revisionSessionV2(
        sessionId: response.session.id,
        courseId: courseId,
        mode: 'quick',
      ),
    );
  } catch (error) {
    if (!context.mounted) {
      return;
    }

    if (loadingDialogShown) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    await showQuickRevisionUnavailableSheet(
      context: context,
      ref: ref,
      courseId: courseId,
      questionCount: questionCount,
      error: error,
    );
  }
}

Future<void> showQuickRevisionLoadingDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(RevisionSpacing.xl),
        child: RevisionGlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(
                  color: RevisionColors.blue,
                  strokeWidth: 4,
                ),
              ),
              const SizedBox(height: RevisionSpacing.l),
              Text(
                'Préparation de la session',
                textAlign: TextAlign.center,
                style: RevisionTypography.sectionTitle,
              ),
              const SizedBox(height: RevisionSpacing.s),
              Text(
                'Ta session courte se prépare.',
                textAlign: TextAlign.center,
                style: RevisionTypography.body,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

String quickRevisionErrorLabel(Object error) {
  if (error is CourseQuickRevisionUnavailableException) {
    if (_isQuestionsPreparing(error)) {
      return 'Les questions sont en préparation. Tu peux lire la fiche en attendant.';
    }

    if (_isTechnicalQuickRevisionMessage(error.message)) {
      return 'Impossible de lancer la session pour le moment.';
    }

    return error.message;
  }

  if (error is CourseNotFoundException) {
    return 'Cours introuvable.';
  }

  return 'Impossible de lancer la session pour le moment.';
}

Future<void> showQuickRevisionUnavailableSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String courseId,
  required int questionCount,
  required Object error,
}) {
  final isPreparing = _isQuestionsPreparing(error);
  final title = isPreparing
      ? 'Questions en préparation'
      : 'Session indisponible';
  final message = isPreparing
      ? 'Neralune prépare encore les questions de ce cours. Tu peux lire la fiche en attendant.'
      : 'Impossible de lancer la session pour le moment.';

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => RevisionBottomSheetFrame(
      title: title,
      subtitle: message,
      children: [
        _QuickRevisionUnavailableStateCard(isPreparing: isPreparing),
        RevisionGradientButton(
          label: isPreparing ? 'Lire la fiche' : 'Réessayer',
          icon: isPreparing ? Icons.menu_book_rounded : Icons.refresh_rounded,
          expanded: true,
          onPressed: () async {
            Navigator.of(sheetContext).pop();
            if (!context.mounted) {
              return;
            }

            if (isPreparing) {
              context.push(AppRoutes.courseSheet(courseId));
              return;
            }

            await startCourseQuickRevisionFlow(
              context: context,
              ref: ref,
              courseId: courseId,
              questionCount: questionCount,
            );
          },
        ),
        if (!isPreparing)
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(sheetContext).pop();
              if (context.mounted) {
                context.push(AppRoutes.courseSheet(courseId));
              }
            },
            icon: const Icon(Icons.menu_book_rounded),
            label: const Text('Lire la fiche'),
          ),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(sheetContext).pop();
            if (context.mounted) {
              context.go(AppRoutes.course(courseId));
            }
          },
          icon: const Icon(Icons.route_rounded),
          label: const Text('Voir le parcours'),
        ),
      ],
    ),
  );
}

bool _isQuestionsPreparing(Object error) {
  if (error is! CourseQuickRevisionUnavailableException) {
    return false;
  }

  final readiness = error.readiness;
  if (readiness?.status == CourseQuestionBankReadinessStatus.preparing) {
    return true;
  }

  final normalized = error.message.toUpperCase();
  return normalized.contains('COURSE_QUICK_REVISION_QUESTIONS_PREPARING') ||
      normalized.contains('QUESTIONS EN PRÉPARATION') ||
      normalized.contains('QUESTIONS EN PREPARATION') ||
      normalized.contains('BEING PREPARED');
}

bool _isTechnicalQuickRevisionMessage(String message) {
  final normalized = message.toUpperCase();
  return normalized.contains('COURSE_QUICK_REVISION') ||
      normalized.contains('409') ||
      normalized.contains('BACKEND') ||
      normalized.contains('PAYLOAD');
}

class _QuickRevisionUnavailableStateCard extends StatelessWidget {
  const _QuickRevisionUnavailableStateCard({required this.isPreparing});

  final bool isPreparing;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      borderColor: isPreparing
          ? RevisionColors.blue.withValues(alpha: 0.42)
          : RevisionColors.red.withValues(alpha: 0.34),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (isPreparing ? RevisionColors.blue : RevisionColors.red).withValues(
            alpha: 0.20,
          ),
          RevisionColors.glassStrong,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RevisionIconTile(
                icon: isPreparing
                    ? Icons.hourglass_top_rounded
                    : Icons.sync_problem_rounded,
                accent: isPreparing ? RevisionColors.blue : RevisionColors.red,
                size: 44,
              ),
              const SizedBox(width: RevisionSpacing.m),
              Expanded(
                child: Text(
                  isPreparing
                      ? 'Ta fiche reste disponible'
                      : 'On garde ton parcours intact',
                  style: RevisionTypography.sectionTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: RevisionSpacing.m),
          Wrap(
            spacing: RevisionSpacing.s,
            runSpacing: RevisionSpacing.s,
            children: [
              _RevisionStatusPill(
                label: 'Fiche prête',
                icon: Icons.menu_book_rounded,
                accent: RevisionColors.green,
              ),
              _RevisionStatusPill(
                label: isPreparing ? 'Bientôt prêtes' : 'Session à relancer',
                icon: isPreparing
                    ? Icons.hourglass_top_rounded
                    : Icons.refresh_rounded,
                accent: isPreparing ? RevisionColors.blue : RevisionColors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RevisionStatusPill extends StatelessWidget {
  const _RevisionStatusPill({
    required this.label,
    required this.icon,
    required this.accent,
  });

  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: accent.withValues(alpha: 0.28)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RevisionSpacing.s,
            vertical: RevisionSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: accent, size: 15),
              const SizedBox(width: RevisionSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RevisionTypography.caption.copyWith(
                    color: RevisionColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
