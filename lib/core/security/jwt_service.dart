import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtService {
  /// Generates a signed Apple App Store Connect JWT using ES256 algorithm.
  ///
  /// [issuerId] is the Apple Issuer ID.
  /// [keyId] is the Apple Key ID.
  /// [privateKey] is the contents of the downloaded .p8 private key file.
  String generateAppStoreConnectJwt({
    required String issuerId,
    required String keyId,
    required String privateKey,
  }) {
    final normalizedKey = _normalizePrivateKey(privateKey);
    final ecPrivateKey = ECPrivateKey(normalizedKey);

    final currentEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final exp = currentEpoch + 1200; // 20 minutes from now

    final jwt = JWT(
      {
        'iss': issuerId,
        'iat': currentEpoch,
        'exp': exp,
        'aud': 'appstoreconnect-v1',
      },
      header: {
        'kid': keyId,
        'typ': 'JWT',
      },
    );

    return jwt.sign(
      ecPrivateKey,
      algorithm: JWTAlgorithm.ES256,
    );
  }

  /// Normalizes the private key to ensure it starts with standard PEM headers.
  String _normalizePrivateKey(String key) {
    var cleaned = key.trim().replaceAll('\r', '');
    
    // Check if the string contains a standard BEGIN and END block
    final pemRegExp = RegExp(
      r'(-----BEGIN\s+PRIVATE\s+KEY-----[\s\S]*?-----END\s+PRIVATE\s+KEY-----)',
      caseSensitive: false,
    );
    
    final match = pemRegExp.firstMatch(cleaned);
    if (match != null) {
      return match.group(0)!.trim();
    }

    // If not found, fall back to wrapping the base64 content
    final base64Content = cleaned.replaceAll(RegExp(r'\s+'), '');
    final chunks = <String>[];
    for (var i = 0; i < base64Content.length; i += 64) {
      final end = (i + 64 < base64Content.length)
          ? i + 64
          : base64Content.length;
      chunks.add(base64Content.substring(i, end));
    }

    return '-----BEGIN PRIVATE KEY-----\n${chunks.join('\n')}\n-----END PRIVATE KEY-----';
  }
}
