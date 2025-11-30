import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:supermarket_backend/services/subscription_service.dart';
import 'package:supermarket_backend/data/repositories/subscription_repository.dart';
import 'package:supermarket_backend/data/repositories/user_repository.dart';
import 'package:supermarket_backend/data/repositories/inventory_repository.dart';
import 'package:supermarket_backend/services/firebase_service.dart';
import 'package:supermarket_backend/domain/models/user.dart';
import 'package:supermarket_backend/domain/models/inventory.dart';
import 'package:supermarket_backend/domain/models/subscription.dart';

class MockSubscriptionRepository extends Mock implements SubscriptionRepository {}
class MockUserRepository extends Mock implements UserRepository {}
class MockInventoryRepository extends Mock implements InventoryRepository {}
class MockFirebaseService extends Mock implements FirebaseService {}

void main() {
  late SubscriptionService service;
  late MockSubscriptionRepository mockSubRepo;
  late MockUserRepository mockUserRepo;
  late MockInventoryRepository mockInvRepo;
  late MockFirebaseService mockFirebase;

  setUp(() {
    mockSubRepo = MockSubscriptionRepository();
    mockUserRepo = MockUserRepository();
    mockInvRepo = MockInventoryRepository();
    mockFirebase = MockFirebaseService();
    service = SubscriptionService(mockSubRepo, mockUserRepo, mockInvRepo, mockFirebase);
  });

  final user = User(id: 'u1', email: 'e', createdAt: DateTime.now(), updatedAt: DateTime.now());
  final item = Inventory(id: 'i1', name: 'n', price: 1, expiryIn: 1, createdAt: DateTime.now(), updatedAt: DateTime.now());
  final sub = Subscription(id: 's1', userId: 'u1', inventoryId: 'i1', alertThreshold: 1, createdAt: DateTime.now());

  group('SubscriptionService', () {
    test('subscribeUser creates subscription if user and item exist', () async {
      when(() => mockUserRepo.getUserById('u1')).thenAnswer((_) async => user);
      when(() => mockInvRepo.getInventoryById('i1')).thenAnswer((_) async => item);
      when(() => mockSubRepo.createSubscription('u1', 'i1', 1)).thenAnswer((_) async => sub);

      final result = await service.subscribeUser(userId: 'u1', inventoryId: 'i1', alertThreshold: 1);
      expect(result.id, 's1');
      verify(() => mockSubRepo.createSubscription('u1', 'i1', 1)).called(1);
    });

    test('subscribeUser throws if user not found', () async {
      when(() => mockUserRepo.getUserById('u1')).thenAnswer((_) async => null);
      
      expect(
        () => service.subscribeUser(userId: 'u1', inventoryId: 'i1', alertThreshold: 1),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('User not found')))
      );
    });

    test('checkAndNotify sends notifications for due items', () async {
      final dueItem = {'email': 'e@e.com', 'item_name': 'Milk', 'days_left': 1};
      when(() => mockSubRepo.getDueSubscriptions()).thenAnswer((_) async => [dueItem]);
      when(() => mockFirebase.addNotification(any())).thenAnswer((_) async => Future.value());

      final result = await service.checkAndNotify();
      
      expect(result, hasLength(1));
      verify(() => mockFirebase.addNotification(any())).called(1);
    });
  });
}
