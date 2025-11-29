import 'package:postgres/postgres.dart';

class DbConnection {
  final Connection _connection;

  DbConnection(this._connection);

  Connection get connection => _connection;

  static Future<DbConnection> connect({
    required String host,
    required int port,
    required String database,
    required String user,
    required String password,
  }) async {
    final endpoint = Endpoint(
      host: host,
      port: port,
      database: database,
      username: user,
      password: password,
    );
    
    final connection = await Connection.open(endpoint, settings: ConnectionSettings(sslMode: SslMode.disable));
    return DbConnection(connection);
  }
}
