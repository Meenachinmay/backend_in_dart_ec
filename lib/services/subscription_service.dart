import '../data/repositories/subscription_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/inventory_repository.dart';
import '../domain/models/subscription.dart';

class SubscriptionService {
  final SubscriptionRepository _subRepo;
  final UserRepository _userRepo;
  final InventoryRepository _inventoryRepo;

  SubscriptionService(this._subRepo, this._userRepo, this._inventoryRepo);

  Future<Subscription> subscribeUser({
    required String userId,
    required String inventoryId,
    required int alertThreshold,
  }) async {
    // 1. Validate User
    final user = await _userRepo.getUserById(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    // 2. Validate Inventory
    final inventory = await _inventoryRepo.getInventoryById(inventoryId);
    if (inventory == null) {
      throw Exception('Inventory item not found');
    }

    // 3. Create Subscription
    return _subRepo.createSubscription(userId, inventoryId, alertThreshold);
  }

  Future<List<Subscription>> getUserSubscriptions(String userId) {
    return _subRepo.getSubscriptionsByUser(userId);
  }

  Future<List<Map<String, dynamic>>> checkAndNotify() async {
    // 1. Find subscriptions where expiry == threshold
    final due = await _subRepo.getDueSubscriptions();
    
    // 2. In a real app, we would queue emails/push notifications here.
    // For this prototype, we return the list of notifications that *would* be sent.
    return due;
  }
}
