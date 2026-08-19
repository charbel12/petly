class GoogleSignInCanceled implements Exception {}

class GoogleSignInUnavailable implements Exception {
  GoogleSignInUnavailable(this.message);
  final String message;

  @override
  String toString() => message;
}
