import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../constants/app_constants.dart';
import 'google_sign_in_errors.dart';

class GoogleSignInService {
  GoogleSignInService._();
  static final GoogleSignInService instance = GoogleSignInService._();

  Completer<void>? _ready;

  Future<void> initialize() async {
    if (!AppConstants.googleSignInConfigured) {
      throw GoogleSignInUnavailable(
        'Google sign-in is not configured. Set GOOGLE_WEB_CLIENT_ID.',
      );
    }
    if (_ready != null) return _ready!.future;
    _ready = Completer<void>();
    try {
      await GoogleSignIn.instance.initialize(
        clientId: kIsWeb
            ? AppConstants.googleWebClientId
            : (AppConstants.googleIosClientId.isEmpty
                ? null
                : AppConstants.googleIosClientId),
        serverClientId: kIsWeb ? null : AppConstants.googleWebClientId,
      );
      _ready!.complete();
    } catch (error, stack) {
      final failed = _ready!;
      _ready = null;
      failed.completeError(error, stack);
      rethrow;
    }
  }

  Future<String> idToken() async {
    await initialize();
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw GoogleSignInUnavailable(
        'Google sign-in is not available on this platform.',
      );
    }
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final token = account.authentication.idToken;
      if (token == null || token.isEmpty) {
        throw GoogleSignInUnavailable('Google did not return an ID token.');
      }
      await GoogleSignIn.instance.signOut();
      return token;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw GoogleSignInCanceled();
      }
      throw GoogleSignInUnavailable(
        error.description ?? 'Google sign-in failed.',
      );
    }
  }
}
