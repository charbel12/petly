import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/models/store_item.dart';
import '../../../data/repositories/partners_repository.dart';

final partnerListingsProvider = FutureProvider.autoDispose<PartnerListings>((ref) {
  return ref.watch(partnersRepositoryProvider).listMine();
});

final partnerStoreItemsProvider =
    FutureProvider.autoDispose.family<List<StoreItem>, String>((ref, storeId) {
  return ref.watch(partnersRepositoryProvider).listStoreItems(storeId);
});
