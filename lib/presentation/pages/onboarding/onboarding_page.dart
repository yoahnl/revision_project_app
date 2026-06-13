import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/core/routing/route_paths.dart';
import 'package:revision_app/features/onboarding/application/revision_goals_controller.dart';
import 'package:revision_app/features/subjects/application/subjects_controller.dart';
import 'package:revision_app/presentation/theme/app_colors.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_background.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_icon_badge.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';
import 'package:revision_app/presentation/widgets/revision_page.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';
import 'package:revision_app/presentation/widgets/revision_text_field.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    required this.subjectsController,
    required this.revisionGoalsController,
    this.now,
    this.onSubjectCreated,
    super.key,
  });

  final SubjectsController subjectsController;
  final RevisionGoalsController revisionGoalsController;
  final DateTime Function()? now;
  final VoidCallback? onSubjectCreated;

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
      backgroundColor: Colors.transparent,
      body: RevisionBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth > 560
                  ? 560.0
                  : constraints.maxWidth;

              return Center(
                child: SizedBox(
                  width: width,
                  height: constraints.maxHeight,
                  child: RevisionPage(
                    title: 'Prepare ton premier plan',
                    subtitle: 'Choisis une premiere matiere et ton rythme.',
                    children: [
                      RevisionPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: RevisionIconBadge(
                                icon: Icons.school_outlined,
                                color: AppColors.violet,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.l),
                            RevisionTextField(
                              controller: _subjectNameController,
                              enabled: !_isSubmitting,
                              label: 'Matiere',
                              icon: Icons.menu_book_outlined,
                            ),
                            const SizedBox(height: AppSpacing.m),
                            RevisionTextField(
                              controller: _weeklyMinutesController,
                              enabled: !_isSubmitting,
                              keyboardType: TextInputType.number,
                              label: 'Minutes par semaine',
                              icon: Icons.timer_outlined,
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: AppSpacing.l),
                              RevisionMessage(
                                message: _errorMessage!,
                                color: Theme.of(context).colorScheme.error,
                                icon: Icons.error_outline,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.l),
                            RevisionButton(
                              onPressed: _isSubmitting ? null : _createPlan,
                              icon: Icons.auto_awesome,
                              label: _isSubmitting
                                  ? 'Creation...'
                                  : 'Creer mon plan',
                              expand: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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
        widget.onSubjectCreated?.call();
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
