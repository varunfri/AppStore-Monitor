class CustomerReviewModel {
  final String id;
  final int rating;
  final String title;
  final String body;
  final String reviewerNickname;
  final DateTime? createdDate;
  final String territory;

  CustomerReviewModel({
    required this.id,
    required this.rating,
    required this.title,
    required this.body,
    required this.reviewerNickname,
    this.createdDate,
    required this.territory,
  });

  factory CustomerReviewModel.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};
    final dateStr = attributes['createdDate'] as String?;
    return CustomerReviewModel(
      id: json['id'] as String? ?? '',
      rating: attributes['rating'] as int? ?? 0,
      title: attributes['title'] as String? ?? '',
      body: attributes['body'] as String? ?? '',
      reviewerNickname: attributes['reviewerNickname'] as String? ?? 'Anonymous',
      createdDate: dateStr != null ? DateTime.tryParse(dateStr) : null,
      territory: attributes['territory'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attributes': {
        'rating': rating,
        'title': title,
        'body': body,
        'reviewerNickname': reviewerNickname,
        'createdDate': createdDate?.toIso8601String(),
        'territory': territory,
      },
    };
  }
}
