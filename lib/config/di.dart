import 'package:get_it/get_it.dart';
import 'package:dotenv/dotenv.dart';
import 'dart:io';
import '../data/db_connection.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/inventory_repository.dart';
import '../data/repositories/subscription_repository.dart';
import '../services/inventory_service.dart';
import '../services/subscription_service.dart';
import '../services/firebase_service.dart';
import '../api/handlers/user_handler.dart';
import '../api/handlers/inventory_handler.dart';
import '../api/handlers/subscription_handler.dart';
import '../api/api_router.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  // Load env
  var env = DotEnv(includePlatformEnvironment: true);
  if (File('.env').existsSync()) {
    env.load();
  }

  // Firebase
  final firebaseService = FirebaseService('service_account.json');
  // We initialize asynchronously. Ideally we should await it, but if file is missing
  // we might want to fail or warn. For this requirement, we'll await.
  try {
    if (File('service_account.json').existsSync()) {
      await firebaseService.initialize();
      print('Firebase initialized successfully');
    } else {
      print('WARNING: service_account.json not found. Firebase features will fail.');
    }
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }
  getIt.registerSingleton<FirebaseService>(firebaseService);

  // DB Connection
  final dbHost = env['DB_HOST'] ?? 'localhost';
  final dbPort = int.parse(env['DB_PORT'] ?? '5432');
  final dbName = env['DB_NAME'] ?? 'supermarket';
  final dbUser = env['DB_USER'] ?? 'user';
  final dbPassword = env['DB_PASSWORD'] ?? 'password';

  final dbConnection = await DbConnection.connect(
    host: dbHost,
    port: dbPort,
    database: dbName,
    user: dbUser,
    password: dbPassword,
  );

  getIt.registerSingleton<DbConnection>(dbConnection);

  // Repositories
  getIt.registerLazySingleton(() => UserRepository(getIt<DbConnection>()));
  getIt.registerLazySingleton(() => InventoryRepository(getIt<DbConnection>()));
  getIt.registerLazySingleton(() => SubscriptionRepository(getIt<DbConnection>()));

  // Services
  getIt.registerLazySingleton(() => InventoryService(getIt<InventoryRepository>()));
  getIt.registerLazySingleton(() => SubscriptionService(
    getIt<SubscriptionRepository>(),
    getIt<UserRepository>(),
    getIt<InventoryRepository>(),
    getIt<FirebaseService>(),
  ));

  // Handlers
  getIt.registerLazySingleton(() => UserHandler(getIt<UserRepository>()));
  getIt.registerLazySingleton(() => InventoryHandler(getIt<InventoryService>()));
  getIt.registerLazySingleton(() => SubscriptionHandler(getIt<SubscriptionService>()));

  // Router
  getIt.registerLazySingleton(() => ApiRouter(
    userHandler: getIt<UserHandler>(),
    inventoryHandler: getIt<InventoryHandler>(),
    subscriptionHandler: getIt<SubscriptionHandler>(),
    firebaseService: getIt<FirebaseService>(),
  ));
}
