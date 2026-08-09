import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/app_constants.dart';

enum LocationSource { gps, fallback }

class AppLocation {
  const AppLocation({
    required this.lat,
    required this.lng,
    required this.label,
    required this.source,
    this.errorMessage,
  });

  final double lat;
  final double lng;
  final String label;
  final LocationSource source;
  final String? errorMessage;

  bool get isGps => source == LocationSource.gps;

  static const fallback = AppLocation(
    lat: AppConstants.defaultLat,
    lng: AppConstants.defaultLng,
    label: AppConstants.defaultLocationLabel,
    source: LocationSource.fallback,
  );
}

class LocationNotifier extends AsyncNotifier<AppLocation> {
  @override
  Future<AppLocation> build() => _resolve(requestPermission: true);

  Future<void> refresh({bool requestPermission = true}) async {
    state = const AsyncLoading();
    state = AsyncData(await _resolve(requestPermission: requestPermission));
  }

  Future<AppLocation> _resolve({required bool requestPermission}) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return AppLocation.fallback.copyWithMessage(
          'Location services are off — showing Beirut',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return AppLocation.fallback.copyWithMessage(
          'Location permission denied — showing Beirut',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return AppLocation(
        lat: position.latitude,
        lng: position.longitude,
        label: 'Near you',
        source: LocationSource.gps,
      );
    } catch (_) {
      return AppLocation.fallback.copyWithMessage(
        'Could not get GPS — showing Beirut',
      );
    }
  }
}

extension on AppLocation {
  AppLocation copyWithMessage(String message) {
    return AppLocation(
      lat: lat,
      lng: lng,
      label: label,
      source: source,
      errorMessage: message,
    );
  }
}

final locationProvider =
    AsyncNotifierProvider<LocationNotifier, AppLocation>(LocationNotifier.new);

final userLatProvider = Provider<double>((ref) {
  return ref.watch(locationProvider).asData?.value.lat ??
      AppConstants.defaultLat;
});

final userLngProvider = Provider<double>((ref) {
  return ref.watch(locationProvider).asData?.value.lng ??
      AppConstants.defaultLng;
});

final locationLabelProvider = Provider<String>((ref) {
  return ref.watch(locationProvider).asData?.value.label ??
      AppConstants.defaultLocationLabel;
});
