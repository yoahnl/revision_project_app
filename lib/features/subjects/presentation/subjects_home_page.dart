import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_paths.dart';
import '../application/subjects_controller.dart';
import '../domain/subject.dart';

class SubjectsHomePage extends StatefulWidget {
  const SubjectsHomePage({required this.controller, super.key});

  final SubjectsController controller;

  @override
  State<SubjectsHomePage> createState() => _SubjectsHomePageState();
}

class _SubjectsHomePageState extends State<SubjectsHomePage> {
  late Future<List<Subject>> _subjects;

  @override
  void initState() {
    super.initState();
    _subjects = widget.controller.listSubjects();
  }

  void _reloadSubjects() {
    setState(() {
      _subjects = widget.controller.listSubjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Tes matieres', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: () => context.go(onboardingRoutePath),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une matiere'),
          ),
        ),
        const SizedBox(height: 24),
        FutureBuilder<List<Subject>>(
          future: _subjects,
          builder: (context, snapshot) {
            final subjects = snapshot.data ?? const <Subject>[];

            if (snapshot.connectionState != ConnectionState.done) {
              return const LinearProgressIndicator();
            }

            if (snapshot.hasError) {
              return _SubjectsErrorState(onRetry: _reloadSubjects);
            }

            if (subjects.isEmpty) {
              return const Text('Aucune matiere pour le moment');
            }

            return Column(
              children: [
                for (final subject in subjects)
                  _SubjectListItem(
                    subject: subject,
                    onTap: () => context.go(subjectDetailRoutePath(subject.id)),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SubjectListItem extends StatelessWidget {
  const _SubjectListItem({required this.subject, required this.onTap});

  final Subject subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.menu_book_outlined),
      title: Text(subject.name),
      subtitle: Text(_subjectSubtitle(subject)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _SubjectsErrorState extends StatelessWidget {
  const _SubjectsErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Impossible de charger les matieres',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Reessayer'),
        ),
      ],
    );
  }
}

String _subjectSubtitle(Subject subject) {
  if (subject.weeklyMinutes <= 0) {
    return 'Priorite ${subject.priority}';
  }

  final hours = subject.weeklyMinutes ~/ 60;
  final minutes = subject.weeklyMinutes % 60;

  if (minutes == 0) {
    return '$hours h / semaine';
  }

  if (hours == 0) {
    return '$minutes min / semaine';
  }

  return '$hours h $minutes min / semaine';
}
