import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/auth_session.dart';
import '../domain/authenticated_user.dart';

abstract interface class AuthRepository {
  Stream<AuthSession> watchSession();

  Future<void> signInWithGoogle();

  Future<void> signInWithApple();

  Future<void> signOut();

  Future<String> requireIdToken();
}

abstract interface class AuthProfileBootstrapper {
  Future<void> bootstrapCurrentStudent();
}

class AuthController extends ChangeNotifier {
  AuthController(
    this._repository, {
    AuthSession initialSession = const AuthSession.loading(),
    this.profileBootstrapper,
  }) : _session = initialSession;

  final AuthRepository _repository;
  final AuthProfileBootstrapper? profileBootstrapper;
  StreamSubscription<AuthSession>? _subscription;
  AuthSession _session;
  bool _isBusy = false;
  bool _started = false;
  String? _bootstrappedUid;
  String? _errorMessage;

  AuthSession get session => _session;

  AuthenticatedUser? get user => _session.user;

  bool get isLoading => _session.isLoading;

  bool get isSignedIn => _session.isSignedIn;

  bool get isBusy => _isBusy;

  String? get errorMessage => _errorMessage;

  void start() {
    if (_started) {
      return;
    }
    _started = true;
    _subscription = _repository.watchSession().listen((session) {
      _session = session;
      _bootstrapProfileIfNeeded(session);
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() {
    return _runAuthAction(_repository.signInWithGoogle);
  }

  Future<void> signInWithApple() {
    return _runAuthAction(_repository.signInWithApple);
  }

  Future<void> signOut() {
    return _runAuthAction(_repository.signOut);
  }

  Future<String> requireIdToken() {
    return _repository.requireIdToken();
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
    } catch (error) {
      _errorMessage = _describeAuthError(error);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void _bootstrapProfileIfNeeded(AuthSession session) {
    final user = session.user;

    if (user == null) {
      _bootstrappedUid = null;
      return;
    }

    if (_bootstrappedUid == user.uid) {
      return;
    }

    final bootstrapper = profileBootstrapper;
    if (bootstrapper == null) {
      return;
    }

    _bootstrappedUid = user.uid;
    unawaited(bootstrapper.bootstrapCurrentStudent().catchError((_) {}));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

String _describeAuthError(Object error) {
  final message = error.toString();

  if (message.contains('signInWithProvider is not supported') ||
      message.contains('AuthorizationError Code=1000')) {
    return 'Connexion Google/Apple indisponible sur macOS avec cette configuration Firebase.';
  }

  if (message.contains('invalid FirebaseApp options') ||
      message.contains('APIKey')) {
    return 'Configuration Firebase incomplète. Ajoute les valeurs du projet Firebase pour te connecter.';
  }

  return 'Connexion impossible pour le moment.';
}
