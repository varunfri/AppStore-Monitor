import 'package:dio/dio.dart';
import '../security/secure_storage.dart';
import '../security/jwt_service.dart';
import '../error/error_logger.dart';

class JwtInterceptor extends Interceptor {
  final SecureStorageService _storageService;
  final JwtService _jwtService;
  final ErrorLogger _errorLogger;

  JwtInterceptor({
    required SecureStorageService storageService,
    required JwtService jwtService,
    required ErrorLogger errorLogger,
  }) : _storageService = storageService,
       _jwtService = jwtService,
       _errorLogger = errorLogger;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final issuerId = await _storageService.getIssuerId();
      final keyId = await _storageService.getKeyId();
      final privateKey = await _storageService.getPrivateKey();

      if (issuerId != null && keyId != null && privateKey != null) {
        final token = _jwtService.generateAppStoreConnectJwt(
          issuerId: issuerId,
          keyId: keyId,
          privateKey: privateKey,
        );
        options.headers['Authorization'] = 'Bearer $token';
        // Cache the token in extra info for logging purposes if request fails
        options.extra['jwt_token'] = token;
      }
    } catch (e) {
      // If JWT generation fails (e.g., bad private key formatting), log it
      _errorLogger.logError(
        method: options.method,
        url: options.uri.toString(),
        message: 'Local JWT signing failed: $e',
      );
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    final jwtUsed = err.requestOptions.extra['jwt_token'] as String?;

    String message = err.message ?? 'Unknown network error';
    String? responseBody;

    if (response != null) {
      responseBody = response.data?.toString();
      if (response.statusCode == 401) {
        message =
            '401 Unauthorized: Check if your Issuer ID, Key ID, and Private Key are correct and match your App Store Connect developer portal.';
      } else if (response.statusCode == 403) {
        message =
            '403 Forbidden: Ensure your Private Key has the necessary permissions (e.g., Developer, Admin) to access this endpoint.';
      }
    }

    _errorLogger.logError(
      method: err.requestOptions.method,
      url: err.requestOptions.uri.toString(),
      statusCode: response?.statusCode,
      message: message,
      responseBody: responseBody,
      jwtUsed: jwtUsed,
    );

    super.onError(err, handler);
  }
}
