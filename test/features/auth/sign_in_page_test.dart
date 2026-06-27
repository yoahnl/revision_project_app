import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/auth/application/auth_controller.dart';
import 'package:Neralune/features/auth/domain/auth_session.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_colors.dart';
import 'package:Neralune/presentation/pages/auth/sign_in_page.dart';
import 'package:Neralune/presentation/widgets/brand/neralune_animated_logo.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.googleSignInError});

  final Object? googleSignInError;
  final calls = <String>[];

  @override
  Stream<AuthSession> watchSession() async* {
    yield const AuthSession.signedOut();
  }

  @override
  Future<void> signInWithApple() async {
    calls.add('apple');
  }

  @override
  Future<void> signInWithGoogle() async {
    calls.add('google');
    final error = googleSignInError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    calls.add('emailSignIn:$email:$password');
  }

  @override
  Future<void> createAccountWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    calls.add('createAccount:$email:$password');
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    calls.add('passwordReset:$email');
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
  }

  @override
  Future<String> requireIdToken() async => 'token';
}

void main() {
  testWidgets('shows Neralune welcome branding and existing auth actions', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    final controller = AuthController(repository);

    await tester.pumpWidget(
      MaterialApp(home: SignInPage(authController: controller)),
    );

    expect(find.text('NERALUNE'), findsOneWidget);
    expect(find.textContaining('Révise mieux'), findsOneWidget);
    expect(find.textContaining('progresse'), findsOneWidget);
    expect(find.text('Continuer avec Google'), findsOneWidget);
    expect(find.text('Continuer avec Apple'), findsOneWidget);
    expect(find.text('Continuer avec email'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('email-auth-open-button')),
      findsOneWidget,
    );
    expect(find.text('Adresse email'), findsNothing);
    expect(find.text('Mot de passe'), findsNothing);
    expect(find.text('Se connecter'), findsNothing);
    expect(find.text('Créer un compte'), findsNothing);
    expect(find.text('Mot de passe oublié'), findsNothing);
    expect(find.text('Conditions d’utilisation'), findsOneWidget);
    expect(find.text('Politique de confidentialité'), findsOneWidget);
    expect(find.byType(NeraluneAnimatedLogo), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(
      _buttonDecorationFor(tester, 'Continuer avec Google').color,
      Colors.white,
    );
    expect(
      _buttonDecorationFor(tester, 'Continuer avec Google').gradient,
      isNull,
    );
    expect(
      _buttonDecorationFor(tester, 'Continuer avec Apple').color,
      Colors.black,
    );
    expect(
      _buttonDecorationFor(tester, 'Continuer avec Apple').gradient,
      isNull,
    );
    expect(
      _buttonDecorationFor(tester, 'Continuer avec email').color,
      RevisionColors.glassSoft,
    );
    expect(find.textContaining('MVP+'), findsNothing);
    expect(find.textContaining('backend'), findsNothing);

    await tester.ensureVisible(find.text('Continuer avec Google'));
    await tester.pump();
    await tester.tap(find.text('Continuer avec Google'));
    await tester.pump();
    await tester.ensureVisible(find.text('Continuer avec Apple'));
    await tester.pump();
    await tester.tap(find.text('Continuer avec Apple'));
    await tester.pump();

    expect(repository.calls, containsAllInOrder(['google', 'apple']));
  });

  testWidgets('reveals the email form after choosing email login', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    final controller = AuthController(repository);

    await tester.pumpWidget(
      MaterialApp(home: SignInPage(authController: controller)),
    );

    await _openEmailForm(tester);

    expect(find.text('Continuer avec Google'), findsNothing);
    expect(find.text('Continuer avec Apple'), findsNothing);
    expect(find.text('Continuer avec email'), findsNothing);
    expect(find.text('Adresse email'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Créer un compte'), findsOneWidget);
    expect(find.text('Mot de passe oublié'), findsOneWidget);
    expect(find.text('Autres méthodes'), findsOneWidget);
  });

  testWidgets('submits an email and password sign-in through Firebase auth', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    final controller = AuthController(repository);

    await tester.pumpWidget(
      MaterialApp(home: SignInPage(authController: controller)),
    );

    await _openEmailForm(tester);
    await tester.enterText(
      find.byKey(const ValueKey('email-auth-email-field')),
      ' student@example.com ',
    );
    await tester.enterText(
      find.byKey(const ValueKey('email-auth-password-field')),
      'secret123',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('email-auth-submit-button')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('email-auth-submit-button')));
    await tester.pump();

    expect(repository.calls, ['emailSignIn:student@example.com:secret123']);
  });

  testWidgets('can switch to account creation and request password reset', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    final controller = AuthController(repository);

    await tester.pumpWidget(
      MaterialApp(home: SignInPage(authController: controller)),
    );

    await _openEmailForm(tester);
    await tester.ensureVisible(
      find.byKey(const ValueKey('email-auth-toggle-mode-button')),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('email-auth-toggle-mode-button')),
    );
    await tester.pump();
    expect(find.text('Créer mon compte'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('email-auth-email-field')),
      'student@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('email-auth-password-field')),
      'secret123',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('email-auth-submit-button')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('email-auth-submit-button')));
    await tester.pump();

    await tester.ensureVisible(
      find.byKey(const ValueKey('email-auth-toggle-mode-button')),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('email-auth-toggle-mode-button')),
    );
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const ValueKey('email-auth-reset-button')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('email-auth-reset-button')));
    await tester.pump();

    expect(repository.calls, [
      'createAccount:student@example.com:secret123',
      'passwordReset:student@example.com',
    ]);
    expect(
      find.text('Email de réinitialisation envoyé. Vérifie ta boîte mail.'),
      findsOneWidget,
    );
  });

  testWidgets('shows a clear auth error after a failed sign-in', (
    tester,
  ) async {
    final controller = AuthController(
      FakeAuthRepository(googleSignInError: StateError('network failed')),
    );

    await tester.pumpWidget(
      MaterialApp(home: SignInPage(authController: controller)),
    );

    await tester.ensureVisible(find.text('Continuer avec Google'));
    await tester.pump();
    await tester.tap(find.text('Continuer avec Google'));
    await tester.pump();

    expect(find.text('Connexion impossible pour le moment.'), findsOneWidget);
  });

  testWidgets('renders the logo when motion is disabled', (tester) async {
    final controller = AuthController(FakeAuthRepository());

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: SignInPage(authController: controller),
        ),
      ),
    );

    expect(find.byType(NeraluneAnimatedLogo), findsOneWidget);
    expect(find.text('NERALUNE'), findsOneWidget);
  });

  testWidgets('fits a compact iPhone viewport without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = AuthController(FakeAuthRepository());

    await tester.pumpWidget(
      MaterialApp(home: SignInPage(authController: controller)),
    );

    expect(find.text('NERALUNE'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Continuer avec email'), findsOneWidget);
    expect(find.text('Adresse email'), findsNothing);
    await tester.ensureVisible(find.text('Politique de confidentialité'));
    await tester.pump();
    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(
      tester.getBottomRight(find.text('Politique de confidentialité')).dy,
      lessThanOrEqualTo(screenHeight),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('places provider buttons in the bottom mobile action area', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = AuthController(FakeAuthRepository());

    await tester.pumpWidget(
      MaterialApp(home: SignInPage(authController: controller)),
    );

    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final taglineBottom = tester
        .getBottomLeft(find.textContaining('Révise mieux'))
        .dy;
    final googleTop = tester.getTopLeft(find.text('Continuer avec Google')).dy;

    expect(googleTop, greaterThan(screenHeight * 0.5));
    expect(googleTop - taglineBottom, greaterThanOrEqualTo(180));
  });
}

BoxDecoration _buttonDecorationFor(WidgetTester tester, String label) {
  final containerFinder = find.ancestor(
    of: find.text(label),
    matching: find.byType(Container),
  );
  final container = tester.widget<Container>(containerFinder.first);
  return container.decoration! as BoxDecoration;
}

Future<void> _openEmailForm(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('email-auth-open-button')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 420));
}
