import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
        );

  static const _keyIssuerId = 'asc_issuer_id';
  static const _keyKeyId = 'asc_key_id';
  static const _keyPrivateKey = 'asc_private_key';

  Future<void> saveCredentials({
    required String issuerId,
    required String keyId,
    required String privateKey,
  }) async {
    await _storage.write(key: _keyIssuerId, value: issuerId.trim());
    await _storage.write(key: _keyKeyId, value: keyId.trim());
    await _storage.write(key: _keyPrivateKey, value: privateKey.trim());
  }

  Future<String?> getIssuerId() async {
    return await _storage.read(key: _keyIssuerId);
  }

  Future<String?> getKeyId() async {
    return await _storage.read(key: _keyKeyId);
  }

  Future<String?> getPrivateKey() async {
    return await _storage.read(key: _keyPrivateKey);
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: _keyIssuerId);
    await _storage.delete(key: _keyKeyId);
    await _storage.delete(key: _keyPrivateKey);
  }

  Future<bool> hasCredentials() async {
    final issuerId = await getIssuerId();
    final keyId = await getKeyId();
    final privateKey = await getPrivateKey();
    return issuerId != null && keyId != null && privateKey != null;
  }
}
