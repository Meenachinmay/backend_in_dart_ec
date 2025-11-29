import 'package:shelf/shelf.dart';
import '../../services/firebase_service.dart';

Middleware firebaseAuthMiddleware(FirebaseService firebaseService) {
  return (Handler innerHandler) {
    return (Request request) async {
      // Bypass token verification for now as requested.
      // All requests will pass through to the inner handler.
      print('Authentication bypassed for request to: ${request.url}');
      return innerHandler(request);
    };
  };
}
