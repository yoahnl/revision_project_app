import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../../../presentation/pages/activities/open_question_page.dart';
import '../../../presentation/widgets/revision_button.dart';
import '../application/courses_providers.dart';
import '../domain/course_models.dart';
import '../domain/courses_repository.dart';
import 'course_not_found_page.dart';
import 'utils/course_source_display_label.dart';

class CourseDeepRevisionResultPage extends ConsumerWidget {
  const CourseDeepRevisionResultPage({
    required this.courseId,
    required this.sessionId,
    super.key,
  });

  final String courseId;
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(
      courseDeepRevisionResultProvider((
        courseId: courseId,
        sessionId: sessionId,
      )),
    );

    return RevisionPageScaffold(
      headerChildren: [
        Row(
          children: [
            IconButton(
              tooltip: 'Retour au cours',
              onPressed: () => _popOrGo(context, AppRoutes.course(courseId)),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ],
        ),
        Text(
          'Résultat de révision approfondie',
          style: RevisionTypography.hero,
        ),
        Text(
          'Relis ta réponse et la correction détaillée.',
          style: RevisionTypography.body,
        ),
      ],
      children: [
        result.when(
          loading: () =>
              const RevisionLoadingState(label: 'Chargement du résultat...'),
          error: (error, stackTrace) {
            if (error is CourseNotFoundException) {
              return CourseNotFoundPage(courseId: courseId);
            }

            return RevisionErrorState(
              title: _resultErrorTitle(error),
              message: 'Impossible de relire ce résultat pour le moment.',
              actionLabel: 'Réessayer',
              onAction: () => ref.invalidate(
                courseDeepRevisionResultProvider((
                  courseId: courseId,
                  sessionId: sessionId,
                )),
              ),
            );
          },
          data: (result) => _CourseDeepRevisionResultContent(
            courseId: courseId,
            result: result,
          ),
        ),
      ],
    );
  }
}

class _CourseDeepRevisionResultContent extends StatelessWidget {
  const _CourseDeepRevisionResultContent({
    required this.courseId,
    required this.result,
  });

  final String courseId;
  final CourseDeepRevisionResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RevisionGlassCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RevisionIconTile(
                icon: Icons.menu_book_rounded,
                accent: RevisionColors.violet,
                size: 44,
              ),
              const SizedBox(width: RevisionSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.scope.label,
                      style: RevisionTypography.sectionTitle,
                    ),
                    const SizedBox(height: RevisionSpacing.xs),
                    Text(
                      humanSourceLabelText(result.scope.sourceLabel, index: 0),
                      style: RevisionTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: RevisionSpacing.m),
        RevisionGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Question', style: RevisionTypography.sectionTitle),
              const SizedBox(height: RevisionSpacing.s),
              Text(result.question.prompt, style: RevisionTypography.body),
              if (result.question.instructions != null) ...[
                const SizedBox(height: RevisionSpacing.s),
                Text(
                  result.question.instructions!,
                  style: RevisionTypography.caption,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: RevisionSpacing.m),
        RevisionGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Réponse envoyée', style: RevisionTypography.sectionTitle),
              const SizedBox(height: RevisionSpacing.s),
              Text(result.answer.text, style: RevisionTypography.body),
            ],
          ),
        ),
        const SizedBox(height: RevisionSpacing.m),
        OpenAnswerEvaluationPanel(evaluation: result.evaluation),
        const SizedBox(height: RevisionSpacing.m),
        RevisionButton(
          label: 'Retour au cours',
          icon: Icons.arrow_back_rounded,
          style: RevisionButtonStyle.ghost,
          onPressed: () => _popOrGo(context, AppRoutes.course(courseId)),
        ),
      ],
    );
  }
}

String _resultErrorTitle(Object error) {
  if (error is CourseRequestException && error.message.trim().isNotEmpty) {
    return error.message;
  }

  return 'Résultat indisponible';
}

void _popOrGo(BuildContext context, String fallback) {
  if (context.canPop()) {
    context.pop();
    return;
  }

  context.go(fallback);
}
