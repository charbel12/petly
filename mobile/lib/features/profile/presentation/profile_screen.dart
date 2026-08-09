import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/utils/whatsapp.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/soft_card.dart';

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
    final userAsync = ref.watch(currentUserProvider);
    final location = ref.watch(locationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AsyncErrorView(
          error: e,
          onRetry: () => ref.read(currentUserProvider.notifier).refresh(),
        ),
        data: (user) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              SoftCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(AppColors.primary)
                          .withValues(alpha: 0.15),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(AppColors.primary),
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
                            user.phone.startsWith('device:')
                                ? 'Guest account'
                                : user.phone,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: const Color(AppColors.muted),
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit profile',
                      onPressed: () => _editProfile(context, ref, user.name, user.phone),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Settings',
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
                      title: 'Notifications',
                      subtitle: 'Coming in a later phase',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Push notifications planned for Phase 3'),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.my_location_rounded,
                      title: 'Location',
                      subtitle: location.when(
                        data: (loc) => loc.isGps
                            ? 'Using GPS · ${loc.label}'
                            : 'Fallback · ${loc.label}',
                        loading: () => 'Detecting...',
                        error: (e, st) => AppConstants.defaultLocationLabel,
                      ),
                      onTap: () async {
                        await ref.read(locationProvider.notifier).refresh();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Location refreshed')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SoftCard(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Become a Partner'),
                      content: const Text(
                        'Are you a vet clinic or pet store in Lebanon?\n\n'
                        'Message us on WhatsApp and we\'ll onboard you manually '
                        '(Phase 2).',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Close'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await _openTrackedWhatsApp(
                              ref: ref,
                              phone: '96171123456',
                              entityType: 'partner',
                              message:
                                  'Hi, I want to become a Petly partner',
                              source: 'profile_partner',
                            );
                          },
                          child: const Text('Contact us'),
                        ),
                      ],
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(AppColors.secondary)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.handshake_rounded,
                        color: Color(AppColors.secondary),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Become a Partner',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'List your clinic or store on Petly',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: const Color(AppColors.muted),
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
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
                child: const Row(
                  children: [
                    Icon(Icons.help_outline_rounded,
                        color: Color(AppColors.primary)),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Help & contact',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  '${AppConstants.appName} · Phase 1.5\nDevice-bound guest account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(AppColors.muted),
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editProfile(
    BuildContext context,
    WidgetRef ref,
    String currentName,
    String currentPhone,
  ) async {
    final nameCtrl = TextEditingController(text: currentName);
    final phoneCtrl = TextEditingController(
      text: currentPhone.startsWith('device:') ? '' : currentPhone,
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Phone (optional)',
                hintText: '+9617...',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
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
        const SnackBar(content: Text('Profile updated')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update profile: $e')),
      );
    }
  }
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
      leading: Icon(icon, color: const Color(AppColors.primary)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
