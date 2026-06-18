import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../../subjects/application/subjects_notifier.dart';
import '../../subjects/domain/subject.dart';
import '../application/active_subject_provider.dart';

class CoursesHomePage extends ConsumerWidget {
  const CoursesHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsNotifierProvider);
    final notifier = ref.read(subjectsNotifierProvider.notifier);

    return RevisionPageScaffold(
      children: [
        const _CoursesHeader(
          title: 'Accueil',
          subtitle:
              'Parcours réel en préparation, sans cours fictifs ni scores simulés.',
        ),
        subjects.when(
          loading: () => const RevisionLoadingState(
            label: 'Chargement des matières réelles',
          ),
          error: (error, stackTrace) => RevisionErrorState(
            title: 'Impossible de charger les matières',
            message:
                'Le parcours réel ne bascule pas vers des fixtures. Réessaie ou ouvre les matières existantes.',
            actionLabel: 'Réessayer',
            onAction: notifier.reload,
          ),
          data: (subjects) => _CoursesHomeContent(subjects: subjects),
        ),
      ],
    );
  }
}

class _CoursesHomeContent extends ConsumerWidget {
  const _CoursesHomeContent({required this.subjects});

  final List<Subject> subjects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (subjects.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RevisionEmptyState(
            title: 'Aucune matière réelle',
            message:
                'Crée une matière via le flow réel avant de rattacher des cours dans CORE-02.',
            icon: Icons.school_outlined,
            actionLabel: 'Ouvrir les matières',
            onAction: () => context.go(AppRoutes.subjects),
          ),
          const SizedBox(height: RevisionSpacing.l),
          const RevisionEmptyState(
            title: 'Aucun cours réel n’est encore branché',
            message:
                'Aucune fixture ne remplace les cours manquants. CORE-02 branchera les vrais cours ici.',
            icon: Icons.layers_outlined,
          ),
        ],
      );
    }

    final activeSubjectId = ref.watch(activeSubjectIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Matières réelles', style: RevisionTypography.sectionTitle),
        const SizedBox(height: RevisionSpacing.m),
        for (var index = 0; index < subjects.length; index++) ...[
          _SubjectCard(
            subject: subjects[index],
            accent: _accentFor(index),
            selected:
                activeSubjectId == subjects[index].id ||
                (activeSubjectId == null && index == 0),
            onTap: () {
              ref
                  .read(activeSubjectIdProvider.notifier)
                  .select(subjects[index].id);
              context.go(AppRoutes.subjectDetail(subjects[index].id));
            },
          ),
          const SizedBox(height: RevisionSpacing.m),
        ],
        RevisionEmptyState(
          title: 'Aucun cours réel n’est encore branché',
          message:
              'L’API Course arrive en CORE-02. En attendant, cette page expose seulement les matières réelles et refuse les cours de fixture.',
          icon: Icons.layers_outlined,
          actionLabel: 'Gérer les matières',
          onAction: () => context.go(AppRoutes.subjects),
        ),
      ],
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.subject,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final Subject subject;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      selected: selected,
      onTap: onTap,
      child: Row(
        children: [
          RevisionIconTile(icon: Icons.menu_book_outlined, accent: accent),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject.name, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.xs),
                Text(
                  'Matière réelle · priorité ${subject.priority}',
                  style: RevisionTypography.body,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: RevisionColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _CoursesHeader extends StatelessWidget {
  const _CoursesHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: RevisionTypography.pageTitle),
        const SizedBox(height: RevisionSpacing.xs),
        Text(subtitle, style: RevisionTypography.body),
      ],
    );
  }
}

Color _accentFor(int index) {
  const accents = [
    RevisionColors.blue,
    RevisionColors.pink,
    RevisionColors.mint,
    RevisionColors.violet,
    RevisionColors.amber,
  ];

  return accents[index % accents.length];
}
