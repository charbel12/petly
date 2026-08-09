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
    this.latitude,
    this.longitude,
    this.distanceKm,
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
  final double? latitude;
  final double? longitude;
  final double? distanceKm;

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
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  String get distanceLabel {
    if (distanceKm == null) return location;
    if (distanceKm! < 1) {
      return '${(distanceKm! * 1000).round()} m away';
    }
    return '${distanceKm!.toStringAsFixed(1)} km away';
  }
}
