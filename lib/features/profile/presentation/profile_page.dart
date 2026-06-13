import 'package:flutter/material.dart';

import '../../auth/application/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.authController, super.key});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authController,
      builder: (context, _) {
        final user = authController.user;

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Profil', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline),
              title: Text(user?.displayName ?? 'Etudiant'),
              subtitle: Text(user?.email ?? user?.uid ?? ''),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: authController.signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Se deconnecter'),
              ),
            ),
          ],
        );
      },
    );
  }
}
