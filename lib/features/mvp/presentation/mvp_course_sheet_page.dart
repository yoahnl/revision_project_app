import 'package:flutter/material.dart';

import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/mvp_study_controller.dart';
import '../domain/mvp_study_models.dart';
import 'mvp_page_helpers.dart';

class MvpCourseSheetPage extends StatefulWidget {
  const MvpCourseSheetPage({required this.courseId, super.key});

  final String courseId;

  @override
  State<MvpCourseSheetPage> createState() => _MvpCourseSheetPageState();
}

class _MvpCourseSheetPageState extends State<MvpCourseSheetPage> {
  MvpRevisionMode _mode = MvpRevisionMode.quick;

  @override
  Widget build(BuildContext context) {
    final course = MvpStudyController.instance.courseOrFallback(
      widget.courseId,
    );

    return RevisionPageScaffold(
      children: [
        MvpBackBar(
          title: course.title,
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.ios_share_rounded),
            color: RevisionColors.text,
            tooltip: 'Partager',
          ),
        ),
        RevisionSegmentedControl<MvpRevisionMode>(
          values: MvpRevisionMode.values,
          selected: _mode,
          labelOf: (mode) => mode.label,
          onChanged: (mode) => setState(() => _mode = mode),
        ),
        _SheetPanel(
          icon: Icons.summarize_rounded,
          iconColor: RevisionColors.blue,
          title: 'Résumé',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _summaryFor(course, _mode),
                style: RevisionTypography.body.copyWith(
                  color: RevisionColors.text,
                ),
              ),
              if (course.id == 'loi-normale') ...[
                const SizedBox(height: RevisionSpacing.m),
                Center(
                  child: Text(
                    'X ~ N(μ, σ²)',
                    style: RevisionTypography.sectionTitle.copyWith(
                      color: RevisionColors.blue,
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        _SheetPanel(
          icon: Icons.check_rounded,
          iconColor: RevisionColors.green,
          title: 'Points clés',
          child: Column(
            children: [
              for (final point in course.keyPoints) ...[
                _BulletLine(label: point, color: RevisionColors.mint),
                if (point != course.keyPoints.last)
                  const SizedBox(height: RevisionSpacing.s),
              ],
            ],
          ),
        ),
        _SheetPanel(
          icon: Icons.warning_rounded,
          iconColor: RevisionColors.coral,
          title: 'Pièges fréquents',
          child: Column(
            children: [
              for (final mistake in course.commonMistakes) ...[
                _BulletLine(label: mistake, color: RevisionColors.textMuted),
                if (mistake != course.commonMistakes.last)
                  const SizedBox(height: RevisionSpacing.s),
              ],
              if (course.sources.isNotEmpty) ...[
                const SizedBox(height: RevisionSpacing.m),
                RevisionSourceFileCard(
                  fileName: 'Source : ${course.sources.first.fileName}',
                  sizeLabel: course.sources.first.sizeLabel,
                  statusLabel: course.sources.first.statusLabel,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SheetPanel extends StatelessWidget {
  const _SheetPanel({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RevisionIconTile(
                icon: icon,
                accent: iconColor,
                size: 26,
                iconSize: 16,
              ),
              const SizedBox(width: RevisionSpacing.s),
              Text(title, style: RevisionTypography.sectionTitle),
            ],
          ),
          const SizedBox(height: RevisionSpacing.m),
          child,
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('•', style: RevisionTypography.body.copyWith(color: color)),
        const SizedBox(width: RevisionSpacing.s),
        Expanded(
          child: Text(
            label,
            style: RevisionTypography.body.copyWith(color: RevisionColors.text),
          ),
        ),
      ],
    );
  }
}

String _summaryFor(MvpCourse course, MvpRevisionMode mode) {
  return switch (mode) {
    MvpRevisionMode.quick =>
      '${course.title} : l’essentiel à retenir pour répondre vite sans perdre le fil.',
    MvpRevisionMode.deep => course.description,
    MvpRevisionMode.exam =>
      '${course.title} : méthode, points clés et pièges à repérer avant le jour J.',
  };
}
