import 'authenticated_user.dart';

class AuthSession {
  const AuthSession.loading() : user = null, isLoading = true;

  const AuthSession.signedOut() : user = null, isLoading = false;

  const AuthSession.signedIn(this.user) : isLoading = false;

  final AuthenticatedUser? user;
  final bool isLoading;

  bool get isSignedIn => user != null;
}
