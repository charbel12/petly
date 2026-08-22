import '../../core/constants/pet_taxonomy.dart';
import 'listing_hours.dart';

class Vet {
  const Vet({
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
    required this.services,
    required this.verified,
    required this.isEmergency,
    required this.isOpenNow,
    required this.featured,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.petTypes = const [],
    this.status,
    this.hours,
    this.rejectionReason,
    this.submittedAt,
    this.avgRating = 0,
    this.ratingCount = 0,
  });

  final String id;
  final String name;
  final String phone;
  final String location;
  final List<String> services;
  final bool verified;
  final bool isEmergency;
  final bool isOpenNow;
  final bool featured;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final List<PetType> petTypes;
  final String? status;
  final ListingHours? hours;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final double avgRating;
  final int ratingCount;

  factory Vet.fromJson(Map<String, dynamic> json) {
    return Vet(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      location: json['location'] as String,
      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      verified: json['verified'] as bool? ?? false,
      isEmergency: json['is_emergency'] as bool? ?? false,
      isOpenNow: json['is_open_now'] as bool? ?? true,
      featured: json['featured'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      petTypes: petTypesFromJson(json['pet_types']),
      status: json['status'] as String?,
      hours: ListingHours.tryParse(json['hours']),
      rejectionReason: json['rejection_reason'] as String?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.tryParse(json['submitted_at'].toString())
          : null,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0,
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
    );
  }

  String get heroTag => 'vet-$id';

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
