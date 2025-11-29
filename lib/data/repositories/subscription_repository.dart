import 'package:postgres/postgres.dart';
import '../../domain/models/subscription.dart';
import '../db_connection.dart';

class SubscriptionRepository {
  final DbConnection _db;

  SubscriptionRepository(this._db);

  Future<Subscription> createSubscription(String userId, String inventoryId, int alertThreshold) async {
    final result = await _db.connection.execute(
      Sql.named('''
        INSERT INTO subscriptions (user_id, inventory_id, alert_threshold) 
        VALUES (@userId, @inventoryId, @alertThreshold) 
        RETURNING *
      '''),
      parameters: {
        'userId': userId,
        'inventoryId': inventoryId,
        'alertThreshold': alertThreshold,
      },
    );

    if (result.isEmpty) {
      throw Exception('Failed to create subscription');
    }

    return _mapRowToSubscription(result.first);
  }

  Future<List<Subscription>> getSubscriptionsByUser(String userId) async {
    final result = await _db.connection.execute(
      Sql.named('''
        SELECT s.*, i.name as item_name 
        FROM subscriptions s
        JOIN inventory i ON s.inventory_id = i.id
        WHERE s.user_id = @userId
      '''),
      parameters: {'userId': userId},
    );

    return result.map((row) => _mapRowToSubscription(row)).toList();
  }

  Future<void> deleteSubscription(String id) async {
    await _db.connection.execute(
      Sql.named('DELETE FROM subscriptions WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  Future<List<Map<String, dynamic>>> getDueSubscriptions() async {
    final result = await _db.connection.execute('''
      SELECT s.id as sub_id, u.email, i.name as item_name, i.expiry_in
      FROM subscriptions s
      JOIN inventory i ON s.inventory_id = i.id
      JOIN users u ON s.user_id = u.id
      WHERE i.expiry_in = s.alert_threshold
    ''');

    return result.map((row) {
      final map = row.toColumnMap();
      return {
        'subscription_id': map['sub_id'],
        'email': map['email'],
        'item_name': map['item_name'],
        'days_left': map['expiry_in'],
      };
    }).toList();
  }

  Subscription _mapRowToSubscription(dynamic row) {
    final map = row.toColumnMap();
    return Subscription(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      inventoryId: map['inventory_id'] as String,
      alertThreshold: map['alert_threshold'] as int,
      createdAt: map['created_at'] as DateTime,
      itemName: map['item_name'] as String?,
    );
  }
}
