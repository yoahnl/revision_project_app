import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_radius.dart';
import '../../../presentation/design_system/tokens/revision_shadows.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/mvp_study_controller.dart';
import '../domain/mvp_study_models.dart';

class MvpTopBar extends StatelessWidget {
  const MvpTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MvpStudyController.instance,
      builder: (context, child) {
        final subject = MvpStudyController.instance.activeSubject;

        return Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: RevisionSubjectSwitcher(
                  label: subject.name,
                  accent: subject.accent,
                  icon: subject.icon,
                  onTap: () => showMvpSubjectSheet(context),
                ),
              ),
            ),
            const RevisionTopCounters(),
          ],
        );
      },
    );
  }
}

class MvpBackBar extends StatelessWidget {
  const MvpBackBar({this.title, this.trailing, super.key});

  final String? title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }

            context.go(AppRoutes.home);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: RevisionColors.text,
          tooltip: 'Retour',
        ),
        Expanded(
          child: Text(
            title ?? '',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RevisionTypography.sectionTitle,
          ),
        ),
        trailing ?? const SizedBox(width: 48),
      ],
    );
  }
}

Future<void> showMvpSubjectSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return _MvpSheetFrame(
        title: 'Changer de matière',
        child: AnimatedBuilder(
          animation: MvpStudyController.instance,
          builder: (context, child) {
            final controller = MvpStudyController.instance;
            final active = controller.activeSubject;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final subject in controller.subjects) ...[
                  RevisionGlassCard(
                    selected: active.id == subject.id,
                    onTap: () {
                      controller.selectSubject(subject.id);
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: [
                        RevisionIconTile(
                          icon: subject.icon,
                          accent: subject.accent,
                        ),
                        const SizedBox(width: RevisionSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject.name,
                                style: RevisionTypography.sectionTitle,
                              ),
                              const SizedBox(height: RevisionSpacing.xs),
                              Text(
                                subject.subtitle,
                                style: RevisionTypography.body,
                              ),
                            ],
                          ),
                        ),
                        if (active.id == subject.id)
                          Icon(
                            Icons.check_circle_rounded,
                            color: subject.accent,
                          ),
                      ],
                    ),
                  ),
                  if (subject != controller.subjects.last)
                    const SizedBox(height: RevisionSpacing.m),
                ],
                const SizedBox(height: RevisionSpacing.l),
                RevisionGradientButton(
                  label: 'Ajouter une matière',
                  icon: Icons.add_rounded,
                  expanded: true,
                  onPressed: () {},
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

Future<void> showMvpSourcesSheet(BuildContext context, MvpCourse course) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return _MvpSheetFrame(
        title: 'Sources',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final source in course.sources) ...[
              RevisionSourceFileCard(
                fileName: source.fileName,
                sizeLabel: source.sizeLabel,
                statusLabel: source.statusLabel,
              ),
              if (source != course.sources.last)
                const SizedBox(height: RevisionSpacing.m),
            ],
            const SizedBox(height: RevisionSpacing.xl),
            Center(
              child: RevisionFloatingAddButton(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Ajout de source branché au backend au lot suivant.',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _MvpSheetFrame extends StatelessWidget {
  const _MvpSheetFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: RevisionSpacing.l,
        right: RevisionSpacing.l,
        bottom: MediaQuery.of(context).viewInsets.bottom + RevisionSpacing.l,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: RevisionColors.glassStrong,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(RevisionRadius.xxl),
            bottom: Radius.circular(RevisionRadius.xl),
          ),
          border: Border.all(color: RevisionColors.borderBright),
          boxShadow: RevisionShadows.nav,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            RevisionSpacing.l,
            RevisionSpacing.m,
            RevisionSpacing.l,
            RevisionSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 52,
                  height: 4,
                  decoration: BoxDecoration(
                    color: RevisionColors.borderBright,
                    borderRadius: RevisionRadius.pill,
                  ),
                ),
              ),
              const SizedBox(height: RevisionSpacing.l),
              Text(title, style: RevisionTypography.pageTitle),
              const SizedBox(height: RevisionSpacing.l),
              Flexible(child: SingleChildScrollView(child: child)),
            ],
          ),
        ),
      ),
    );
  }
}

Widget mvpLearnItem(String label, {Color color = RevisionColors.green}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(Icons.check_circle_rounded, color: color, size: 18),
      const SizedBox(width: RevisionSpacing.s),
      Expanded(child: Text(label, style: RevisionTypography.body)),
    ],
  );
}

Widget mvpSmallPill({
  required IconData icon,
  required String label,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: RevisionSpacing.m,
      vertical: RevisionSpacing.s,
    ),
    decoration: BoxDecoration(
      color: RevisionColors.glassSoft,
      borderRadius: RevisionRadius.pill,
      border: Border.all(color: RevisionColors.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: RevisionSpacing.xs),
        Text(
          label,
          style: RevisionTypography.caption.copyWith(
            color: RevisionColors.text,
          ),
        ),
      ],
    ),
  );
}
