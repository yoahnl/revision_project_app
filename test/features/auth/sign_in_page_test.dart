import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/auth/application/auth_controller.dart';
import 'package:Neralune/features/auth/domain/auth_session.dart';
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
    expect(find.text('Conditions d’utilisation'), findsOneWidget);
    expect(find.text('Politique de confidentialité'), findsOneWidget);
    expect(find.byType(NeraluneAnimatedLogo), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
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
    expect(find.textContaining('MVP+'), findsNothing);
    expect(find.textContaining('backend'), findsNothing);

    await tester.tap(find.text('Continuer avec Google'));
    await tester.pump();
    await tester.tap(find.text('Continuer avec Apple'));
    await tester.pump();

    expect(repository.calls, containsAllInOrder(['google', 'apple']));
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

  testWidgets('fits a compact iPhone viewport without scrolling', (
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
    expect(find.byType(SingleChildScrollView), findsNothing);
    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(
      tester.getTopLeft(find.text('Continuer avec Google')).dy,
      greaterThan(screenHeight * 0.58),
    );
    expect(tester.takeException(), isNull);
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
