import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/user.dart';
import 'app_providers.dart';

const _kDeviceId = 'petly_device_id';
const _kUserId = 'petly_user_id';
const _kUserName = 'petly_user_name';
const _kUserPhone = 'petly_user_phone';

class CurrentUserNotifier extends AsyncNotifier<User> {
  @override
  Future<User> build() => _ensureUser();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _ensureUser());
  }

  Future<User> updateProfile({
    required String name,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = await _deviceId(prefs);
    final repo = ref.read(usersRepositoryProvider);
    final user = await repo.create(
      name: name.trim().isEmpty ? 'Petly User' : name.trim(),
      phone: phone.trim().isEmpty ? 'device:$deviceId' : phone.trim(),
      deviceId: deviceId,
    );
    await _persist(prefs, user);
    state = AsyncData(user);
    return user;
  }

  Future<User> _ensureUser() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = await _deviceId(prefs);
    final repo = ref.read(usersRepositoryProvider);

    final cachedId = prefs.getString(_kUserId);
    final cachedName = prefs.getString(_kUserName);
    final cachedPhone = prefs.getString(_kUserPhone);

    if (cachedId != null && cachedName != null && cachedPhone != null) {
      return User(
        id: cachedId,
        name: cachedName,
        phone: cachedPhone,
        deviceId: deviceId,
      );
    }

    try {
      final existing = await repo.getByDeviceId(deviceId);
      if (existing != null) {
        await _persist(prefs, existing);
        return existing;
      }
    } catch (_) {
      // Fall through to create.
    }

    try {
      final user = await repo.create(
        name: 'Petly User',
        phone: 'device:$deviceId',
        deviceId: deviceId,
      );
      await _persist(prefs, user);
      return user;
    } catch (_) {
      // Offline first launch — keep a local guest until API is reachable.
      final local = User(
        id: 'local-$deviceId',
        name: 'Petly User',
        phone: 'device:$deviceId',
        deviceId: deviceId,
      );
      await _persist(prefs, local);
      return local;
    }
  }

  Future<String> _deviceId(SharedPreferences prefs) async {
    final existing = prefs.getString(_kDeviceId);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = const Uuid().v4();
    await prefs.setString(_kDeviceId, id);
    return id;
  }

  Future<void> _persist(SharedPreferences prefs, User user) async {
    await prefs.setString(_kUserId, user.id);
    await prefs.setString(_kUserName, user.name);
    await prefs.setString(_kUserPhone, user.phone);
    if (user.deviceId != null) {
      await prefs.setString(_kDeviceId, user.deviceId!);
    }
  }
}

final currentUserProvider =
    AsyncNotifierProvider<CurrentUserNotifier, User>(CurrentUserNotifier.new);

final deviceIdProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final existing = prefs.getString(_kDeviceId);
  if (existing != null && existing.isNotEmpty) return existing;
  final id = const Uuid().v4();
  await prefs.setString(_kDeviceId, id);
  return id;
});

/// Convenience when a sync user id is needed; null while loading.
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider).asData?.value.id;
});
