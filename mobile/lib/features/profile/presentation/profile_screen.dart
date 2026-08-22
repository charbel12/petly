import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/api_error.dart';
import '../../../core/utils/whatsapp.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _openTrackedWhatsApp({
    required WidgetRef ref,
    required String phone,
    required String entityType,
    required String message,
    required String source,
  }) async {
    final user = ref.read(currentUserProvider).asData?.value;
    final deviceId = await ref.read(deviceIdProvider.future);
    await WhatsAppService.openChat(
      phone: phone,
      message: message,
      analytics: ref.read(analyticsRepositoryProvider),
      entityType: entityType,
      userId: user?.id,
      deviceId: deviceId,
      source: source,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final userAsync = ref.watch(currentUserProvider);
    final location = ref.watch(locationProvider);
    final signedIn = ref.watch(isAuthenticatedProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AsyncErrorView(
          error: e,
          onRetry: () => ref.read(currentUserProvider.notifier).refresh(),
        ),
        data: (user) {
          final tokens = AppTokens.of(context);
          final themeMode = ref.watch(themeModeProvider);
          final locale = ref.watch(localeProvider);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              SoftCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: tokens.onCard.withValues(alpha: 0.16),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: tokens.onCard,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.displayContact,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: tokens.onCardMuted,
                                ),
                          ),
                          if (user.role != null && !user.isGuest) ...[
                            const SizedBox(height: 2),
                            Text(
                              user.role!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: tokens.brandAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.profileEditTooltip,
                      onPressed: () => _editProfile(
                        context,
                        ref,
                        user.name,
                        user.phone ?? '',
                      ),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (signedIn)
                OutlinedButton(
                  onPressed: () => _signOut(context, ref),
                  child: Text(l10n.profileSignOut),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () => context.push('/login'),
                      child: Text(l10n.profileSignIn),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => context.push('/register'),
                      child: Text(l10n.profileCreateAccount),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Text(
                l10n.profileSettingsHeader,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              SoftCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      title: l10n.profileNotificationsTitle,
                      subtitle: l10n.profileNotificationsSubtitle,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.profileNotificationsSnack)),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.palette_outlined,
                      title: l10n.profileAppearanceTitle,
                      subtitle: _themeModeLabel(l10n, themeMode),
                      onTap: () => _pickThemeMode(context, ref, themeMode),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      title: l10n.profileLanguageTitle,
                      subtitle: _localeLabel(l10n, locale),
                      onTap: () => _pickLocale(context, ref, locale),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.my_location_rounded,
                      title: l10n.profileLocationTitle,
                      subtitle: location.when(
                        data: (loc) => loc.isGps
                            ? l10n.profileLocationGps(loc.label)
                            : l10n.profileLocationFallback(loc.label),
                        loading: () => l10n.profileLocationDetecting,
                        error: (e, st) => AppConstants.defaultLocationLabel,
                      ),
                      onTap: () async {
                        await ref.read(locationProvider.notifier).refresh();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.profileLocationRefreshedSnack),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (signedIn && user.isPartner)
                SoftCard(
                  onTap: () => context.push('/partner'),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: tokens.brandSecondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.storefront_rounded,
                          color: tokens.brandSecondary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.profilePartnerDashboardTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.profilePartnerDashboardSubtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: tokens.onCardMuted),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                )
              else if (signedIn && !user.isGuest && !user.isAdmin)
                SoftCard(
                  onTap: () => _becomePartner(context, ref),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: tokens.brandSecondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.handshake_rounded,
                          color: tokens.brandSecondary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.profileBecomePartnerTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.profileBecomePartnerSubtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: tokens.onCardMuted),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                )
              else if (!signedIn)
                SoftCard(
                  child: Row(
                    children: [
                      Icon(Icons.handshake_rounded, color: tokens.onCard),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          l10n.profileSignInPartnerPrompt,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              SoftCard(
                onTap: () => _openTrackedWhatsApp(
                  ref: ref,
                  phone: '96171123456',
                  entityType: 'support',
                  message: 'Hi Petly support',
                  source: 'profile_help',
                ),
                child: Row(
                  children: [
                    Icon(Icons.help_outline_rounded, color: tokens.onCard),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        l10n.profileHelpContact,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  l10n.profileTagline(
                    AppConstants.appName,
                    signedIn ? l10n.profileSignedInStatus : l10n.profileGuestStatus,
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _themeModeLabel(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.settingsThemeLight;
      case ThemeMode.dark:
        return l10n.settingsThemeDark;
      case ThemeMode.system:
        return l10n.settingsThemeSystem;
    }
  }

  String _localeLabel(AppLocalizations l10n, Locale? locale) {
    switch (locale?.languageCode) {
      case 'en':
        return l10n.profileLanguageEnglish;
      case 'ar':
        return l10n.profileLanguageArabic;
      default:
        return l10n.profileLanguageSystem;
    }
  }

  Future<void> _becomePartner(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileBecomePartnerDialogTitle),
        content: Text(l10n.profileBecomePartnerDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.profileBecomePartnerConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(authProvider.notifier).becomePartner();
      if (!context.mounted) return;
      context.go('/partner');
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyErrorMessage(context, error))),
      );
    }
  }

  Future<void> _pickThemeMode(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.profileAppearanceTitle),
        children: [
          RadioGroup<ThemeMode>(
            groupValue: current,
            onChanged: (value) {
              if (value != null) Navigator.pop(ctx, value);
            },
            child: Column(
              children: [
                for (final mode in ThemeMode.values)
                  RadioListTile<ThemeMode>(
                    value: mode,
                    title: Text(_themeModeLabel(l10n, mode)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (selected == null) return;
    await ref.read(themeModeProvider.notifier).setMode(selected);
  }

  /// `null` entry represents "follow system".
  Future<void> _pickLocale(
    BuildContext context,
    WidgetRef ref,
    Locale? current,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    const choices = <Locale?>[null, Locale('en'), Locale('ar')];
    final selected = await showDialog<_LocaleChoice>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.profileLanguageTitle),
        children: [
          RadioGroup<Locale?>(
            groupValue: current,
            onChanged: (value) {
              Navigator.pop(ctx, _LocaleChoice(value));
            },
            child: Column(
              children: [
                for (final locale in choices)
                  RadioListTile<Locale?>(
                    value: locale,
                    title: Text(_localeLabel(l10n, locale)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (selected == null) return;
    await ref.read(localeProvider.notifier).setLocale(selected.locale);
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileSignOutDialogTitle),
        content: Text(l10n.profileSignOutDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.profileSignOut),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authProvider.notifier).logout();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.profileSignOutSnack)),
    );
  }

  Future<void> _editProfile(
    BuildContext context,
    WidgetRef ref,
    String currentName,
    String currentPhone,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController(text: currentName);
    final phoneCtrl = TextEditingController(
      text: currentPhone.startsWith('device:') ? '' : currentPhone,
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileEditDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: l10n.profileEditNameLabel),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: InputDecoration(
                labelText: l10n.profileEditPhoneLabel,
                hintText: '+9617...',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );

    if (saved != true) return;
    try {
      await ref.read(currentUserProvider.notifier).updateProfile(
            name: nameCtrl.text,
            phone: phoneCtrl.text,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileUpdatedSnack)),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileUpdateFailedSnack('$e'))),
      );
    }
  }
}

/// Wraps a nullable [Locale] so `showDialog<Locale?>` can distinguish
/// "dialog dismissed" (null) from "system default selected" (Locale? null).
class _LocaleChoice {
  const _LocaleChoice(this.locale);
  final Locale? locale;
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTokens.of(context).onCard),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppTokens.of(context).onCardMuted),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
