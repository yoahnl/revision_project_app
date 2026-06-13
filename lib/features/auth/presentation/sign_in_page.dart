import 'package:flutter/material.dart';

import '../application/auth_controller.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({required this.authController, super.key});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ListenableBuilder(
                listenable: authController,
                builder: (context, _) {
                  final errorMessage = authController.errorMessage;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Connexion',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (errorMessage != null) ...[
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              errorMessage,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      FilledButton.icon(
                        onPressed: authController.isBusy
                            ? null
                            : authController.signInWithGoogle,
                        icon: const Icon(Icons.login),
                        label: const Text('Continuer avec Google'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: authController.isBusy
                            ? null
                            : authController.signInWithApple,
                        icon: const Icon(Icons.apple),
                        label: const Text('Continuer avec Apple'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
