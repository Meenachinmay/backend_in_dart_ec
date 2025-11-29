import 'package:postgres/postgres.dart';
import '../../domain/models/inventory.dart';
import '../db_connection.dart';

class InventoryRepository {
  final DbConnection _db;

  InventoryRepository(this._db);

  Future<List<Inventory>> getAllInventory() async {
    final result = await _db.connection.execute('SELECT * FROM inventory');

    return result.map((row) => _mapRowToInventory(row)).toList();
  }

  Future<Inventory?> getInventoryById(String id) async {
    final result = await _db.connection.execute(
      Sql.named('SELECT * FROM inventory WHERE id = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;
    return _mapRowToInventory(result.first);
  }

  Inventory _mapRowToInventory(dynamic row) {
    final map = row.toColumnMap();
    return Inventory(
      id: map['id'] as String,
      name: map['name'] as String,
      price: double.parse(map['price'].toString()), // Postgres numeric might be string or Num
      expiryIn: map['expiry_in'] as int,
      createdAt: map['created_at'] as DateTime,
      updatedAt: map['updated_at'] as DateTime,
      // discountedPrice is not stored in DB permanently as per prompt logic (calculated on fly),
      // but the schema has the column. I'll leave it null here and let Service layer handle calculation.
      discountedPrice: map['discounted_price'] != null 
          ? double.parse(map['discounted_price'].toString()) 
          : null,
    );
  }
}
