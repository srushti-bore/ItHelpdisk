import 'package:it_helpdesk_client/shared/models/user_model.dart';

class SLAModel {
  final DateTime targetResponseAt;
  final DateTime targetResolveAt;
  final bool responseBreached;
  final bool resolveBreached;
  final DateTime? firstRespondedAt;
  final DateTime? resolvedAt;
  final String? pausedReason;

  SLAModel({
    required this.targetResponseAt,
    required this.targetResolveAt,
    required this.responseBreached,
    required this.resolveBreached,
    this.firstRespondedAt,
    this.resolvedAt,
    this.pausedReason,
  });

  factory SLAModel.fromJson(Map<String, dynamic> json) {
    return SLAModel(
      targetResponseAt: DateTime.parse(json['target_response_at']),
      targetResolveAt: DateTime.parse(json['target_resolve_at']),
      responseBreached: json['response_breached'] ?? false,
      resolveBreached: json['resolve_breached'] ?? false,
      firstRespondedAt: json['first_responded_at'] != null ? DateTime.parse(json['first_responded_at']) : null,
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at']) : null,
      pausedReason: json['paused_reason'],
    );
  }
}

class AITriageModel {
  final String suggestedCategory;
  final String suggestedSeverity;
  final String suggestedPriority;
  final String confidenceLevel;
  final List<String> supportingFactors;
  final List<String> missingInfo;
  final String? suggestedTeam;
  final String? recommendedNextAction;

  AITriageModel({
    required this.suggestedCategory,
    required this.suggestedSeverity,
    required this.suggestedPriority,
    required this.confidenceLevel,
    required this.supportingFactors,
    required this.missingInfo,
    this.suggestedTeam,
    this.recommendedNextAction,
  });

  factory AITriageModel.fromJson(Map<String, dynamic> json) {
    return AITriageModel(
      suggestedCategory: json['suggested_category'] ?? '',
      suggestedSeverity: json['suggested_severity'] ?? '',
      suggestedPriority: json['suggested_priority'] ?? '',
      confidenceLevel: json['confidence_level'] ?? 'Moderate',
      supportingFactors: List<String>.from(json['supporting_factors'] ?? []),
      missingInfo: List<String>.from(json['missing_info'] ?? []),
      suggestedTeam: json['suggested_team'],
      recommendedNextAction: json['recommended_next_action'],
    );
  }
}

class CaseModel {
  final String id;
  final String referenceNumber;
  final String type; // incident, service_request
  final String title;
  final String description;
  final String status;
  final String priority;
  final String requesterId;
  final String? ownerId;
  final String? teamId;
  final String? site;
  final String? serviceId;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;

  final UserModel? requester;
  final UserModel? owner;
  final SLAModel? sla;
  final AITriageModel? triageResult;
  final String? summaryText;
  final String? riskLevel;

  CaseModel({
    required this.id,
    required this.referenceNumber,
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.requesterId,
    this.ownerId,
    this.teamId,
    this.site,
    this.serviceId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.closedAt,
    this.requester,
    this.owner,
    this.sla,
    this.triageResult,
    this.summaryText,
    this.riskLevel,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['id'] ?? '',
      referenceNumber: json['reference_number'] ?? '',
      type: json['type'] ?? 'incident',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'new',
      priority: json['priority'] ?? 'P3',
      requesterId: json['requester_id'] ?? '',
      ownerId: json['owner_id'],
      teamId: json['team_id'],
      site: json['site'],
      serviceId: json['service_id'],
      version: json['version'] ?? 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at']) : null,
      closedAt: json['closed_at'] != null ? DateTime.parse(json['closed_at']) : null,
      requester: json['requester'] != null ? UserModel.fromJson(json['requester']) : null,
      owner: json['owner'] != null ? UserModel.fromJson(json['owner']) : null,
      sla: json['sla'] != null ? SLAModel.fromJson(json['sla']) : null,
      triageResult: json['triage_result'] != null ? AITriageModel.fromJson(json['triage_result']) : null,
      summaryText: json['summary_text'],
      riskLevel: json['risk_level'],
    );
  }

  bool get slaBreached => (sla?.resolveBreached ?? false) || (sla?.responseBreached ?? false);
  String get requesterEmail => requester?.fullName ?? requester?.email ?? 'User';
}
