import 'dart:convert';
import 'package:mocktail/mocktail.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';
import 'package:supermarket_backend/api/handlers/subscription_handler.dart';
import 'package:supermarket_backend/services/subscription_service.dart';
import 'package:supermarket_backend/domain/models/subscription.dart';

class MockSubscriptionService extends Mock implements SubscriptionService {}

void main() {
  late SubscriptionHandler handler;
  late MockSubscriptionService mockService;

  setUp(() {
    mockService = MockSubscriptionService();
    handler = SubscriptionHandler(mockService);
  });

  final sub = Subscription(
    id: 's1', userId: 'u1', inventoryId: 'i1', alertThreshold: 1, createdAt: DateTime.now()
  );

  group('SubscriptionHandler', () {
    test('POST / creates subscription', () async {
      when(() => mockService.subscribeUser(
        userId: any(named: 'userId'),
        inventoryId: any(named: 'inventoryId'),
        alertThreshold: any(named: 'alertThreshold')
      )).thenAnswer((_) async => sub);

      final request = Request(
        'POST', 
        Uri.parse('http://localhost/'),
        body: jsonEncode({'user_id': 'u1', 'inventory_id': 'i1', 'alert_threshold': 1})
      );
      final response = await handler.router.call(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString());
      expect(body['id'], 's1');
    });

    test('POST / returns 400 on missing fields', () async {
      final request = Request(
        'POST', 
        Uri.parse('http://localhost/'),
        body: jsonEncode({'user_id': 'u1'})
      );
      final response = await handler.router.call(request);

      expect(response.statusCode, 400);
    });

    test('POST /trigger-check triggers notifications', () async {
      when(() => mockService.checkAndNotify()).thenAnswer((_) async => []);

      final request = Request('POST', Uri.parse('http://localhost/trigger-check'));
      final response = await handler.router.call(request);

      expect(response.statusCode, 200);
    });
  });
}
