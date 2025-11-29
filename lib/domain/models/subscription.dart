import 'package:json_annotation/json_annotation.dart';

part 'subscription.g.dart';

@JsonSerializable()
class Subscription {
  final String? id;
  
  @JsonKey(name: 'user_id')
  final String userId;
  
  @JsonKey(name: 'inventory_id')
  final String inventoryId;
  
  @JsonKey(name: 'alert_threshold')
  final int alertThreshold;
  
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  @JsonKey(name: 'item_name')
  final String? itemName;

  Subscription({
    this.id,
    required this.userId,
    required this.inventoryId,
    required this.alertThreshold,
    this.createdAt,
    this.itemName,
  });

  // Use the generated methods from the part file
  factory Subscription.fromJson(Map<String, dynamic> json) => _$SubscriptionFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionToJson(this);
}