import 'dart:convert';
import 'package:mocktail/mocktail.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';
import 'package:supermarket_backend/api/handlers/inventory_handler.dart';
import 'package:supermarket_backend/services/inventory_service.dart';
import 'package:supermarket_backend/domain/models/inventory.dart';

class MockInventoryService extends Mock implements InventoryService {}

void main() {
  late InventoryHandler handler;
  late MockInventoryService mockService;

  setUp(() {
    mockService = MockInventoryService();
    handler = InventoryHandler(mockService);
  });

  final sampleItem = Inventory(
    id: '1', 
    name: 'Item', 
    price: 10.0, 
    expiryIn: 5, 
    createdAt: DateTime.now(), 
    updatedAt: DateTime.now()
  );

  group('InventoryHandler', () {
    test('GET / returns list of inventory', () async {
      when(() => mockService.getInventoryWithDiscounts()).thenAnswer((_) async => [sampleItem]);

      final request = Request('GET', Uri.parse('http://localhost/'));
      final response = await handler.router.call(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString()) as List;
      expect(body.length, 1);
      expect(body[0]['id'], '1');
    });

    test('GET /<id> returns item', () async {
      when(() => mockService.getInventoryById('1')).thenAnswer((_) async => sampleItem);

      final request = Request('GET', Uri.parse('http://localhost/1'));
      final response = await handler.router.call(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString());
      expect(body['id'], '1');
    });

    test('GET /<id> returns 404 if not found', () async {
      when(() => mockService.getInventoryById('999')).thenAnswer((_) async => null);

      final request = Request('GET', Uri.parse('http://localhost/999'));
      final response = await handler.router.call(request);

      expect(response.statusCode, 404);
    });
  });
}
