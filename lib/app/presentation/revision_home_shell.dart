import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/route_paths.dart';

class RevisionHomeShell extends StatelessWidget {
  const RevisionHomeShell({
    super.key,
    required this.currentPath,
    required this.child,
  });

  static const double _wideLayoutBreakpoint = 840;
  static const double _maxContentWidth = 900;

  final String currentPath;
  final Widget child;

  int get _selectedIndex {
    final index = _destinations.indexWhere(
      (destination) => currentPath == destination.path,
    );

    return index == -1 ? 0 : index;
  }

  void _goToDestination(BuildContext context, int index) {
    final destinationPath = _destinations[index].path;

    if (destinationPath != currentPath) {
      context.go(destinationPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _wideLayoutBreakpoint) {
          return _WideHomeScaffold(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => _goToDestination(context, index),
            child: child,
          );
        }

        return Scaffold(
          body: SafeArea(child: child),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => _goToDestination(context, index),
            destinations: _navigationDestinations,
          ),
        );
      },
    );
  }
}

class _WideHomeScaffold extends StatelessWidget {
  const _WideHomeScaffold({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: _railDestinations,
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: RevisionHomeShell._maxContentWidth,
                  ),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const List<_RevisionDestination> _destinations = [
  _RevisionDestination(
    path: subjectsRoutePath,
    label: 'Accueil',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  _RevisionDestination(
    path: todayRoutePath,
    label: 'Aujourd hui',
    icon: Icons.today_outlined,
    selectedIcon: Icons.today,
  ),
  _RevisionDestination(
    path: activitiesRoutePath,
    label: 'Activites',
    icon: Icons.local_activity_outlined,
    selectedIcon: Icons.local_activity,
  ),
  _RevisionDestination(
    path: profileRoutePath,
    label: 'Profil',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  ),
];

final List<NavigationDestination> _navigationDestinations = _destinations
    .map(
      (destination) => NavigationDestination(
        icon: Icon(destination.icon),
        selectedIcon: Icon(destination.selectedIcon),
        label: destination.label,
      ),
    )
    .toList(growable: false);

final List<NavigationRailDestination> _railDestinations = _destinations
    .map(
      (destination) => NavigationRailDestination(
        icon: Icon(destination.icon),
        selectedIcon: Icon(destination.selectedIcon),
        label: Text(destination.label),
      ),
    )
    .toList(growable: false);

class _RevisionDestination {
  const _RevisionDestination({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
