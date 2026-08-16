import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_tokens.dart';
import '../utils/api_error.dart';

class AsyncErrorView extends StatelessWidget {
  const AsyncErrorView({
    super.key,
    required this.error,
    required this.onRetry,
    this.compact = false,
  });

  final Object error;
  final VoidCallback onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final message = friendlyErrorMessage(error);
    final isOffline = error is ApiException && (error as ApiException).isOffline;

    if (compact) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tokens.danger.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              size: 48,
              color: tokens.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              isOffline ? 'You\'re offline' : 'Something went wrong',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textMuted,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(AppColors.blackForest),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: Color(AppColors.cornsilk),
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'No internet connection',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(AppColors.cornsilk),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
