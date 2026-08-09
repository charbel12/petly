import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/api_client.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../data/repositories/pets_repository.dart';
import '../../data/repositories/stores_repository.dart';
import '../../data/repositories/users_repository.dart';
import '../../data/repositories/vets_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final vetsRepositoryProvider = Provider<VetsRepository>(
  (ref) => VetsRepository(ref.watch(apiClientProvider)),
);

final storesRepositoryProvider = Provider<StoresRepository>(
  (ref) => StoresRepository(ref.watch(apiClientProvider)),
);

final petsRepositoryProvider = Provider<PetsRepository>(
  (ref) => PetsRepository(ref.watch(apiClientProvider)),
);

final usersRepositoryProvider = Provider<UsersRepository>(
  (ref) => UsersRepository(ref.watch(apiClientProvider)),
);

final analyticsRepositoryProvider = Provider<AnalyticsRepository>(
  (ref) => AnalyticsRepository(ref.watch(apiClientProvider)),
);
