import 'dart:convert';
import 'package:mocktail/mocktail.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';
import 'package:supermarket_backend/api/handlers/user_handler.dart';
import 'package:supermarket_backend/data/repositories/user_repository.dart';
import 'package:supermarket_backend/domain/models/user.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late UserHandler handler;
  late MockUserRepository mockRepo;

  setUp(() {
    mockRepo = MockUserRepository();
    handler = UserHandler(mockRepo);
  });

  group('UserHandler', () {
    test('POST / creates user successfully', () async {
      final user = User(
        id: 'user1',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      when(() => mockRepo.createUser('user1', 'test@example.com'))
          .thenAnswer((_) async => user);

      final request = Request(
        'POST', 
        Uri.parse('http://localhost/'), 
        body: jsonEncode({'id': 'user1', 'email': 'test@example.com'})
      );
      
      final response = await handler.router.call(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString());
      expect(body['id'], 'user1');
      expect(body['email'], 'test@example.com');
    });

    test('POST / returns 400 if missing fields', () async {
      final request = Request(
        'POST', 
        Uri.parse('http://localhost/'), 
        body: jsonEncode({'id': 'user1'}) // Missing email
      );
      
      final response = await handler.router.call(request);

      expect(response.statusCode, 400);
    });

    test('GET /<id> returns user successfully', () async {
      final user = User(
        id: 'user1',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockRepo.getUserById('user1')).thenAnswer((_) async => user);

      final request = Request('GET', Uri.parse('http://localhost/user1'));
      final response = await handler.router.call(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString());
      expect(body['id'], 'user1');
    });

    test('POST /<id> returns 404 if user not found', () async {
      when(() => mockRepo.getUserById('unknown')).thenAnswer((_) async => null);

      final request = Request('GET', Uri.parse('http://localhost/unknown'));
      final response = await handler.router.call(request);

      expect(response.statusCode, 404);
    });

    test('POST / updates user if id already exists (Upsert)', () async {
      final updatedUser = User(
        id: 'user1',
        email: 'updated@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockRepo.createUser('user1', 'updated@example.com'))
          .thenAnswer((_) async => updatedUser);

      final request = Request(
        'POST', 
        Uri.parse('http://localhost/'), 
        body: jsonEncode({'id': 'user1', 'email': 'updated@example.com'})
      );
      
      final response = await handler.router.call(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString());
      expect(body['id'], 'user1');
      expect(body['email'], 'updated@example.com');
    });
  });
}
