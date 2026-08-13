class User {
  const User({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.role,
    this.status,
    this.deviceId,
  });

  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? role;
  final String? status;
  final String? deviceId;

  bool get isGuest => email == null || email!.isEmpty;

  String get displayContact {
    if (email != null && email!.isNotEmpty) return email!;
    final phoneValue = phone;
    if (phoneValue == null || phoneValue.startsWith('device:')) {
      return 'Guest account';
    }
    return phoneValue;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      status: json['status'] as String?,
      deviceId: json['device_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'role': role,
        'status': status,
        if (deviceId != null) 'device_id': deviceId,
      };

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? role,
    String? status,
    String? deviceId,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}
