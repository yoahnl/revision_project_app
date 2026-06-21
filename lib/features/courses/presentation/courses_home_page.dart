import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_subject_visuals.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../../subjects/application/subjects_notifier.dart';
import '../../subjects/domain/subject.dart';
import '../application/active_subject_provider.dart';
import '../application/courses_providers.dart';
import '../domain/course_models.dart';
import '../domain/courses_repository.dart';
import 'course_quick_revision_launcher.dart';

class CoursesHomePage extends ConsumerWidget {
  const CoursesHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsNotifierProvider);
    final notifier = ref.read(subjectsNotifierProvider.notifier);

    return _HomePageFrame(
      child: subjects.when(
        loading: () =>
            const RevisionLoadingState(label: 'Chargement des matières'),
        error: (error, stackTrace) => RevisionErrorState(
          title: 'Impossible de charger les matières',
          message:
              'Vérifie la connexion puis réessaie. Aucun cours de remplacement ne sera affiché.',
          actionLabel: 'Réessayer',
          onAction: notifier.reload,
        ),
        data: (subjects) => _CoursesHomeContent(subjects: subjects),
      ),
    );
  }
}

class _HomePageFrame extends StatelessWidget {
  const _HomePageFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: SizedBox(
              height: constraints.maxHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  RevisionSpacing.pageX,
                  RevisionSpacing.pageTop,
                  RevisionSpacing.pageX,
                  RevisionSpacing.l,
                ),
                child: child,
              ),
            ),
          ),
        );
      },
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
        title: 'Commence par créer une matière.',
        message:
            'Ajoute ensuite un cours et une source pour générer tes premières révisions.',
        icon: Icons.school_outlined,
        actionLabel: 'Créer une matière',
        onAction: () => _showCreateSubjectSheet(context),
      );
    }

    final activeSubject = _activeSubject(
      subjects,
      ref.watch(activeSubjectIdProvider),
    );
    final visual = revisionSubjectVisualThemeFor(activeSubject.name);
    final courses = ref.watch(coursesProvider(activeSubject.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HomeTopBar(subject: activeSubject, visual: visual, subjects: subjects),
        const SizedBox(height: RevisionSpacing.xl),
        Text(activeSubject.name, style: RevisionTypography.hero),
        const SizedBox(height: RevisionSpacing.xs),
        Text('Continue ton progrès', style: RevisionTypography.body),
        const SizedBox(height: RevisionSpacing.xl),
        Expanded(
          // The home header stays anchored like the mockups; only the course
          // cards below the hero/section title scroll when the list grows.
          child: courses.when(
            loading: () =>
                const RevisionLoadingState(label: 'Chargement des cours'),
            error: (error, stackTrace) => RevisionErrorState(
              title: 'Impossible de charger les cours',
              message:
                  'Vérifie la connexion puis réessaie. Aucun cours de remplacement ne sera affiché.',
              actionLabel: 'Réessayer',
              onAction: () => ref.invalidate(coursesProvider(activeSubject.id)),
            ),
            data: (courses) => _CourseList(
              subject: activeSubject,
              visual: visual,
              courses: courses,
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeTopBar extends ConsumerWidget {
  const _HomeTopBar({
    required this.subject,
    required this.visual,
    required this.subjects,
  });

  final Subject subject;
  final RevisionSubjectVisualTheme visual;
  final List<Subject> subjects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        RevisionSubjectSwitcher(
          label: subject.name,
          accent: visual.accent,
          icon: visual.icon,
          onTap: () => _showSubjectPicker(context, subjects, subject.id),
        ),
        const Spacer(),
        // No streak/gems are displayed here: the MVP Core has no real
        // gamification counters yet, so the mockup slots intentionally remain
        // empty instead of inventing production values.
        const RevisionTopCounters(),
      ],
    );
  }
}

class _CourseList extends ConsumerWidget {
  const _CourseList({
    required this.subject,
    required this.visual,
    required this.courses,
  });

  final Subject subject;
  final RevisionSubjectVisualTheme visual;
  final List<CourseListItem> courses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (courses.isEmpty) {
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          Text(
            'Tes cours de ${subject.name}',
            style: RevisionTypography.sectionTitle,
          ),
          const SizedBox(height: RevisionSpacing.m),
          RevisionEmptyState(
            title: 'Aucun cours pour le moment',
            message:
                'Crée ton premier cours pour ajouter une source et commencer à réviser.',
            icon: Icons.layers_outlined,
            actionLabel: 'Créer un cours',
            onAction: () => _showCreateCourseSheet(context, subject),
          ),
          const SizedBox(height: RevisionSpacing.l),
          _CourseCreationHint(subject: subject, visual: visual),
        ],
      );
    }

    final spotlightCourse = _spotlightCourse(courses);
    final spotlightReady = spotlightCourse.readySourceCount > 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final fixedHeader = <Widget>[
          RevisionResumeCourseCard(
            title: spotlightCourse.title,
            subtitle: spotlightReady
                ? 'Cours prêt à réviser'
                : 'Préparer ce cours',
            progressLabel: _courseProgressLabel(spotlightCourse),
            progress: _courseProgressValue(spotlightCourse),
            accent: visual.accent,
            icon: visual.icon,
            actionLabel: spotlightReady ? 'Réviser' : 'Ouvrir',
            onContinue: () {
              if (!spotlightReady) {
                context.push(AppRoutes.course(spotlightCourse.id));
                return;
              }

              startCourseQuickRevisionFlow(
                context: context,
                ref: ref,
                courseId: spotlightCourse.id,
                questionCount: 5,
              );
            },
          ),
          const SizedBox(height: RevisionSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tes cours de ${subject.name}',
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
        ];

        if (constraints.maxHeight < 340) {
          // On very short surfaces, preserving accessibility matters more than
          // strict pinning: the whole course area scrolls to avoid clipping.
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              ...fixedHeader,
              ..._courseCards(context),
              const SizedBox(height: RevisionSpacing.l),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...fixedHeader,
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: RevisionSpacing.l),
                itemCount: courses.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: RevisionSpacing.m),
                itemBuilder: (context, index) =>
                    _courseCard(context, courses[index]),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _courseCards(BuildContext context) {
    return [
      for (final course in courses) ...[
        _courseCard(context, course),
        const SizedBox(height: RevisionSpacing.m),
      ],
    ];
  }

  Widget _courseCard(BuildContext context, CourseListItem course) {
    return RevisionCourseCard(
      title: course.title,
      progressLabel: _courseProgressLabel(course),
      durationLabel: _courseMeta(course),
      progress: _courseProgressValue(course),
      accent: visual.accent,
      icon: visual.icon,
      onTap: () => context.push(AppRoutes.course(course.id)),
    );
  }
}

class _CourseCreationHint extends StatelessWidget {
  const _CourseCreationHint({required this.subject, required this.visual});

  final Subject subject;
  final RevisionSubjectVisualTheme visual;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          visual.accent.withValues(alpha: 0.28),
          RevisionColors.glassStrong,
        ],
      ),
      borderColor: visual.accent.withValues(alpha: 0.34),
      child: Row(
        children: [
          RevisionIconTile(icon: visual.icon, accent: visual.accent),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prêt à structurer ${subject.name} ?',
                  style: RevisionTypography.sectionTitle,
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(
                  'Un cours devient utile dès qu’une source PDF est prête.',
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
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: RevisionBottomSheetFrame(
        title: 'Créer un cours',
        subtitle: widget.subject.name,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Titre'),
            textInputAction: TextInputAction.next,
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            textInputAction: TextInputAction.next,
          ),
          TextField(
            controller: _chapterController,
            decoration: const InputDecoration(labelText: 'Chapitre'),
            textInputAction: TextInputAction.next,
          ),
          TextField(
            controller: _minutesController,
            decoration: const InputDecoration(labelText: 'Durée estimée'),
            keyboardType: TextInputType.number,
          ),
          if (_localError != null)
            Text(
              _localError!,
              style: const TextStyle(color: RevisionColors.red),
            ),
          if (createState.hasError)
            const Text(
              'Impossible de créer le cours.',
              style: TextStyle(color: RevisionColors.red),
            ),
          RevisionGradientButton(
            label: createState.isLoading ? 'Création...' : 'Créer le cours',
            icon: Icons.add_rounded,
            expanded: true,
            onPressed: createState.isLoading ? null : _submit,
          ),
        ],
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

      final router = GoRouter.of(context);
      Navigator.of(context).pop();
      router.push(AppRoutes.course(course.id));
    } on CourseRequestException {
      setState(() {
        _localError = 'Les informations du cours sont invalides.';
      });
    }
  }
}

class _CreateSubjectSheet extends ConsumerStatefulWidget {
  const _CreateSubjectSheet();

  @override
  ConsumerState<_CreateSubjectSheet> createState() =>
      _CreateSubjectSheetState();
}

class _CreateSubjectSheetState extends ConsumerState<_CreateSubjectSheet> {
  final _nameController = TextEditingController();
  String? _localError;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: RevisionBottomSheetFrame(
        title: 'Créer une matière',
        subtitle: 'Elle deviendra la matière active de l’accueil.',
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nom de la matière'),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (!_submitting) {
                _submit();
              }
            },
          ),
          if (_localError != null)
            Text(
              _localError!,
              style: const TextStyle(color: RevisionColors.red),
            ),
          RevisionGradientButton(
            label: _submitting ? 'Création...' : 'Créer la matière',
            icon: Icons.add_rounded,
            expanded: true,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();

    if (name.length < 2) {
      setState(() {
        _localError = 'Le nom doit contenir au moins 2 caractères.';
      });
      return;
    }

    setState(() {
      _localError = null;
      _submitting = true;
    });

    try {
      final subject = await ref
          .read(subjectsNotifierProvider.notifier)
          .createSubject(name: name);

      ref.read(activeSubjectIdProvider.notifier).select(subject.id);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } on ArgumentError {
      if (!mounted) {
        return;
      }

      setState(() {
        _localError = 'Le nom doit contenir au moins 2 caractères.';
        _submitting = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _localError = 'Impossible de créer la matière.';
        _submitting = false;
      });
    }
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

CourseListItem _spotlightCourse(List<CourseListItem> courses) {
  for (final course in courses) {
    if (course.readySourceCount > 0) {
      return course;
    }
  }

  return courses.first;
}

void _showSubjectPicker(
  BuildContext context,
  List<Subject> subjects,
  String activeSubjectId,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _SubjectPickerSheet(
      parentContext: context,
      subjects: subjects,
      activeSubjectId: activeSubjectId,
    ),
  );
}

class _SubjectPickerSheet extends ConsumerWidget {
  const _SubjectPickerSheet({
    required this.parentContext,
    required this.subjects,
    required this.activeSubjectId,
  });

  final BuildContext parentContext;
  final List<Subject> subjects;
  final String activeSubjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RevisionBottomSheetFrame(
      title: 'Choisir une matière',
      subtitle: 'La page reste centrée sur une seule matière active.',
      children: [
        for (final subject in subjects)
          _SubjectChoiceCard(
            subject: subject,
            selected: subject.id == activeSubjectId,
            onTap: () {
              ref.read(activeSubjectIdProvider.notifier).select(subject.id);
              Navigator.of(context).pop();
            },
          ),
        RevisionGradientButton(
          label: 'Créer une matière',
          icon: Icons.add_rounded,
          expanded: true,
          onPressed: () {
            Navigator.of(context).pop();
            Future<void>.microtask(() {
              if (!parentContext.mounted) {
                return;
              }

              _showCreateSubjectSheet(parentContext);
            });
          },
        ),
      ],
    );
  }
}

void _showCreateCourseSheet(BuildContext context, Subject subject) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _CreateCourseSheet(subject: subject),
  );
}

void _showCreateSubjectSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _CreateSubjectSheet(),
  );
}

class _SubjectChoiceCard extends StatelessWidget {
  const _SubjectChoiceCard({
    required this.subject,
    required this.selected,
    required this.onTap,
  });

  final Subject subject;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = revisionSubjectVisualThemeFor(subject.name);

    return RevisionGlassCard(
      selected: selected,
      onTap: onTap,
      child: Row(
        children: [
          RevisionIconTile(icon: visual.icon, accent: visual.accent),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Text(subject.name, style: RevisionTypography.sectionTitle),
          ),
          if (selected) Icon(Icons.check_circle_rounded, color: visual.accent),
        ],
      ),
    );
  }
}

double _courseProgressValue(CourseListItem course) {
  final progress = course.progress;
  if (progress != null) {
    return progress.estimatedGlobalMastery;
  }

  if (course.sourceCount <= 0) {
    return 0;
  }

  return course.readySourceCount / course.sourceCount;
}

String _courseProgressLabel(CourseListItem course) {
  final progress = course.progress;
  if (progress != null) {
    return 'Global ${_percent(progress.estimatedGlobalMastery)}';
  }

  return _sourceMeta(course);
}

String _courseMeta(CourseListItem course) {
  final parts = <String>[
    if (course.chapterLabel != null) course.chapterLabel!,
    if (course.estimatedMinutes != null) '${course.estimatedMinutes} min',
  ];

  return parts.isEmpty ? 'Durée à préciser' : parts.join(' · ');
}

String _sourceMeta(CourseListItem course) {
  final sourceLabel = course.sourceCount <= 1 ? 'source' : 'sources';
  final readyLabel = course.readySourceCount <= 1 ? 'prête' : 'prêtes';

  return '${course.sourceCount} $sourceLabel · ${course.readySourceCount} $readyLabel';
}

String _percent(double value) {
  return '${(value.clamp(0, 1) * 100).round()}%';
}

String? _optionalText(String value) {
  final trimmed = value.trim();

  return trimmed.isEmpty ? null : trimmed;
}
