import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'course_hero_tags.dart';

class CoursesHomePage extends ConsumerWidget {
  const CoursesHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsNotifierProvider);
    final notifier = ref.read(subjectsNotifierProvider.notifier);

    return subjects.when(
      loading: () => RevisionPageScaffold(
        headerChildren: [
          _CoursesHeader(onCreate: () => _showCreateSubjectSheet(context)),
        ],
        children: const [
          RevisionLoadingState(label: 'Chargement des matières'),
        ],
      ),
      error: (error, stackTrace) => RevisionPageScaffold(
        headerChildren: [
          _CoursesHeader(onCreate: () => _showCreateSubjectSheet(context)),
        ],
        children: [
          RevisionErrorState(
            title: 'Impossible de charger les matières',
            message:
                'Vérifie la connexion puis réessaie. Aucun cours de remplacement ne sera affiché.',
            actionLabel: 'Réessayer',
            onAction: notifier.reload,
          ),
        ],
      ),
      data: (subjects) => _CoursesHomeContent(subjects: subjects),
    );
  }
}

class _CoursesHeader extends StatelessWidget {
  const _CoursesHeader({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return RevisionPageHeader(
      title: 'Cours',
      trailing: Hero(
        tag: CourseHeroTags.navigationControl(),
        flightShuttleBuilder: buildCourseNavigationControlHeroFlightShuttle,
        transitionOnUserGestures: true,
        child: RevisionHeaderIconButton(
          tooltip: 'Créer',
          icon: Icons.add_rounded,
          onPressed: onCreate,
        ),
      ),
    );
  }
}

class _CoursesHomeContent extends ConsumerWidget {
  const _CoursesHomeContent({required this.subjects});

  final List<Subject> subjects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (subjects.isEmpty) {
      return RevisionPageScaffold(
        headerChildren: [
          _CoursesHeader(onCreate: () => _showCreateSubjectSheet(context)),
        ],
        children: [
          RevisionEmptyState(
            title: 'Crée ta première matière',
            message: 'Ajoute une matière pour commencer à organiser tes cours.',
            icon: Icons.school_outlined,
            actionLabel: 'Créer une matière',
            onAction: () => _showCreateSubjectSheet(context),
          ),
        ],
      );
    }

    final activeSubject = _activeSubject(
      subjects,
      ref.watch(activeSubjectIdProvider),
    );
    final visual = revisionSubjectVisualThemeFor(activeSubject.name);
    final courses = ref.watch(coursesProvider(activeSubject.id));

    return RevisionPageScaffold(
      headerChildren: [
        _CoursesHeader(
          onCreate: () => _showCreateCourseSheet(context, activeSubject),
        ),
      ],
      children: [
        _SubjectSelectorBlock(
          subject: activeSubject,
          visual: visual,
          subjects: subjects,
          courses: courses.maybeWhen(
            data: (value) => value,
            orElse: () => null,
          ),
        ),
        courses.when(
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
      ],
    );
  }
}

class _SubjectSelectorBlock extends StatelessWidget {
  const _SubjectSelectorBlock({
    required this.subject,
    required this.visual,
    required this.subjects,
    required this.courses,
  });

  final Subject subject;
  final RevisionSubjectVisualTheme visual;
  final List<Subject> subjects;
  final List<CourseListItem>? courses;

  @override
  Widget build(BuildContext context) {
    final loadedCourses = courses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: RevisionSubjectSwitcher(
            label: subject.name,
            accent: visual.accent,
            icon: visual.icon,
            onTap: () => _showSubjectPicker(context, subjects, subject.id),
          ),
        ),
        const SizedBox(height: RevisionSpacing.l),
        Text(
          loadedCourses == null
              ? 'Cours en préparation'
              : _subjectSummary(loadedCourses),
          style: RevisionTypography.body,
        ),
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
      return RevisionEmptyState(
        title: 'Aucun cours pour le moment',
        message:
            'Crée ton premier cours dans ${subject.name}, puis ajoute une source PDF.',
        icon: Icons.layers_outlined,
        actionLabel: 'Créer un cours',
        onAction: () => _showCreateCourseSheet(context, subject),
      );
    }

    final priorityCourse = _priorityCourse(courses);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SubjectHeroCard(
          subject: subject,
          visual: visual,
          priorityCourse: priorityCourse,
        ),
        const SizedBox(height: RevisionSpacing.l),
        for (final course in courses) ...[
          _CourseRow(
            course: course,
            visual: visual,
            onTap: () => context.go(AppRoutes.course(course.id)),
          ),
          if (course != courses.last) const SizedBox(height: RevisionSpacing.m),
        ],
      ],
    );
  }
}

class _SubjectHeroCard extends StatelessWidget {
  const _SubjectHeroCard({
    required this.subject,
    required this.visual,
    required this.priorityCourse,
  });

  final Subject subject;
  final RevisionSubjectVisualTheme visual;
  final CourseListItem priorityCourse;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: CourseHeroTags.subjectOverview(subject.id),
      flightShuttleBuilder: buildCourseCardHeroFlightShuttle,
      transitionOnUserGestures: true,
      child: RevisionGlassCard(
        padding: const EdgeInsets.all(RevisionSpacing.l),
        borderColor: visual.accent.withValues(alpha: 0.48),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            visual.accent.withValues(alpha: 0.38),
            RevisionColors.blueDeep.withValues(alpha: 0.20),
            RevisionColors.glassStrong,
          ],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 130),
          child: Stack(
            children: [
              Positioned(
                right: -8,
                bottom: -22,
                child: Opacity(
                  opacity: 0.18,
                  child: SvgPicture.asset(
                    'assets/brand/neralune_cat.svg',
                    width: 126,
                    height: 126,
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Réviser toute la matière',
                      style: RevisionTypography.sectionTitle,
                    ),
                    const SizedBox(height: RevisionSpacing.s),
                    Text(
                      'On commence par ${priorityCourse.title}.',
                      style: RevisionTypography.body.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: RevisionSpacing.m),
                    RevisionLightButton(
                      label: 'Commencer',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () =>
                          context.go(AppRoutes.course(priorityCourse.id)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  const _CourseRow({
    required this.course,
    required this.visual,
    required this.onTap,
  });

  final CourseListItem course;
  final RevisionSubjectVisualTheme visual;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: CourseHeroTags.learningPath(course.id),
      flightShuttleBuilder: buildCourseCardHeroFlightShuttle,
      transitionOnUserGestures: true,
      child: RevisionGlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: RevisionSpacing.xl,
          vertical: RevisionSpacing.l,
        ),
        backgroundColor: RevisionColors.glassSoft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: RevisionTypography.sectionTitle,
                    ),
                    const SizedBox(height: RevisionSpacing.s),
                    Text(
                      _courseStatusLabel(course),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: RevisionTypography.body,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: RevisionSpacing.m),
              course.progress != null
                  ? RevisionMasteryRing(
                      value: course.progress!.estimatedGlobalMastery,
                      label: _percent(course.progress!.estimatedGlobalMastery),
                      color: visual.accent,
                      size: 60,
                    )
                  : _NeutralProgressCircle(color: RevisionColors.borderBright),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeutralProgressCircle extends StatelessWidget {
  const _NeutralProgressCircle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 5),
      ),
      child: const SizedBox.square(dimension: 44),
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

CourseListItem _priorityCourse(List<CourseListItem> courses) {
  final readyCourses = courses
      .where((course) => course.readySourceCount > 0)
      .toList(growable: false);

  final candidates = readyCourses.isEmpty ? courses : readyCourses;
  final withProgress = candidates
      .where((course) => course.progress != null)
      .toList(growable: false);

  if (withProgress.isNotEmpty) {
    withProgress.sort((a, b) {
      final masteryComparison = a.progress!.estimatedGlobalMastery.compareTo(
        b.progress!.estimatedGlobalMastery,
      );
      if (masteryComparison != 0) {
        return masteryComparison;
      }

      return a.displayOrder.compareTo(b.displayOrder);
    });

    return withProgress.first;
  }

  return candidates.first;
}

String _subjectSummary(List<CourseListItem> courses) {
  final courseCount = courses.length;
  final courseLabel = courseCount <= 1 ? 'cours' : 'cours';
  final knowledgeUnitCount = courses
      .map((course) => course.progress?.knowledgeUnitCount)
      .whereType<int>()
      .fold<int>(0, (sum, value) => sum + value);

  if (courseCount == 0) {
    return 'Aucun cours';
  }

  if (knowledgeUnitCount <= 0) {
    return '$courseCount $courseLabel';
  }

  final notionLabel = knowledgeUnitCount <= 1 ? 'notion' : 'notions';
  return '$courseCount $courseLabel · $knowledgeUnitCount $notionLabel';
}

String _courseStatusLabel(CourseListItem course) {
  final progress = course.progress;

  if (progress == null) {
    return _sourceStatusLabel(course);
  }

  switch (progress.state) {
    case CourseProgressState.noSource:
      return 'Source à ajouter';
    case CourseProgressState.processing:
      return 'Analyse en cours';
    case CourseProgressState.failedOnly:
      return 'Analyse indisponible';
    case CourseProgressState.noKnowledgeUnits:
      return 'Analyse en cours';
    case CourseProgressState.readyNotPracticed:
    case CourseProgressState.practiced:
    case CourseProgressState.unknown:
      final total = progress.knowledgeUnitCount;
      final practiced = progress.practicedKnowledgeUnitCount.clamp(0, total);

      if (total <= 0) {
        return _sourceStatusLabel(course);
      }

      if (practiced == 0) {
        return 'Pas encore commencé';
      }

      final remaining = total - practiced;
      final solidLabel = practiced <= 1 ? 'solide' : 'solides';
      final reinforceLabel = remaining <= 1 ? 'à renforcer' : 'à renforcer';
      return '$practiced $solidLabel · $remaining $reinforceLabel';
  }
}

String _sourceStatusLabel(CourseListItem course) {
  if (course.sourceCount <= 0) {
    return 'Source à ajouter';
  }

  if (course.processingSourceCount > 0 && course.readySourceCount == 0) {
    return 'Analyse en cours';
  }

  if (course.readySourceCount <= 0) {
    return 'Pas encore prêt';
  }

  final sourceLabel = course.sourceCount <= 1 ? 'source' : 'sources';
  final readyLabel = course.readySourceCount <= 1 ? 'prête' : 'prêtes';

  if (course.sourceCount == course.readySourceCount) {
    return '${course.readySourceCount} $sourceLabel $readyLabel';
  }

  return '${course.sourceCount} $sourceLabel · ${course.readySourceCount} $readyLabel';
}

String _percent(double value) {
  return '${(value.clamp(0, 1) * 100).round()}%';
}

String? _optionalText(String value) {
  final trimmed = value.trim();

  return trimmed.isEmpty ? null : trimmed;
}
