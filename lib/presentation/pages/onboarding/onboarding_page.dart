import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/core/routing/route_paths.dart';
import 'package:Neralune/features/onboarding/application/revision_goals_controller.dart';
import 'package:Neralune/features/subjects/application/subjects_controller.dart';
import 'package:Neralune/presentation/design_system/components/revision_mvp_components.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_colors.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_radius.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_spacing.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_typography.dart';
import 'package:Neralune/presentation/widgets/revision_background.dart';

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
          child: RevisionPageScaffold(
            maxWidth: 560,
            children: [
              RevisionGlassCard(
                padding: const EdgeInsets.all(RevisionSpacing.xl),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    RevisionColors.violet.withValues(alpha: 0.62),
                    RevisionColors.glassStrong,
                  ],
                ),
                borderColor: RevisionColors.violet.withValues(alpha: 0.42),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RevisionIconTile(
                      icon: Icons.school_rounded,
                      accent: RevisionColors.violet,
                      size: 58,
                    ),
                    SizedBox(height: RevisionSpacing.l),
                    Text(
                      'Crée ta première matière',
                      style: RevisionTypography.pageTitle,
                    ),
                    SizedBox(height: RevisionSpacing.s),
                    Text(
                      'Ajoute ensuite un cours et une source pour générer tes premières révisions.',
                      style: RevisionTypography.body,
                    ),
                  ],
                ),
              ),
              RevisionGlassCard(
                padding: const EdgeInsets.all(RevisionSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PremiumTextField(
                      controller: _subjectNameController,
                      enabled: !_isSubmitting,
                      label: 'Matière',
                      icon: Icons.menu_book_rounded,
                    ),
                    const SizedBox(height: RevisionSpacing.m),
                    _PremiumTextField(
                      controller: _weeklyMinutesController,
                      enabled: !_isSubmitting,
                      keyboardType: TextInputType.number,
                      label: 'Minutes par semaine',
                      icon: Icons.timer_rounded,
                      helperText: 'Ex. 180 min = 3 h par semaine.',
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: RevisionSpacing.l),
                      _InlineErrorMessage(message: _errorMessage!),
                    ],
                    const SizedBox(height: RevisionSpacing.l),
                    RevisionGradientButton(
                      onPressed: _isSubmitting ? null : _createPlan,
                      icon: Icons.arrow_forward_rounded,
                      label: _isSubmitting
                          ? 'Création en cours...'
                          : 'Créer mon plan',
                      expanded: true,
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

  Future<void> _createPlan() async {
    final subjectName = _subjectNameController.text.trim();
    final weeklyMinutes = int.tryParse(_weeklyMinutesController.text.trim());

    if (subjectName.isEmpty) {
      setState(() {
        _errorMessage = 'Indique le nom de ta matière.';
      });
      return;
    }

    if (weeklyMinutes == null || weeklyMinutes < 30) {
      setState(() {
        _errorMessage = 'Indique au moins 30 minutes par semaine.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final subject = await widget.subjectsController.createSubject(
        name: subjectName,
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
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Impossible de créer la matière pour le moment.';
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

class _PremiumTextField extends StatelessWidget {
  const _PremiumTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.enabled = true,
    this.keyboardType,
    this.helperText,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: RevisionTypography.body.copyWith(color: RevisionColors.text),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: Icon(icon, color: RevisionColors.textMuted),
        filled: true,
        fillColor: RevisionColors.ink.withValues(alpha: 0.22),
        border: OutlineInputBorder(
          borderRadius: RevisionRadius.radiusM,
          borderSide: const BorderSide(color: RevisionColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: RevisionRadius.radiusM,
          borderSide: const BorderSide(color: RevisionColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: RevisionRadius.radiusM,
          borderSide: const BorderSide(color: RevisionColors.blue, width: 1.4),
        ),
      ),
    );
  }
}

class _InlineErrorMessage extends StatelessWidget {
  const _InlineErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RevisionSpacing.m),
      decoration: BoxDecoration(
        color: RevisionColors.red.withValues(alpha: 0.08),
        borderRadius: RevisionRadius.radiusM,
        border: Border.all(color: RevisionColors.red.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: RevisionColors.red),
          const SizedBox(width: RevisionSpacing.s),
          Expanded(
            child: Text(
              message,
              style: RevisionTypography.body.copyWith(
                color: RevisionColors.text,
              ),
            ),
          ),
        ],
      ),
    );
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
