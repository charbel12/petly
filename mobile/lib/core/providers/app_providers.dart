import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/api_client.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/pets_repository.dart';
import '../../data/repositories/stores_repository.dart';
import '../../data/repositories/users_repository.dart';
import '../../data/repositories/vets_repository.dart';
import '../auth/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(tokenStorage: ref.watch(tokenStorageProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

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
