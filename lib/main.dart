import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

// Services & Core
import 'core/error/error_logger.dart';
import 'core/network/dio_client.dart';
import 'core/network/jwt_interceptor.dart';
import 'core/security/jwt_service.dart';
import 'core/security/secure_storage.dart';
import 'core/theme/app_theme.dart';

// Repositories
import 'features/dashboard/data/repositories/app_store_repository.dart';

// Providers
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';

// Screens & Widgets
import 'features/auth/presentation/screens/auth_gate.dart';
import 'features/error_overlay/presentation/widgets/error_logger_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Initialize core services that do not depend on other providers
    final secureStorageService = SecureStorageService();
    final jwtService = JwtService();
    final errorLogger = ErrorLogger();

    // 2. Initialize network layers
    final jwtInterceptor = JwtInterceptor(
      storageService: secureStorageService,
      jwtService: jwtService,
      errorLogger: errorLogger,
    );

    final dioClient = DioClient(jwtInterceptor: jwtInterceptor);

    // 3. Initialize repositories
    final appStoreRepository = AppStoreRepository(dioClient: dioClient);

    return MultiProvider(
      providers: [
        // Provide error logger globally
        ChangeNotifierProvider<ErrorLogger>.value(value: errorLogger),

        // Provide repository layer (could be RepositoryProvider but ChangeNotifierProvider is fine or Provider)
        Provider<AppStoreRepository>.value(value: appStoreRepository),

        // Auth Provider
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            storageService: secureStorageService,
            repository: appStoreRepository,
          ),
        ),

        // Dashboard Provider
        ChangeNotifierProvider<DashboardProvider>(
          create: (context) =>
              DashboardProvider(repository: appStoreRepository),
        ),
      ],
      child: CupertinoApp(
        title: 'App Store Connect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.cupertinoTheme,
        builder: (context, child) {
          // Wrap the entire app view tree with our custom interactive error logger overlay
          return ErrorLoggerOverlay(child: child ?? const SizedBox.shrink());
        },
        home: const AuthGate(),
      ),
    );
  }
}
