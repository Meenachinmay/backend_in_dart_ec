import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../services/inventory_service.dart';

class InventoryHandler {
  final InventoryService _service;

  InventoryHandler(this._service);

  Router get router {
    final router = Router();
    router.get('/', _getAll);
    router.get('/<id>', _getOne);
    return router;
  }

  Future<Response> _getAll(Request request) async {
    try {
      final items = await _service.getInventoryWithDiscounts();
      return Response.ok(
        jsonEncode(items.map((e) => e.toJson()).toList()),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _getOne(Request request, String id) async {
    try {
      final item = await _service.getInventoryById(id);
      if (item == null) {
        return Response.notFound(jsonEncode({'error': 'Inventory not found'}));
      }
      return Response.ok(jsonEncode(item.toJson()), headers: {'content-type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }
}
