import 'package:json_annotation/json_annotation.dart';

part 'inventory.g.dart';

@JsonSerializable()
class Inventory {
  final String id;
  final String name;
  final double price;
  @JsonKey(name: 'discounted_price')
  final double? discountedPrice;
  @JsonKey(name: 'expiry_in')
  final int expiryIn;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Inventory({
    required this.id,
    required this.name,
    required this.price,
    this.discountedPrice,
    required this.expiryIn,
    required this.createdAt,
    required this.updatedAt,
  });

  Inventory copyWith({
    String? id,
    String? name,
    double? price,
    double? discountedPrice,
    int? expiryIn,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Inventory(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      expiryIn: expiryIn ?? this.expiryIn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Inventory.fromJson(Map<String, dynamic> json) => _$InventoryFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryToJson(this);
}
