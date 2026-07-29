class BuildModel {
  final String id;
  final String version; // This is the build number (e.g. 24)
  final String? appVersion; // This is the marketing version (e.g. 1.0.0)
  final String? iconUrl; // This is the build icon URL (formatted from template)
  final DateTime? uploadedDate;
  final String processingState;
  final bool expired;

  BuildModel({
    required this.id,
    required this.version,
    this.appVersion,
    this.iconUrl,
    this.uploadedDate,
    required this.processingState,
    required this.expired,
  });

  factory BuildModel.fromJson(Map<String, dynamic> json, {String? appVersion, String? iconUrl}) {
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};
    final dateStr = attributes['uploadedDate'] as String?;
    return BuildModel(
      id: json['id'] as String? ?? '',
      version: attributes['version'] as String? ?? 'N/A',
      appVersion: appVersion,
      iconUrl: iconUrl,
      uploadedDate: dateStr != null ? DateTime.tryParse(dateStr) : null,
      processingState: attributes['processingState'] as String? ?? 'UNKNOWN',
      expired: attributes['expired'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appVersion': appVersion,
      'iconUrl': iconUrl,
      'attributes': {
        'version': version,
        'uploadedDate': uploadedDate?.toIso8601String(),
        'processingState': processingState,
        'expired': expired,
      },
    };
  }

  /// Helper to get a human-readable and beautiful status text & color code.
  String get statusText {
    if (expired) return 'Expired';
    switch (processingState.toUpperCase()) {
      case 'PROCESSING':
        return 'Processing';
      case 'VALID':
        return 'Valid';
      case 'INVALID':
        return 'Invalid';
      default:
        return processingState;
    }
  }
}
