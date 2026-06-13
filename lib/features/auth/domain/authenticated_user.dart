class AuthenticatedUser {
  const AuthenticatedUser({
    required this.uid,
    required this.email,
    required this.displayName,
  });

  final String uid;
  final String? email;
  final String? displayName;
}
