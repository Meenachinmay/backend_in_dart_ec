import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../services/subscription_service.dart';

class SubscriptionHandler {
  final SubscriptionService _service;

  SubscriptionHandler(this._service);

  Router get router {
    final router = Router();
    router.post('/', _createSubscription);
    router.post('/trigger-check', _triggerCheck);
    router.get('/user/<userId>', _getUserSubscriptions);
    return router;
  }

  Future<Response> _triggerCheck(Request request) async {
    try {
      final notifications = await _service.checkAndNotify();
      return Response.ok(
        jsonEncode({
          'message': 'Notifications processed',
          'sent_to': notifications
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _createSubscription(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);

      final userId = data['user_id'];
      final inventoryId = data['inventory_id'];
      final alertThreshold = data['alert_threshold'];

      if (userId == null || inventoryId == null || alertThreshold == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Missing fields'}));
      }

      final sub = await _service.subscribeUser(
        userId: userId,
        inventoryId: inventoryId,
        alertThreshold: alertThreshold is int ? alertThreshold : int.parse(alertThreshold.toString()),
      );

      return Response.ok(jsonEncode(sub.toJson()), headers: {'content-type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _getUserSubscriptions(Request request, String userId) async {
    try {
      final subs = await _service.getUserSubscriptions(userId);
      return Response.ok(
        jsonEncode(subs.map((e) => e.toJson()).toList()),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }
}
