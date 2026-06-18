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
import '../application/courses_providers.dart';
import '../domain/course_models.dart';
import '../domain/courses_repository.dart';

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
              'Tes vrais cours apparaissent ici dès qu’ils existent côté API.',
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
      return RevisionEmptyState(
        title: 'Aucune matière réelle',
        message:
            'Crée une matière via le flow réel avant de rattacher des cours.',
        icon: Icons.school_outlined,
        actionLabel: 'Ouvrir les matières',
        onAction: () => context.go(AppRoutes.subjects),
      );
    }

    final activeSubject = _activeSubject(
      subjects,
      ref.watch(activeSubjectIdProvider),
    );
    final courses = ref.watch(coursesProvider(activeSubject.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SubjectSelector(subjects: subjects, activeSubject: activeSubject),
        const SizedBox(height: RevisionSpacing.l),
        _ActiveSubjectHeader(subject: activeSubject),
        const SizedBox(height: RevisionSpacing.l),
        courses.when(
          loading: () =>
              const RevisionLoadingState(label: 'Chargement des cours réels'),
          error: (error, stackTrace) => RevisionErrorState(
            title: 'Impossible de charger les cours',
            message:
                'Aucun cours fictif ne sera affiché. Vérifie la connexion API puis réessaie.',
            actionLabel: 'Réessayer',
            onAction: () => ref.invalidate(coursesProvider(activeSubject.id)),
          ),
          data: (courses) =>
              _CourseList(subject: activeSubject, courses: courses),
        ),
      ],
    );
  }
}

class _SubjectSelector extends ConsumerWidget {
  const _SubjectSelector({required this.subjects, required this.activeSubject});

  final List<Subject> subjects;
  final Subject activeSubject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Matières réelles', style: RevisionTypography.sectionTitle),
        const SizedBox(height: RevisionSpacing.m),
        for (var index = 0; index < subjects.length; index++) ...[
          _SubjectCard(
            subject: subjects[index],
            accent: _accentFor(index),
            selected: subjects[index].id == activeSubject.id,
            onTap: () {
              ref
                  .read(activeSubjectIdProvider.notifier)
                  .select(subjects[index].id);
            },
          ),
          const SizedBox(height: RevisionSpacing.m),
        ],
      ],
    );
  }
}

class _ActiveSubjectHeader extends StatelessWidget {
  const _ActiveSubjectHeader({required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Row(
        children: [
          RevisionIconTile(
            icon: Icons.menu_book_outlined,
            accent: RevisionColors.blue,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject.name, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.xs),
                Text(
                  'Matière active · priorité ${subject.priority}',
                  style: RevisionTypography.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseList extends StatelessWidget {
  const _CourseList({required this.subject, required this.courses});

  final Subject subject;
  final List<CourseListItem> courses;

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return RevisionEmptyState(
        title: 'Aucun cours réel',
        message:
            'Crée un cours réel, puis ouvre-le pour ajouter un PDF, générer une fiche ou lancer une révision rapide.',
        icon: Icons.layers_outlined,
        actionLabel: 'Créer un cours',
        onAction: () => _showCreateCourseSheet(context, subject),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Cours réels',
                style: RevisionTypography.sectionTitle,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showCreateCourseSheet(context, subject),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Créer'),
            ),
          ],
        ),
        const SizedBox(height: RevisionSpacing.m),
        for (final course in courses) ...[
          _CourseCard(course: course),
          const SizedBox(height: RevisionSpacing.m),
        ],
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});

  final CourseListItem course;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      onTap: () => context.go(AppRoutes.course(course.id)),
      child: Row(
        children: [
          const RevisionIconTile(
            icon: Icons.auto_stories_outlined,
            accent: RevisionColors.mint,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.xs),
                Text(_courseMeta(course), style: RevisionTypography.body),
                const SizedBox(height: RevisionSpacing.xs),
                Text(_sourceMeta(course), style: RevisionTypography.caption),
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
          RevisionIconTile(icon: Icons.school_outlined, accent: accent),
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
        ],
      ),
    );
  }
}

class _CreateCourseSheet extends ConsumerStatefulWidget {
  const _CreateCourseSheet({required this.subject});

  final Subject subject;

  @override
  ConsumerState<_CreateCourseSheet> createState() => _CreateCourseSheetState();
}

class _CreateCourseSheetState extends ConsumerState<_CreateCourseSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _chapterController = TextEditingController();
  final _minutesController = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _chapterController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createCourseControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: RevisionSpacing.l,
        right: RevisionSpacing.l,
        top: RevisionSpacing.l,
        bottom: MediaQuery.viewInsetsOf(context).bottom + RevisionSpacing.l,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Créer un cours', style: RevisionTypography.sectionTitle),
            const SizedBox(height: RevisionSpacing.s),
            Text(widget.subject.name, style: RevisionTypography.body),
            const SizedBox(height: RevisionSpacing.l),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: RevisionSpacing.m),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: RevisionSpacing.m),
            TextField(
              controller: _chapterController,
              decoration: const InputDecoration(labelText: 'Chapitre'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: RevisionSpacing.m),
            TextField(
              controller: _minutesController,
              decoration: const InputDecoration(labelText: 'Durée estimée'),
              keyboardType: TextInputType.number,
            ),
            if (_localError != null) ...[
              const SizedBox(height: RevisionSpacing.m),
              Text(
                _localError!,
                style: const TextStyle(color: RevisionColors.red),
              ),
            ],
            if (createState.hasError) ...[
              const SizedBox(height: RevisionSpacing.m),
              const Text(
                'Impossible de créer le cours réel.',
                style: TextStyle(color: RevisionColors.red),
              ),
            ],
            const SizedBox(height: RevisionSpacing.l),
            RevisionGradientButton(
              label: createState.isLoading ? 'Création...' : 'Créer le cours',
              icon: Icons.add_rounded,
              expanded: true,
              onPressed: createState.isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final minutesText = _minutesController.text.trim();
    final estimatedMinutes = minutesText.isEmpty
        ? null
        : int.tryParse(minutesText);

    if (title.length < 2) {
      setState(() {
        _localError = 'Le titre doit contenir au moins 2 caractères.';
      });
      return;
    }

    if (minutesText.isNotEmpty && estimatedMinutes == null) {
      setState(() {
        _localError = 'La durée doit être un nombre entier.';
      });
      return;
    }

    setState(() {
      _localError = null;
    });

    try {
      final course = await ref
          .read(createCourseControllerProvider.notifier)
          .create(
            subjectId: widget.subject.id,
            input: CreateCourseInput(
              title: title,
              description: _optionalText(_descriptionController.text),
              chapterLabel: _optionalText(_chapterController.text),
              estimatedMinutes: estimatedMinutes,
            ),
          );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      context.go(AppRoutes.course(course.id));
    } on CourseRequestException {
      setState(() {
        _localError = 'Les informations du cours sont invalides.';
      });
    }
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

Subject _activeSubject(List<Subject> subjects, String? activeSubjectId) {
  for (final subject in subjects) {
    if (subject.id == activeSubjectId) {
      return subject;
    }
  }

  return subjects.first;
}

void _showCreateCourseSheet(BuildContext context, Subject subject) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: RevisionColors.ink2,
    builder: (context) => _CreateCourseSheet(subject: subject),
  );
}

String _courseMeta(CourseListItem course) {
  final parts = <String>[
    if (course.chapterLabel != null) course.chapterLabel!,
    if (course.estimatedMinutes != null) '${course.estimatedMinutes} min',
  ];

  return parts.isEmpty ? 'Cours réel' : parts.join(' · ');
}

String _sourceMeta(CourseListItem course) {
  final sourceLabel = course.sourceCount <= 1 ? 'source' : 'sources';
  final readyLabel = course.readySourceCount <= 1 ? 'prête' : 'prêtes';

  return '${course.sourceCount} $sourceLabel · ${course.readySourceCount} $readyLabel';
}

String? _optionalText(String value) {
  final trimmed = value.trim();

  return trimmed.isEmpty ? null : trimmed;
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
