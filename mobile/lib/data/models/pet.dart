import '../../core/constants/pet_taxonomy.dart';

class Pet {
  const Pet({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.age,
  });

  final String id;
  final String userId;
  final String name;
  final PetType type;
  final double age;

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      type: PetTypeX.fromApi(json['type'] as String?),
      age: (json['age'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'user_id': userId,
        'name': name,
        'type': type.apiValue,
        'age': age,
      };

  String get ageLabel {
    if (age == age.roundToDouble()) {
      final years = age.toInt();
      return years == 1 ? '1 year' : '$years years';
    }
    return '$age years';
  }
}
