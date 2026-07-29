class PreReleaseModel {
  final String id;
  final String version;
  final String platform;
  final String? uploadDate;

  PreReleaseModel({
    required this.id,
    required this.version,
    required this.platform,
    this.uploadDate,
  });

  factory PreReleaseModel.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};
    return PreReleaseModel(
      id: json['id'] as String? ?? '',
      version: attributes['version'] as String? ?? 'N/A',
      platform: attributes['platform'] as String? ?? 'IOS',
      uploadDate: attributes['uploadedDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attributes': {
        'version': version,
        'platform': platform,
        'uploadedDate': uploadDate,
      },
    };
  }
}
