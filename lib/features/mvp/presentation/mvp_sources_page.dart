import 'package:flutter/material.dart';

import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../application/mvp_study_controller.dart';
import 'mvp_page_helpers.dart';

class MvpSourcesPage extends StatelessWidget {
  const MvpSourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MvpStudyController.instance,
      builder: (context, child) {
        final controller = MvpStudyController.instance;
        final sources = controller.activeSources.toList();

        return RevisionPageScaffold(
          children: [
            const MvpTopBar(),
            RevisionSectionHeader(
              title: 'Sources',
              subtitle:
                  'Fichiers attachés aux cours de ${controller.activeSubject.name}',
            ),
            if (sources.isEmpty)
              const RevisionGlassCard(
                child: Text('Aucune source pour le moment.'),
              )
            else
              Column(
                children: [
                  for (final source in sources) ...[
                    RevisionSourceFileCard(
                      fileName: source.fileName,
                      sizeLabel: source.sizeLabel,
                      statusLabel: source.statusLabel,
                    ),
                    if (source != sources.last)
                      const SizedBox(height: RevisionSpacing.m),
                  ],
                ],
              ),
            Center(
              child: RevisionFloatingAddButton(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ajout de source prévu avec l’API Course.'),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
