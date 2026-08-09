import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/utils/whatsapp.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/soft_card.dart';
import '../providers/stores_providers.dart';

class StoreDetailScreen extends ConsumerWidget {
  const StoreDetailScreen({super.key, required this.storeId});

  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(storeDetailProvider(storeId));

    return Scaffold(
      appBar: AppBar(title: const Text('Store details')),
      body: storeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => AsyncErrorView(
          error: error,
          onRetry: () => ref.invalidate(storeDetailProvider(storeId)),
        ),
        data: (store) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            store.type,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(AppColors.secondary),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.place_outlined,
                                color: Color(AppColors.primary),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(store.location)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.near_me_outlined,
                                color: Color(AppColors.primary),
                              ),
                              const SizedBox(width: 8),
                              Text(store.distanceLabel),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                color: Color(AppColors.primary),
                              ),
                              const SizedBox(width: 8),
                              Text(store.isOpenNow ? 'Open now' : 'Closed'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (store.phone != null)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final user = ref.read(currentUserProvider).asData?.value;
                        final deviceId = await ref.read(deviceIdProvider.future);
                        final ok = await WhatsAppService.openChat(
                          phone: store.phone!,
                          analytics: ref.read(analyticsRepositoryProvider),
                          entityType: 'store',
                          entityId: store.id,
                          userId: user?.id,
                          deviceId: deviceId,
                          source: 'detail',
                        );
                        if (!context.mounted) return;
                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not open WhatsApp'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.chat_rounded),
                      label: const Text('Chat on WhatsApp'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        minimumSize: const Size.fromHeight(56),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
