import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/pet.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/user_provider.dart';

final petsProvider = FutureProvider.autoDispose<List<Pet>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  final repo = ref.watch(petsRepositoryProvider);
  return repo.listByUser(user.id);
});
