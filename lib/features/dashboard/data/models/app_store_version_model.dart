class AppStoreVersionModel {
  final String id;
  final String versionString;
  final String appStoreState;

  AppStoreVersionModel({
    required this.id,
    required this.versionString,
    required this.appStoreState,
  });

  factory AppStoreVersionModel.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};
    return AppStoreVersionModel(
      id: json['id'] as String? ?? '',
      versionString: attributes['versionString'] as String? ?? 'N/A',
      appStoreState: attributes['appStoreState'] as String? ?? 'UNKNOWN',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attributes': {
        'versionString': versionString,
        'appStoreState': appStoreState,
      },
    };
  }

  /// Helper to get a human-readable and beautiful status text.
  String get statusText {
    switch (appStoreState.toUpperCase()) {
      case 'PREPARE_FOR_SUBMISSION':
        return 'Prepare for Submission';
      case 'READY_FOR_REVIEW':
        return 'Ready for Review';
      case 'WAITING_FOR_REVIEW':
        return 'Waiting for Review';
      case 'IN_REVIEW':
        return 'In Review';
      case 'READY_FOR_SALE':
        return 'Ready for Sale';
      case 'REJECTED':
        return 'Rejected';
      case 'METADATA_REJECTED':
        return 'Metadata Rejected';
      case 'DEVELOPER_REJECTED':
        return 'Developer Rejected';
      case 'PENDING_APPLE_RELEASE':
        return 'Pending Apple Release';
      case 'PENDING_DEVELOPER_RELEASE':
        return 'Pending Developer Release';
      default:
        return appStoreState
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
            .join(' ');
    }
  }
}
