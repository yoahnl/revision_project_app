import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/theme/app_theme.dart';
import '../presentation/theme/theme_controller.dart';
import 'bootstrap/app_widget.dart';
import 'router/app_router.dart';

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref
        .watch(themeProvider)
        .when(
          data: (mode) => mode,
          error: (error, stackTrace) => ThemeMode.system,
          loading: () => ThemeMode.system,
        );

    return MaterialApp.router(
      title: 'Revision',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return UiEventsListener(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
