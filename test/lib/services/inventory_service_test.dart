import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:supermarket_backend/services/inventory_service.dart';
import 'package:supermarket_backend/data/repositories/inventory_repository.dart';
import 'package:supermarket_backend/domain/models/inventory.dart';

class MockInventoryRepository extends Mock implements InventoryRepository {}

void main() {
  late InventoryService service;
  late MockInventoryRepository mockRepo;

  setUp(() {
    mockRepo = MockInventoryRepository();
    service = InventoryService(mockRepo);
  });

  Inventory createItem({required int expiryIn, double price = 100.0}) {
    return Inventory(
      id: 'item1',
      name: 'Milk',
      price: price,
      expiryIn: expiryIn,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  group('InventoryService', () {
    test('Applies 50% discount for 1 day expiry', () async {
      when(() => mockRepo.getAllInventory()).thenAnswer((_) async => [
        createItem(expiryIn: 1, price: 100.0)
      ]);

      final items = await service.getInventoryWithDiscounts();
      expect(items.first.discountedPrice, 50.0);
    });

    test('Applies 30% discount for 2 days expiry', () async {
      when(() => mockRepo.getAllInventory()).thenAnswer((_) async => [
        createItem(expiryIn: 2, price: 100.0)
      ]);

      final items = await service.getInventoryWithDiscounts();
      expect(items.first.discountedPrice, 70.0);
    });

    test('Applies 10% discount for 3 days expiry', () async {
      when(() => mockRepo.getAllInventory()).thenAnswer((_) async => [
        createItem(expiryIn: 3, price: 100.0)
      ]);

      final items = await service.getInventoryWithDiscounts();
      expect(items.first.discountedPrice, 90.0);
    });

    test('Applies no discount for >3 days expiry', () async {
      when(() => mockRepo.getAllInventory()).thenAnswer((_) async => [
        createItem(expiryIn: 4, price: 100.0)
      ]);

      final items = await service.getInventoryWithDiscounts();
      // Service implementation sets discountedPrice to original price if no discount
      expect(items.first.discountedPrice, 100.0); 
    });

    test('getInventoryById applies discount logic', () async {
       when(() => mockRepo.getInventoryById('item1')).thenAnswer((_) async => 
        createItem(expiryIn: 1, price: 100.0)
      );

      final item = await service.getInventoryById('item1');
      expect(item?.discountedPrice, 50.0);
    });

    test('getInventoryById returns null if not found', () async {
       when(() => mockRepo.getInventoryById('unknown')).thenAnswer((_) async => null);

      final item = await service.getInventoryById('unknown');
      expect(item, isNull);
    });
  });
}
