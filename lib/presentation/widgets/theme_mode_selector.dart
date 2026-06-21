import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/components/revision_mvp_components.dart';
import '../design_system/components/revision_states.dart';
import '../theme/theme_controller.dart';

class ThemeModeSelector extends ConsumerWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return themeMode.when(
      loading: () => const RevisionLoadingState(label: 'Chargement du thème'),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (mode) => RevisionSegmentedControl<ThemeMode>(
        values: const [ThemeMode.system, ThemeMode.light, ThemeMode.dark],
        selected: mode,
        labelOf: _themeLabel,
        onChanged: ref.read(themeProvider.notifier).select,
      ),
    );
  }
}

String _themeLabel(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.system => 'Système',
    ThemeMode.light => 'Clair',
    ThemeMode.dark => 'Sombre',
  };
}
