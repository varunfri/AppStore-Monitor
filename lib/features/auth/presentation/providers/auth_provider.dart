import 'package:flutter/material.dart';
import '../../../../core/security/secure_storage.dart';
import '../../../dashboard/data/repositories/app_store_repository.dart';

class AuthProvider extends ChangeNotifier {
  final SecureStorageService _storageService;
  final AppStoreRepository _repository;

  AuthProvider({
    required SecureStorageService storageService,
    required AppStoreRepository repository,
  })  : _storageService = storageService,
        _repository = repository {
    loadCredentials();
  }

  String? _issuerId;
  String? _keyId;
  String? _privateKey;
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _errorMessage;

  String? get issuerId => _issuerId;
  String? get keyId => _keyId;
  String? get privateKey => _privateKey;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  /// Loads credentials from secure storage and updates the state.
  Future<void> loadCredentials() async {
    _isLoading = true;
    notifyListeners();

    try {
      _issuerId = await _storageService.getIssuerId();
      _keyId = await _storageService.getKeyId();
      _privateKey = await _storageService.getPrivateKey();
      _isAuthenticated = _issuerId != null && _keyId != null && _privateKey != null;
    } catch (e) {
      _errorMessage = 'Failed to load credentials: $e';
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verifies credentials by doing a dummy request (fetching apps) and saving them if successful.
  Future<bool> verifyAndSaveCredentials({
    required String issuerId,
    required String keyId,
    required String privateKey,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Temporarily save to secure storage to allow Dio client / JwtInterceptor to sign requests
      await _storageService.saveCredentials(
        issuerId: issuerId,
        keyId: keyId,
        privateKey: privateKey,
      );

      // Perform a test request to check if credentials actually work
      await _repository.fetchApps();

      // If it succeeds: update state
      _issuerId = issuerId;
      _keyId = keyId;
      _privateKey = privateKey;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Clean up temporary keys if validation failed so we don't save bad configuration
      await _storageService.clearCredentials();
      _issuerId = null;
      _keyId = null;
      _privateKey = null;
      _isAuthenticated = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clears credentials from secure storage and state.
  Future<void> clearCredentials() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.clearCredentials();
      _issuerId = null;
      _keyId = null;
      _privateKey = null;
      _isAuthenticated = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to clear credentials: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
