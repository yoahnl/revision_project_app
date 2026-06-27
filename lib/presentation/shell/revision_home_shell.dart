import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/app/di/providers.dart';
import 'package:Neralune/features/auth/application/auth_controller.dart';
import 'package:Neralune/presentation/design_system/components/revision_mvp_components.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_colors.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_shadows.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_spacing.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_typography.dart';
import 'package:Neralune/presentation/pages/profile/profile_page.dart';
import 'package:Neralune/presentation/theme/app_spacing.dart';
import 'package:Neralune/presentation/widgets/revision_background.dart';
import 'package:Neralune/presentation/widgets/revision_navigation.dart';

class RevisionHomeShell extends ConsumerWidget {
  const RevisionHomeShell({super.key, required this.navigationShell});

  static const double _wideLayoutBreakpoint = 840;
  static const double _maxContentWidth = RevisionPageScaffold.wideMaxWidth;

  final StatefulNavigationShell navigationShell;

  void _goToDestination(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider);
    final showProfileAction = navigationShell.currentIndex == 0;
    final currentPath = GoRouter.of(
      context,
    ).routeInformationProvider.value.uri.path;
    final showBottomNavigation = !currentPath.startsWith('/courses/');

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _wideLayoutBreakpoint) {
          return _WideHomeScaffold(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goToDestination,
            authController: authController,
            showProfileAction: showProfileAction,
            child: navigationShell,
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: RevisionBackground(
            child: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  navigationShell,
                  if (showProfileAction)
                    Positioned(
                      right: AppSpacing.l,
                      top: AppSpacing.l,
                      child: _ProfileSheetButton(
                        authController: authController,
                      ),
                    ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: showBottomNavigation
              ? RevisionBottomNavigation(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _goToDestination,
                  destinations: _navigationDestinations,
                )
              : null,
        );
      },
    );
  }
}

class _WideHomeScaffold extends StatelessWidget {
  const _WideHomeScaffold({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.authController,
    required this.showProfileAction,
    required this.child,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final AuthController authController;
  final bool showProfileAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RevisionBackground(
          child: Row(
            children: [
              RevisionNavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                destinations: _navigationDestinations,
              ),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: RevisionHomeShell._maxContentWidth,
                        ),
                        child: child,
                      ),
                    ),
                    if (showProfileAction)
                      Positioned(
                        top: AppSpacing.l,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: RevisionHomeShell._maxContentWidth,
                              ),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: _ProfileSheetButton(
                                  authController: authController,
                                ),
                              ),
                            ),
                          ),
                        ),
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

const List<RevisionNavigationDestination> _navigationDestinations = [
  RevisionNavigationDestination(
    label: 'Aujourd’hui',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
  ),
  RevisionNavigationDestination(
    label: 'Cours',
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book_rounded,
  ),
  RevisionNavigationDestination(
    label: 'Progrès',
    icon: Icons.trending_up_rounded,
    selectedIcon: Icons.trending_up_rounded,
  ),
];

class _ProfileSheetButton extends StatelessWidget {
  const _ProfileSheetButton({required this.authController});

  final AuthController authController;

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.46),
      builder: (_) => _ProfileBottomSheet(authController: authController),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('profile-menu-button'),
      decoration: BoxDecoration(
        color: RevisionColors.glassStrong,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: RevisionColors.borderBright),
        boxShadow: RevisionShadows.nav,
      ),
      child: IconButton(
        tooltip: 'Profil',
        constraints: const BoxConstraints.tightFor(width: 44, height: 44),
        padding: EdgeInsets.zero,
        onPressed: () => _openSheet(context),
        icon: const Icon(
          Icons.person_outline_rounded,
          color: RevisionColors.text,
          size: 22,
        ),
      ),
    );
  }
}

class _ProfileBottomSheet extends StatelessWidget {
  const _ProfileBottomSheet({required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('profile-bottom-sheet'),
      decoration: const BoxDecoration(
        color: RevisionColors.ink2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: RevisionColors.borderBright)),
      ),
      child: SafeArea(
        top: false,
        child: FractionallySizedBox(
          heightFactor: 0.82,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.m,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: RevisionColors.borderBright,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const SizedBox(width: 42, height: 4),
                  ),
                ),
                const SizedBox(height: RevisionSpacing.xl),
                const Text('Profil', style: RevisionTypography.pageTitle),
                const SizedBox(height: RevisionSpacing.xs),
                const Text(
                  'Gère ton compte et tes préférences d’affichage.',
                  style: RevisionTypography.body,
                ),
                const SizedBox(height: RevisionSpacing.l),
                ProfileContent(authController: authController),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
