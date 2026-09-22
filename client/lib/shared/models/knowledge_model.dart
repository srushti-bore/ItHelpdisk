class KnowledgeModel {
  final String id;
  final String title;
  final String body;
  final String category;
  final String? authorId;
  final String state;
  final DateTime? reviewDate;
  final String? sourceCaseId;
  final DateTime createdAt;
  final DateTime updatedAt;

  KnowledgeModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.authorId,
    required this.state,
    this.reviewDate,
    this.sourceCaseId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KnowledgeModel.fromJson(Map<String, dynamic> json) {
    return KnowledgeModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      category: json['category'] ?? 'General',
      authorId: json['author_id'],
      state: json['state'] ?? 'draft',
      reviewDate: json['review_date'] != null ? DateTime.parse(json['review_date']) : null,
      sourceCaseId: json['source_case_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
