import 'package:postgres/postgres.dart';
import '../../domain/models/user.dart';
import '../db_connection.dart';

class UserRepository {
  final DbConnection _db;

  UserRepository(this._db);

  Future<User> createUser(String id, String email) async {
    final result = await _db.connection.execute(
      Sql.named('''
        INSERT INTO users (id, email) 
        VALUES (@id, @email) 
        ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email 
        RETURNING *
      '''),
      parameters: {'id': id, 'email': email},
    );

    if (result.isEmpty) {
      throw Exception('Failed to create or retrieve user');
    }

    return _mapRowToUser(result.first);
  }

  Future<User?> getUserById(String id) async {
    final result = await _db.connection.execute(
      Sql.named('SELECT * FROM users WHERE id = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;

    return _mapRowToUser(result.first);
  }

  User _mapRowToUser(List<dynamic> row) {
     // Postgres v3 returns rows as lists, mapped by column index if generic, 
     // but here we select * so we need to be careful or use mapped results if available via 'result.map'. 
     // However, `result.first` is a Row. row.toColumnMap() is the way.
     final map = (row as dynamic).toColumnMap(); // Casting to dynamic to access extension/method if needed or just rely on the Row type.
     // Actually result.first is of type Row. Row has toColumnMap().
     
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      createdAt: map['created_at'] as DateTime,
      updatedAt: map['updated_at'] as DateTime,
    );
  }
}
