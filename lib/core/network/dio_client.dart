import 'package:dio/dio.dart';
import 'jwt_interceptor.dart';

class DioClient {
  final Dio _dio;

  DioClient({required JwtInterceptor jwtInterceptor})
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://api.appstoreconnect.apple.com',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        )..interceptors.addAll([
            jwtInterceptor,
            // We can also add LogInterceptor for console logging
            LogInterceptor(
              requestHeader: false,
              responseHeader: false,
              requestBody: true,
              responseBody: true,
            ),
          ]);

  Dio get dio => _dio;
}
