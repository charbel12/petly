class Store {
  const Store({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.featured,
    required this.isOpenNow,
    this.phone,
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  final String id;
  final String name;
  final String type;
  final String location;
  final String? phone;
  final bool featured;
  final bool isOpenNow;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      location: json['location'] as String,
      phone: json['phone'] as String?,
      featured: json['featured'] as bool? ?? false,
      isOpenNow: json['is_open_now'] as bool? ?? true,
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
