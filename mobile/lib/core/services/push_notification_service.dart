import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../providers/auth_provider.dart';

/// Bootstraps Firebase Cloud Messaging and registers this device's push
/// token with the backend when a user is signed in.
///
/// There is no `google-services.json`/`GoogleService-Info.plist` checked
/// into this repo yet (see docs/PUSH_NOTIFICATIONS_SETUP.md for the manual
/// steps to add one), so [Firebase.initializeApp] is expected to fail on a
/// fresh checkout — every step below is defensive so a missing/misconfigured
/// Firebase project never crashes the app or blocks startup.
class PushNotificationService {
  PushNotificationService(this._ref);

  final Ref _ref;
  bool _initialized = false;

  /// A global key the app can attach to its top-level [Navigator]/
  /// [ScaffoldMessenger] so foreground push messages can show a SnackBar
  /// even though this service has no [BuildContext] of its own.
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await Firebase.initializeApp();
    } catch (error, stack) {
      developer.log(
        'Firebase.initializeApp failed — push notifications disabled. '
        'This is expected until google-services.json / '
        'GoogleService-Info.plist are added (see '
        'docs/PUSH_NOTIFICATIONS_SETUP.md).',
        name: 'PushNotificationService',
        error: error,
        stackTrace: stack,
      );
      return;
    }

    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      final token = await messaging.getToken();
      if (token != null) {
        await _registerToken(token);
      }
      messaging.onTokenRefresh.listen(_registerToken);

      FirebaseMessaging.onMessage.listen((message) {
        final title = message.notification?.title;
        final body = message.notification?.body;
        final text = [
          title,
          body,
        ].where((s) => s != null && s.isNotEmpty).join(': ');
        if (text.isEmpty) return;

        final messenger = scaffoldMessengerKey.currentState;
        if (messenger != null) {
          messenger.showSnackBar(SnackBar(content: Text(text)));
        } else {
          developer.log(
            'Foreground push received (no scaffold messenger attached): $text',
            name: 'PushNotificationService',
          );
        }
      });
    } catch (error, stack) {
      developer.log(
        'Push notification setup failed after Firebase init.',
        name: 'PushNotificationService',
        error: error,
        stackTrace: stack,
      );
    }
  }

  String get _platform {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    return 'android';
  }

  Future<void> _registerToken(String token) async {
    try {
      final user = await _ref.read(authProvider.future);
      if (user == null) return; // Only registered users get pushes for now.
      await _ref.read(notificationsRepositoryProvider).registerToken(
            token: token,
            platform: _platform,
          );
    } catch (error, stack) {
      developer.log(
        'Failed to register push token with backend.',
        name: 'PushNotificationService',
        error: error,
        stackTrace: stack,
      );
    }
  }

  /// Best-effort unregister, called from the logout flow. Never throws —
  /// logout must succeed even if this fails.
  Future<void> unregisterCurrentToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await _ref.read(notificationsRepositoryProvider).unregisterToken(token);
    } catch (error, stack) {
      developer.log(
        'Failed to unregister push token on logout.',
        name: 'PushNotificationService',
        error: error,
        stackTrace: stack,
      );
    }
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>(
  (ref) => PushNotificationService(ref),
);
