import '../data/repositories/inventory_repository.dart';
import '../domain/models/inventory.dart';

class InventoryService {
  final InventoryRepository _repo;

  InventoryService(this._repo);

  Future<List<Inventory>> getInventoryWithDiscounts() async {
    final inventoryList = await _repo.getAllInventory();

    return inventoryList.map((item) => _applyDiscount(item)).toList();
  }

  Future<Inventory?> getInventoryById(String id) async {
    final item = await _repo.getInventoryById(id);
    if (item == null) return null;
    return _applyDiscount(item);
  }

  Inventory _applyDiscount(Inventory item) {
    double discountPercentage = 0.0;

    if (item.expiryIn == 1) {
      discountPercentage = 0.50;
    } else if (item.expiryIn == 2) {
      discountPercentage = 0.30;
    } else if (item.expiryIn == 3) {
      discountPercentage = 0.10;
    }

    if (discountPercentage > 0) {
      final discounted = item.price * (1 - discountPercentage);
      // Round to 2 decimal places
      final roundedDiscounted = double.parse(discounted.toStringAsFixed(2));
      return item.copyWith(discountedPrice: roundedDiscounted);
    }

    // No discount, ensure discountedPrice is null or same as price? 
    // Plan says: "Else -> 0% OFF (Original Price)".
    // Usually discounted_price is null if no discount, or equal to price.
    // I'll leave it as null in copyWith if not set, but here I'll explicitly set it to price if we want consistency,
    // OR just leave it null to indicate "no special price". 
    // Let's stick to null implies no discount for now, or set it to price.
    // The user said: "discounted_price column... you handle that".
    // Let's set it to the original price if no discount, so the frontend always has a 'current valid price'.
    return item.copyWith(discountedPrice: item.price);
  }
}
