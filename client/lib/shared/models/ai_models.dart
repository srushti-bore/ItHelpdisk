class CommunicationDraftModel {
  final String id;
  final String caseId;
  final String draftType;
  final String body;
  final String status;
  final String? reviewedBy;
  final String? sentMessageId;
  final DateTime createdAt;

  CommunicationDraftModel({
    required this.id,
    required this.caseId,
    required this.draftType,
    required this.body,
    required this.status,
    this.reviewedBy,
    this.sentMessageId,
    required this.createdAt,
  });

  factory CommunicationDraftModel.fromJson(Map<String, dynamic> json) {
    return CommunicationDraftModel(
      id: json['id'] ?? '',
      caseId: json['case_id'] ?? '',
      draftType: json['draft_type'] ?? 'progress_update',
      body: json['body'] ?? '',
      status: json['status'] ?? 'draft',
      reviewedBy: json['reviewed_by'],
      sentMessageId: json['sent_message_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class CandidateOperatorModel {
  final String userId;
  final String fullName;
  final String email;
  final String? site;
  final String availabilityStatus;
  final int activeCaseCount;
  final double matchScore;
  final List<String> reasons;

  CandidateOperatorModel({
    required this.userId,
    required this.fullName,
    required this.email,
    this.site,
    required this.availabilityStatus,
    required this.activeCaseCount,
    required this.matchScore,
    required this.reasons,
  });

  factory CandidateOperatorModel.fromJson(Map<String, dynamic> json) {
    return CandidateOperatorModel(
      userId: json['user_id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      site: json['site'],
      availabilityStatus: json['availability_status'] ?? 'available',
      activeCaseCount: json['active_case_count'] ?? 0,
      matchScore: (json['match_score'] as num?)?.toDouble() ?? 0.0,
      reasons: List<String>.from(json['reasons'] ?? []),
    );
  }
}
