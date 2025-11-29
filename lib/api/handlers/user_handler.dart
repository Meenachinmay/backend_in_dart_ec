import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../data/repositories/user_repository.dart';

class UserHandler {
  final UserRepository _repo;

  UserHandler(this._repo);

  Router get router {
    final router = Router();
    router.post('/', _createUser);
    router.get('/<id>', _getUser);
    return router;
  }

  Future<Response> _createUser(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);
      final email = data['email'];

      if (email == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Email is required'}));
      }

      final user = await _repo.createUser(email);
      return Response.ok(jsonEncode(user.toJson()), headers: {'content-type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> _getUser(Request request, String id) async {
    try {
      final user = await _repo.getUserById(id);
      if (user == null) {
        return Response.notFound(jsonEncode({'error': 'User not found'}));
      }
      return Response.ok(jsonEncode(user.toJson()), headers: {'content-type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }
}
