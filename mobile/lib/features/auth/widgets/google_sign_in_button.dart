import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/auth/google_sign_in.dart';
import '../../../core/auth/google_sign_in_errors.dart';
import '../../../core/auth/google_web_support.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/api_error.dart';

class ContinueWithGoogleButton extends StatefulWidget {
  const ContinueWithGoogleButton({
    super.key,
    required this.onIdToken,
    this.enabled = true,
  });

  final Future<void> Function(String idToken) onIdToken;
  final bool enabled;

  @override
  State<ContinueWithGoogleButton> createState() =>
      _ContinueWithGoogleButtonState();
}

class _ContinueWithGoogleButtonState extends State<ContinueWithGoogleButton> {
  StreamSubscription<GoogleSignInAuthenticationEvent>? _events;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb && AppConstants.googleSignInConfigured) {
      _listenOnWeb();
    }
  }

  Future<void> _listenOnWeb() async {
    try {
      await GoogleSignInService.instance.initialize();
      _events = GoogleSignIn.instance.authenticationEvents.listen((event) {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          final token = event.user.authentication.idToken;
          if (token != null && token.isNotEmpty) {
            unawaited(_handleToken(token));
          }
        }
      });
    } catch (_) {
      // Button tap / renderButton still surface a message if init failed.
    }
  }

  @override
  void dispose() {
    _events?.cancel();
    super.dispose();
  }

  Future<void> _handleToken(String idToken) async {
    if (_busy || !widget.enabled) return;
    setState(() => _busy = true);
    try {
      await widget.onIdToken(idToken);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyErrorMessage(error))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onPressed() async {
    if (_busy || !widget.enabled) return;
    if (!AppConstants.googleSignInConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Google sign-in is not configured. Add GOOGLE_WEB_CLIENT_ID.',
          ),
        ),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final token = await GoogleSignInService.instance.idToken();
      await widget.onIdToken(token);
    } on GoogleSignInCanceled {
      return;
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyErrorMessage(error))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    if (kIsWeb && AppConstants.googleSignInConfigured) {
      return Column(
        children: [
          if (_busy) const LinearProgressIndicator(),
          Center(child: renderGoogleButton()),
        ],
      );
    }

    return OutlinedButton(
      onPressed: widget.enabled && !_busy ? _onPressed : null,
      child: _busy
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: tokens.brandPrimary,
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.g_mobiledata_rounded, size: 22),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Continue with Google',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );
  }
}

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: tokens.onCardMuted.withValues(alpha: 0.4))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'or',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.onCardMuted,
                  ),
            ),
          ),
          Expanded(child: Divider(color: tokens.onCardMuted.withValues(alpha: 0.4))),
        ],
      ),
    );
  }
}
