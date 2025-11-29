import 'dart:io';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:logging/logging.dart';
import '../lib/config/di.dart';
import '../lib/api/api_router.dart';

void main(List<String> args) async {
  // Setup logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  final log = Logger('Server');

  try {
    await setupDI();
    log.info('Dependency Injection setup complete.');

    final apiRouter = getIt<ApiRouter>();
    final handler = apiRouter.handler;

    final port = int.parse(Platform.environment['PORT'] ?? '8080');
    final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);

    log.info('Serving at http://${server.address.host}:${server.port}');
  } catch (e, stack) {
    log.severe('Failed to start server', e, stack);
    exit(1);
  }
}
