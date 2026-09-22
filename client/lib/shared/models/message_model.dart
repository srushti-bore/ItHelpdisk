import 'package:it_helpdesk_client/shared/models/user_model.dart';

class MessageModel {
  final String id;
  final String caseId;
  final String? authorId;
  final String body;
  final String visibility; // requester_visible, internal_only
  final bool aiGenerated;
  final DateTime createdAt;
  final UserModel? author;

  MessageModel({
    required this.id,
    required this.caseId,
    this.authorId,
    required this.body,
    required this.visibility,
    required this.aiGenerated,
    required this.createdAt,
    this.author,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      caseId: json['case_id'] ?? '',
      authorId: json['author_id'],
      body: json['body'] ?? '',
      visibility: json['visibility'] ?? 'requester_visible',
      aiGenerated: json['ai_generated'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      author: json['author'] != null ? UserModel.fromJson(json['author']) : null,
    );
  }
}
