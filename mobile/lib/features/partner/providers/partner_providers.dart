import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/repositories/partners_repository.dart';

final partnerListingsProvider = FutureProvider.autoDispose<PartnerListings>((ref) {
  return ref.watch(partnersRepositoryProvider).listMine();
});
