import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user.dart';
import 'app_providers.dart';

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final api = ref.read(apiClientProvider);
    api.onSessionExpired = () {
      state = const AsyncData(null);
    };
    return ref.read(authRepositoryProvider).restore();
  }

  Future<String?> _deviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('petly_device_id');
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final deviceId = await _deviceId();
      final user = await ref.read(authRepositoryProvider).login(
            email: email,
            password: password,
            deviceId: deviceId,
          );
      state = AsyncData(user);
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? role,
  }) async {
    state = const AsyncLoading();
    try {
      final deviceId = await _deviceId();
      final user = await ref.read(authRepositoryProvider).register(
            name: name,
            email: email,
            password: password,
            phone: phone,
            deviceId: deviceId,
            role: role,
          );
      state = AsyncData(user);
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }

  Future<void> becomePartner() async {
    state = const AsyncLoading();
    try {
      final user = await ref.read(authRepositoryProvider).becomePartner();
      state = AsyncData(user);
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }

  Future<String> forgotPassword(String email) {
    return ref.read(authRepositoryProvider).forgotPassword(email);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).asData?.value != null;
});
