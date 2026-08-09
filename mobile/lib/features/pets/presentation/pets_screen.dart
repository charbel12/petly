import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../data/models/pet.dart';
import '../providers/pets_providers.dart';

class PetsScreen extends ConsumerWidget {
  const PetsScreen({super.key});

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'dog':
        return Icons.pets_rounded;
      case 'cat':
        return Icons.cruelty_free_rounded;
      case 'bird':
        return Icons.flutter_dash_rounded;
      default:
        return Icons.pets_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Pets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/pets/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add pet'),
      ),
      body: petsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => AsyncErrorView(
          error: error,
          onRetry: () => ref.invalidate(petsProvider),
        ),
        data: (pets) {
          if (pets.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.pets_rounded,
                      size: 64,
                      color: const Color(AppColors.primary).withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No pets yet',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add your first pet to keep their info handy.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(AppColors.primary),
            onRefresh: () async {
              ref.invalidate(petsProvider);
              await ref.read(petsProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return _PetCard(
                  pet: pet,
                  icon: _iconForType(pet.type),
                  onDelete: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Remove pet?'),
                        content: Text('Remove ${pet.name} from your list?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true) return;
                    await ref.read(petsRepositoryProvider).delete(pet.id);
                    ref.invalidate(petsProvider);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({
    required this.pet,
    required this.icon,
    required this.onDelete,
  });

  final Pet pet;
  final IconData icon;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(AppColors.primary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(AppColors.primary), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pet.type} · ${pet.ageLabel}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(AppColors.muted),
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            color: const Color(AppColors.muted),
          ),
        ],
      ),
    );
  }
}
