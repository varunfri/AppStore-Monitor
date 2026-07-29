import 'package:flutter/material.dart';
import '../../data/models/app_model.dart';
import '../../data/models/build_model.dart';
import '../../data/models/prerelease_model.dart';
import '../../data/models/customer_review_model.dart';
import '../../data/models/app_store_version_model.dart';
import '../../data/repositories/app_store_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final AppStoreRepository _repository;

  DashboardProvider({required AppStoreRepository repository})
    : _repository = repository;

  List<AppModel> _apps = [];
  bool _isLoadingApps = false;
  String? _appsError;

  final Map<String, List<BuildModel>> _appBuilds = {};
  final Map<String, List<PreReleaseModel>> _appPreReleases = {};
  final Map<String, List<CustomerReviewModel>> _appReviews = {};
  final Map<String, List<AppStoreVersionModel>> _appStoreVersions = {};
  final Map<String, bool> _isLoadingDetails = {};
  final Map<String, String?> _detailsError = {};

  List<AppModel> get apps => _apps;
  bool get isLoadingApps => _isLoadingApps;
  String? get appsError => _appsError;

  List<BuildModel>? getBuilds(String appId) => _appBuilds[appId];
  List<PreReleaseModel>? getPreReleases(String appId) => _appPreReleases[appId];
  List<CustomerReviewModel>? getReviews(String appId) => _appReviews[appId];
  List<AppStoreVersionModel>? getAppStoreVersions(String appId) =>
      _appStoreVersions[appId];
  bool isLoadingDetails(String appId) => _isLoadingDetails[appId] ?? false;
  String? getDetailsError(String appId) => _detailsError[appId];

  /// Loads the list of apps from App Store Connect.
  Future<void> loadApps() async {
    _isLoadingApps = true;
    _appsError = null;
    notifyListeners();

    try {
      _apps = await _repository.fetchApps();
      notifyListeners();

      // Load app icons and store versions in the background
      _loadAppIconsAndVersions();
    } catch (e) {
      _appsError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingApps = false;
      notifyListeners();
    }
  }

  Future<void> _loadAppIconsAndVersions() async {
    for (var i = 0; i < _apps.length; i++) {
      final app = _apps[i];
      try {
        // 1. Try public iTunes Search API first
        var iconUrl = await _repository.fetchAppIconUrl(app.id);

        // 2. Fetch builds for the app (pre-caches builds for app details)
        final builds = await _repository.fetchBuilds(app.id);
        if (builds.isNotEmpty) {
          _appBuilds[app.id] = builds;

          // If public API returned null (pre-release app), extract the build icon
          if (iconUrl == null) {
            for (var build in builds) {
              if (build.iconUrl != null) {
                iconUrl = build.iconUrl;
                break;
              }
            }
          }
        }

        if (iconUrl != null) {
          app.iconUrl = iconUrl;
        }

        // 3. Load App Store Version Status
        final versions = await _repository.fetchAppStoreVersions(app.id);
        if (versions.isNotEmpty) {
          _appStoreVersions[app.id] = versions;
        }

        notifyListeners();
      } catch (_) {
        // Silently fail
      }
    }
  }

  /// Loads builds, pre-releases, customer reviews, and app store versions for a specific app ID in parallel.
  Future<void> loadAppDetails(String appId) async {
    _isLoadingDetails[appId] = true;
    _detailsError[appId] = null;
    notifyListeners();

    try {
      final results = await (
        _repository.fetchBuilds(appId),
        _repository.fetchPreReleaseVersions(appId),
        _repository.fetchCustomerReviews(appId),
        _repository.fetchAppStoreVersions(appId),
      ).wait;

      _appBuilds[appId] = results.$1;
      _appPreReleases[appId] = results.$2;
      _appReviews[appId] = results.$3;
      _appStoreVersions[appId] = results.$4;
    } catch (e) {
      _detailsError[appId] = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingDetails[appId] = false;
      notifyListeners();
    }
  }
}
