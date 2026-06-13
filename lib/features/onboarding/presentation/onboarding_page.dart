import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_paths.dart';
import '../application/revision_goals_controller.dart';
import '../../subjects/application/subjects_controller.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    required this.subjectsController,
    required this.revisionGoalsController,
    this.now,
    super.key,
  });

  final SubjectsController subjectsController;
  final RevisionGoalsController revisionGoalsController;
  final DateTime Function()? now;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final TextEditingController _subjectNameController = TextEditingController();
  final TextEditingController _weeklyMinutesController = TextEditingController(
    text: '180',
  );
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _subjectNameController.dispose();
    _weeklyMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Prepare ton premier plan',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subjectNameController,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                labelText: 'Matiere',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _weeklyMinutesController,
              enabled: !_isSubmitting,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Minutes par semaine',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
            ],
            FilledButton(
              onPressed: _isSubmitting ? null : _createPlan,
              child: Text(_isSubmitting ? 'Creation...' : 'Creer mon plan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPlan() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final weeklyMinutes = int.parse(_weeklyMinutesController.text.trim());
      final subject = await widget.subjectsController.createSubject(
        name: _subjectNameController.text,
        priority: _priorityFromWeeklyMinutes(weeklyMinutes),
        weeklyMinutes: weeklyMinutes,
      );
      await widget.revisionGoalsController.saveGoal(
        targetDate: _targetDate(),
        weeklyMinutes: weeklyMinutes,
      );

      if (mounted) {
        context.go(subjectDetailRoutePath(subject.id));
      }
    } on FormatException {
      if (mounted) {
        setState(() {
          _errorMessage = 'Indique un nombre de minutes valide';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Impossible de creer la matiere';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  DateTime _targetDate() {
    final now = widget.now ?? DateTime.now;

    return now().add(const Duration(days: 30));
  }
}

int _priorityFromWeeklyMinutes(int weeklyMinutes) {
  if (weeklyMinutes >= 240) {
    return 5;
  }

  if (weeklyMinutes >= 120) {
    return 4;
  }

  return 3;
}
