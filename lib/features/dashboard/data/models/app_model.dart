class AppModel {
  final String id;
  final String name;
  final String bundleId;
  final String sku;
  String? iconUrl; // URL from public iTunes lookup API

  AppModel({
    required this.id,
    required this.name,
    required this.bundleId,
    required this.sku,
    this.iconUrl,
  });

  factory AppModel.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};
    return AppModel(
      id: json['id'] as String? ?? '',
      name: attributes['name'] as String? ?? 'Unknown App',
      bundleId: attributes['bundleId'] as String? ?? 'N/A',
      sku: attributes['sku'] as String? ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'iconUrl': iconUrl,
      'attributes': {'name': name, 'bundleId': bundleId, 'sku': sku},
    };
  }
}
