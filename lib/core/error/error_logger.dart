import 'package:flutter/foundation.dart';

class NetworkLog {
  final DateTime timestamp;
  final String method;
  final String url;
  final int? statusCode;
  final String message;
  final String? responseBody;
  final String? jwtUsed;

  NetworkLog({
    required this.timestamp,
    required this.method,
    required this.url,
    this.statusCode,
    required this.message,
    this.responseBody,
    this.jwtUsed,
  });

  bool get isAuthError => statusCode == 401 || statusCode == 403;
}

class ErrorLogger extends ChangeNotifier {
  final List<NetworkLog> _logs = [];

  List<NetworkLog> get logs => List.unmodifiable(_logs);

  void logError({
    required String method,
    required String url,
    int? statusCode,
    required String message,
    String? responseBody,
    String? jwtUsed,
  }) {
    final log = NetworkLog(
      timestamp: DateTime.now(),
      method: method,
      url: url,
      statusCode: statusCode,
      message: message,
      responseBody: responseBody,
      jwtUsed: jwtUsed,
    );
    
    // Keep a maximum of 50 logs to prevent memory bloat
    if (_logs.length >= 50) {
      _logs.removeAt(0);
    }
    
    _logs.add(log);
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }
}
