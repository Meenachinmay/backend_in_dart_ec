// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) => Subscription(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      inventoryId: json['inventory_id'] as String,
      alertThreshold: (json['alert_threshold'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$SubscriptionToJson(Subscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'inventory_id': instance.inventoryId,
      'alert_threshold': instance.alertThreshold,
      'created_at': instance.createdAt.toIso8601String(),
    };
