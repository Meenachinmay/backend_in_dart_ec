import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class FirebaseService {
  final String _serviceAccountPath;
  late final AutoRefreshingAuthClient _client;
  late final FirestoreApi _firestore;
  String? _projectId;
  
  // Cache for Google's public keys
  Map<String, String> _publicKeys = {};
  DateTime? _keysExpiry;

  FirebaseService(this._serviceAccountPath);

  Future<void> initialize() async {
    final file = File(_serviceAccountPath);
    if (!file.existsSync()) {
      throw Exception('Service account file not found at $_serviceAccountPath');
    }

    final jsonString = await file.readAsString();
    final jsonMap = jsonDecode(jsonString);
    _projectId = jsonMap['project_id'];
    final creds = ServiceAccountCredentials.fromJson(jsonString);

    _client = await clientViaServiceAccount(creds, [
      FirestoreApi.datastoreScope,
      'https://www.googleapis.com/auth/cloud-platform',
    ]);

    _firestore = FirestoreApi(_client);
  }

  /// Verifies a Firebase ID Token.
  /// Returns the decoded payload if valid, throws otherwise.
  Future<Map<String, dynamic>> verifyToken(String token) async {
    await _ensurePublicKeys();

    try {
      // Decode header to find 'kid'
      final jwt = JWT.decode(token);
      final kid = jwt.header?['kid'];

      if (kid == null || !_publicKeys.containsKey(kid)) {
        throw Exception('Unknown or invalid key ID (kid)');
      }

      final publicKeyPem = _publicKeys[kid]!;
      
      // Verify signature
      // Note: RS256 is the algorithm. dart_jsonwebtoken needs the PEM.
      // Google provides X.509 certs. We might need to wrap them or use them directly.
      // The endpoint returns standard X.509 certificates.
      // dart_jsonwebtoken's RSAPublicKey expects a PEM string.
      
      final verified = JWT.verify(token, RSAPublicKey(publicKeyPem));
      
      // Verify Claims
      final payload = verified.payload;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      if (payload['aud'] != _projectId) {
        throw Exception('Invalid audience');
      }
      if (payload['iss'] != 'https://securetoken.google.com/$_projectId') {
        throw Exception('Invalid issuer');
      }
      if (payload['exp'] < now) {
        throw Exception('Token expired');
      }

      return payload;
    } catch (e) {
      print('Token verification failed: $e');
      throw Exception('Invalid Token: $e');
    }
  }

  Future<void> _ensurePublicKeys() async {
    if (_publicKeys.isNotEmpty && _keysExpiry != null && _keysExpiry!.isAfter(DateTime.now())) {
      return;
    }

    final response = await http.get(Uri.parse(
        'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      _publicKeys = data.map((key, value) => MapEntry(key, value.toString()));
      
      // Cache-Control header usually contains max-age
      final cacheControl = response.headers['cache-control'];
      int maxAge = 3600; // Default 1 hour
      if (cacheControl != null) {
        final match = RegExp(r'max-age=(\d+)').firstMatch(cacheControl);
        if (match != null) {
          maxAge = int.parse(match.group(1)!);
        }
      }
      _keysExpiry = DateTime.now().add(Duration(seconds: maxAge));
    } else {
      throw Exception('Failed to fetch Google public keys');
    }
  }

  /// Adds a notification document to Firestore
  Future<void> addNotification(Map<String, dynamic> data) async {
    if (_projectId == null) throw Exception('FirebaseService not initialized');

    final document = Document(fields: _mapToFields(data));
    
    await _firestore.projects.databases.documents.createDocument(
      document,
      'projects/$_projectId/databases/(default)/documents',
      'notifications',
    );
  }

  Map<String, Value> _mapToFields(Map<String, dynamic> data) {
    return data.map((key, value) {
      return MapEntry(key, _toValue(value));
    });
  }

  Value _toValue(dynamic value) {
    if (value is String) return Value(stringValue: value);
    if (value is int) return Value(integerValue: value.toString());
    if (value is double) return Value(doubleValue: value);
    if (value is bool) return Value(booleanValue: value);
    if (value is DateTime) return Value(timestampValue: value.toUtc().toIso8601String());
    if (value is Map<String, dynamic>) return Value(mapValue: MapValue(fields: _mapToFields(value)));
    if (value is List) return Value(arrayValue: ArrayValue(values: value.map((e) => _toValue(e)).toList()));
    return Value(nullValue: 'NULL_VALUE');
  }
}
