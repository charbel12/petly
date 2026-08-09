class User {
  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.deviceId,
  });

  final String id;
  final String name;
  final String phone;
  final String? deviceId;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      deviceId: json['device_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        if (deviceId != null) 'device_id': deviceId,
      };

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? deviceId,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}
