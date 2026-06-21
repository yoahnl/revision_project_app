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
    unawaited(showQuickRevisionLoadingDialog(context, questionCount));
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(quickRevisionErrorLabel(error))));
  }
}

Future<void> showQuickRevisionLoadingDialog(
  BuildContext context,
  int questionCount,
) {
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
                'Préparation des questions',
                textAlign: TextAlign.center,
                style: RevisionTypography.sectionTitle,
              ),
              const SizedBox(height: RevisionSpacing.s),
              Text(
                '$questionCount questions sont chargées depuis la banque du cours.',
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
    if (error.message == 'Course quick revision questions are being prepared') {
      return 'Les questions sont en préparation. Réessaie dans un instant.';
    }

    return error.message;
  }

  if (error is CourseNotFoundException) {
    return 'Cours introuvable.';
  }

  return 'Impossible de démarrer la révision rapide.';
}
