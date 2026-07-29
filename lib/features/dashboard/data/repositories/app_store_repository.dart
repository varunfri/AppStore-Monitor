import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/network/dio_client.dart';
import '../models/app_model.dart';
import '../models/build_model.dart';
import '../models/prerelease_model.dart';
import '../models/customer_review_model.dart';
import '../models/app_store_version_model.dart';

class AppStoreRepository {
  final DioClient _dioClient;

  AppStoreRepository({required DioClient dioClient}) : _dioClient = dioClient;

  /// Fetches all apps configured in the Apple Developer account.
  /// Endpoint: GET https://api.appstoreconnect.apple.com/v1/apps
  Future<List<AppModel>> fetchApps() async {
    try {
      final response = await _dioClient.dio.get('/v1/apps');
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((json) => AppModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      debugPrint("Error model parsing data from URL: $e");
    }
    return [];
  }

  /// Fetches builds for a specific app, including pre-release versions and build icons.
  /// Endpoint: GET https://api.appstoreconnect.apple.com/v1/builds?filter[app]={appId}&include=preReleaseVersion,icons
  Future<List<BuildModel>> fetchBuilds(String appId) async {
    try {
      final response = await _dioClient.dio.get(
        '/v1/builds',
        queryParameters: {
          'filter[app]': appId,
          'include': 'preReleaseVersion,icons',
        },
      );

      final included = response.data['included'] as List<dynamic>? ?? [];
      final preReleaseMap = <String, String>{};
      final iconsMap = <String, String>{};

      for (var item in included) {
        if (item['type'] == 'preReleaseVersions') {
          final id = item['id'] as String? ?? '';
          final version = item['attributes']?['version'] as String? ?? '';
          if (id.isNotEmpty && version.isNotEmpty) {
            preReleaseMap[id] = version;
          }
        } else if (item['type'] == 'buildIcons') {
          final id = item['id'] as String? ?? '';
          final iconAsset =
              item['attributes']?['iconAsset'] as Map<String, dynamic>?;
          if (id.isNotEmpty && iconAsset != null) {
            final templateUrl = iconAsset['templateUrl'] as String? ?? '';
            if (templateUrl.isNotEmpty) {
              final formattedUrl = templateUrl
                  .replaceAll('{w}', '120')
                  .replaceAll('{h}', '120')
                  .replaceAll('{f}', 'png')
                  .replaceAll('{c}', 'png');
              iconsMap[id] = formattedUrl;
            }
          }
        }
      }

      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((json) {
        final map = json as Map<String, dynamic>;
        final relId =
            map['relationships']?['preReleaseVersion']?['data']?['id']
                as String?;
        final appVersion = relId != null ? preReleaseMap[relId] : null;

        final iconsData =
            map['relationships']?['icons']?['data'] as List<dynamic>? ?? [];
        final iconId = iconsData.isNotEmpty
            ? iconsData.first['id'] as String?
            : null;
        final iconUrl = iconId != null ? iconsMap[iconId] : null;

        return BuildModel.fromJson(
          map,
          appVersion: appVersion,
          iconUrl: iconUrl,
        );
      }).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      debugPrint("Error model parsing data from URL: $e");
    }
    return [];
  }

  /// Fetches prerelease versions for a specific app.
  /// Endpoint: GET https://api.appstoreconnect.apple.com/v1/apps/{id}/preReleaseVersions
  Future<List<PreReleaseModel>> fetchPreReleaseVersions(String appId) async {
    try {
      final response = await _dioClient.dio.get(
        '/v1/apps/$appId/preReleaseVersions',
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((json) => PreReleaseModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      debugPrint("Error model parsing data from URL: $e");
    }
    return [];
  }

  /// Fetches customer reviews for a specific app.
  /// Endpoint: GET https://api.appstoreconnect.apple.com/v1/apps/{id}/customerReviews
  Future<List<CustomerReviewModel>> fetchCustomerReviews(String appId) async {
    try {
      final response = await _dioClient.dio.get(
        '/v1/apps/$appId/customerReviews',
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map(
            (json) =>
                CustomerReviewModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      debugPrint("Error model parsing data from URL: $e");
    }
    return [];
  }

  /// Fetches the app store versions for a specific app.
  /// Endpoint: GET https://api.appstoreconnect.apple.com/v1/apps/{id}/appStoreVersions
  Future<List<AppStoreVersionModel>> fetchAppStoreVersions(String appId) async {
    try {
      final response = await _dioClient.dio.get(
        '/v1/apps/$appId/appStoreVersions',
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map(
            (json) =>
                AppStoreVersionModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      debugPrint("Error fetching: $e");
      throw _handleDioError(e);
    } catch (e) {
      debugPrint("Error model parsing data from URL: $e");
    }
    return [];
  }

  /// Fetches the app icon URL using the public iTunes Search API.
  /// This request does not require JWT authorization, so we use a clean Dio client.
  Future<String?> fetchAppIconUrl(String appId) async {
    try {
      final dio = Dio(); // Clean client without interceptor
      final response = await dio.get(
        'https://itunes.apple.com/lookup?id=$appId',
      );
      final results = response.data['results'] as List<dynamic>? ?? [];
      if (results.isNotEmpty) {
        return results[0]['artworkUrl100'] as String? ??
            results[0]['artworkUrl512'] as String? ??
            results[0]['artworkUrl60'] as String?;
      }
    } catch (e) {
      // Silently fail if public API lookup fails (e.g. app not yet published to App Store)
      debugPrint("Error fetching app icon URL: $e");
    }
    return null;
  }

  Exception _handleDioError(DioException e) {
    // Let the JWT Interceptor log the detailed error status code and payload,
    // here we return a friendly display message or rethrow.
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) {
      return Exception(
        '401 Unauthorized: Invalid App Store Connect JWT credentials.',
      );
    } else if (statusCode == 403) {
      return Exception(
        '403 Forbidden: Missing permission or incorrect key configuration.',
      );
    }
    return Exception(
      e.message ??
          'A network error occurred while communicating with Apple servers.',
    );
  }
}
