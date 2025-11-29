import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'handlers/user_handler.dart';
import 'handlers/inventory_handler.dart';
import 'handlers/subscription_handler.dart';
import 'middleware/auth_middleware.dart';

class ApiRouter {
  final UserHandler userHandler;
  final InventoryHandler inventoryHandler;
  final SubscriptionHandler subscriptionHandler;

  ApiRouter({
    required this.userHandler,
    required this.inventoryHandler,
    required this.subscriptionHandler,
  });

  Handler get handler {
    final router = Router();

    router.get('/health', (Request request) => Response.ok('OK'));

    router.mount('/api/v1/users/', userHandler.router.call);
    router.mount('/api/v1/inventory/', inventoryHandler.router.call);
    router.mount('/api/v1/subscriptions/', subscriptionHandler.router.call);

    final pipeline = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(firebaseAuthMiddleware());

    return pipeline.addHandler(router.call);
  }
}
