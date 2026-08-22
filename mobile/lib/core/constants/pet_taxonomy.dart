import 'package:flutter/material.dart';

/// Pet species/type taxonomy shared across listings, items, and pets.
///
/// Wire values are snake_case and match the enum name exactly.
enum PetType { dog, cat, bird, fish, rabbit, other }

extension PetTypeX on PetType {
  String get apiValue => name;

  static PetType fromApi(String? value) {
    if (value == null) return PetType.other;
    for (final type in PetType.values) {
      if (type.apiValue == value) return type;
    }
    return PetType.other;
  }

  /// Display label. When used as an unset filter placeholder, [other] reads
  /// as "All pets" via [filterLabel] instead.
  String get label {
    switch (this) {
      case PetType.dog:
        return 'Dog';
      case PetType.cat:
        return 'Cat';
      case PetType.bird:
        return 'Bird';
      case PetType.fish:
        return 'Fish';
      case PetType.rabbit:
        return 'Rabbit';
      case PetType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case PetType.dog:
        return Icons.pets_rounded;
      case PetType.cat:
        return Icons.cruelty_free_rounded;
      case PetType.bird:
        return Icons.flutter_dash_rounded;
      case PetType.fish:
        return Icons.set_meal_rounded;
      case PetType.rabbit:
        return Icons.cruelty_free_outlined;
      case PetType.other:
        return Icons.pets_outlined;
    }
  }
}

/// Catalog item categories used by store items.
enum ItemCategory { food, toys, cleaning, health, accessories, other }

extension ItemCategoryX on ItemCategory {
  String get apiValue => name;

  static ItemCategory fromApi(String? value) {
    if (value == null) return ItemCategory.other;
    for (final category in ItemCategory.values) {
      if (category.apiValue == value) return category;
    }
    return ItemCategory.other;
  }

  String get label {
    switch (this) {
      case ItemCategory.food:
        return 'Food';
      case ItemCategory.toys:
        return 'Toys';
      case ItemCategory.cleaning:
        return 'Cleaning';
      case ItemCategory.health:
        return 'Health';
      case ItemCategory.accessories:
        return 'Accessories';
      case ItemCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ItemCategory.food:
        return Icons.set_meal_outlined;
      case ItemCategory.toys:
        return Icons.toys_outlined;
      case ItemCategory.cleaning:
        return Icons.cleaning_services_outlined;
      case ItemCategory.health:
        return Icons.health_and_safety_outlined;
      case ItemCategory.accessories:
        return Icons.checkroom_outlined;
      case ItemCategory.other:
        return Icons.category_outlined;
    }
  }
}

List<PetType> petTypesFromJson(Object? value) {
  if (value is! List) return const [];
  return value
      .map((e) => PetTypeX.fromApi(e?.toString()))
      .toSet()
      .toList();
}

List<String> petTypesToJson(List<PetType> types) =>
    types.map((t) => t.apiValue).toList();
