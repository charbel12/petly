import 'listing_hours.dart';

class Store {
  const Store({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.featured,
    required this.isOpenNow,
    this.phone,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.services = const [],
    this.status,
    this.hours,
    this.rejectionReason,
    this.submittedAt,
  });

  final String id;
  final String name;
  final String type;
  final String location;
  final String? phone;
  final String? imageUrl;
  final bool featured;
  final bool isOpenNow;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final List<String> services;
  final String? status;
  final ListingHours? hours;
  final String? rejectionReason;
  final DateTime? submittedAt;

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      location: json['location'] as String,
      phone: json['phone'] as String?,
      imageUrl: json['image_url'] as String?,
      featured: json['featured'] as bool? ?? false,
      isOpenNow: json['is_open_now'] as bool? ?? true,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      status: json['status'] as String?,
      hours: ListingHours.tryParse(json['hours']),
      rejectionReason: json['rejection_reason'] as String?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.tryParse(json['submitted_at'].toString())
          : null,
    );
  }

  String get heroTag => 'store-$id';

  String get distanceOnly {
    if (distanceKm == null) return '';
    if (distanceKm! < 1) {
      return '${(distanceKm! * 1000).round()} m away';
    }
    return '${distanceKm!.toStringAsFixed(1)} km away';
  }

  String get distanceLabel {
    if (distanceKm == null) return location;
    return distanceOnly;
  }

  String get distanceAndLocation {
    if (distanceKm == null) return location;
    return '$distanceOnly · $location';
  }
}
