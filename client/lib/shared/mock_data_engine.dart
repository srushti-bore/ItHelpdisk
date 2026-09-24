/// NextAssist Interactive Mock Engine for Web & Offline Demos
/// Provides realistic SRS-compliant seed data when backend is unreachable or on HTTPS Vercel.
class MockDataEngine {
  static final Map<String, dynamic> mockUsers = {
    'operator@nexassist.internal': {
      'id': 'u1111111-1111-1111-1111-111111111111',
      'email': 'operator@nexassist.internal',
      'full_name': 'Priya Sharma',
      'role': 'operator',
      'site': 'Pune - Hinjawadi DC',
      'is_active': true,
      'is_available': true,
      'email_verified': true,
      'auth_provider': 'password',
    },
    'admin@nexassist.internal': {
      'id': 'u2222222-2222-2222-2222-222222222222',
      'email': 'admin@nexassist.internal',
      'full_name': 'Elena Rostova',
      'role': 'admin',
      'site': 'Global HQ - Frankfurt',
      'is_active': true,
      'is_available': true,
      'email_verified': true,
      'auth_provider': 'password',
    },
    'rahul.requester@nexassist.internal': {
      'id': 'u3333333-3333-3333-3333-333333333333',
      'email': 'rahul.requester@nexassist.internal',
      'full_name': 'Rahul Joshi',
      'role': 'requester',
      'site': 'Mumbai - Bandra Kurla',
      'is_active': true,
      'is_available': true,
      'email_verified': true,
      'auth_provider': 'password',
    },
    'teamlead@nexassist.internal': {
      'id': 'u4444444-4444-4444-4444-444444444444',
      'email': 'teamlead@nexassist.internal',
      'full_name': 'Marcus Vance',
      'role': 'team_lead',
      'site': 'Austin - Tech Center',
      'is_active': true,
      'is_available': true,
      'email_verified': true,
      'auth_provider': 'password',
    },
  };

  static Map<String, dynamic> activeUser = mockUsers['operator@nexassist.internal']!;

  static List<Map<String, dynamic>> mockCases = [
    {
      'id': 'c1000000-0000-0000-0000-000000000001',
      'reference_number': 'INC-2026-000042',
      'type': 'incident',
      'title': 'Global FortiClient VPN Gateway Connection Failure',
      'description': 'Over 45 engineers in the Pune and Frankfurt offices cannot access the internal dev clusters via VPN gateway. Error code 800: IPsec negotiation failed.',
      'status': 'in_investigation',
      'priority': 'P1',
      'site': 'Pune - Hinjawadi DC',
      'service_id': 'NET-VPN-01',
      'version': 3,
      'created_at': DateTime.now().subtract(const Duration(minutes: 42)).toIso8601String(),
      'updated_at': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
      'requester': {
        'id': 'u3333333-3333-3333-3333-333333333333',
        'full_name': 'Rahul Joshi',
        'email': 'rahul.requester@nexassist.internal',
      },
      'owner': {
        'id': 'u1111111-1111-1111-1111-111111111111',
        'full_name': 'Priya Sharma',
        'email': 'operator@nexassist.internal',
      },
      'sla': {
        'response_target': DateTime.now().subtract(const Duration(minutes: 27)).toIso8601String(),
        'resolution_target': DateTime.now().add(const Duration(minutes: 18)).toIso8601String(),
        'responded_at': DateTime.now().subtract(const Duration(minutes: 35)).toIso8601String(),
        'is_breached': false,
        'warning_triggered': true,
        'remaining_minutes': 18,
        'progress_percentage': 0.82,
      },
      'ai_triage': {
        'suggested_category': 'Network & Infrastructure',
        'suggested_priority': 'P1',
        'suggested_severity': 'Critical Outage',
        'confidence_level': 'High',
        'supporting_factors': [
          'Multiple users affected across two geographic data centers',
          'Primary gateway cluster heartbeat failure detected',
          'Automated fallback gateway link timeout',
        ],
        'suggested_team': 'Global Network Engineering',
        'sop_recommendations': [
          'SOP-NET-012: IPsec Tunnel Flush & Failover Gateway Activation',
        ],
      },
    },
    {
      'id': 'c2000000-0000-0000-0000-000000000002',
      'reference_number': 'INC-2026-000043',
      'type': 'incident',
      'title': 'CrowdStrike Falcon Sensor kernel panic on macOS Sequoia',
      'description': 'Workstation restarts randomly with kernel panic logs indicating CrowdStrike CSDAgent.sys driver clash with recent macOS update.',
      'status': 'in_assessment',
      'priority': 'P2',
      'site': 'Austin - Tech Center',
      'service_id': 'SEC-EDR-04',
      'version': 1,
      'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'updated_at': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
      'requester': {
        'id': 'u5555555-5555-5555-5555-555555555555',
        'full_name': 'Sarah Connor',
        'email': 'sarah.c@nexassist.internal',
      },
      'owner': null,
      'sla': {
        'response_target': DateTime.now().subtract(const Duration(minutes: 90)).toIso8601String(),
        'resolution_target': DateTime.now().add(const Duration(hours: 4)).toIso8601String(),
        'responded_at': DateTime.now().subtract(const Duration(hours: 1, minutes: 45)).toIso8601String(),
        'is_breached': false,
        'warning_triggered': false,
        'remaining_minutes': 240,
        'progress_percentage': 0.35,
      },
      'ai_triage': {
        'suggested_category': 'Endpoint Security',
        'suggested_priority': 'P2',
        'suggested_severity': 'High Degradation',
        'confidence_level': 'High',
        'supporting_factors': [
          'Matches known vendor vulnerability CS-2026-991',
          'Kernel stack trace references Falcon EDR extension',
        ],
        'suggested_team': 'Information Security Ops',
        'sop_recommendations': ['SOP-SEC-004: Safe Boot Sensor Reinstallation'],
      },
    },
    {
      'id': 'c3000000-0000-0000-0000-000000000003',
      'reference_number': 'SR-2026-000019',
      'type': 'service_request',
      'title': 'Developer Access Provisioning for SAP S/4HANA Finance',
      'description': 'Onboarding request for Finance Engineering team members to access SAP Sandbox and Dev environments with RFC permissions.',
      'status': 'awaiting_requester',
      'priority': 'P3',
      'site': 'Global HQ - Frankfurt',
      'service_id': 'ACC-SAP-09',
      'version': 2,
      'created_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      'updated_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      'requester': {
        'id': 'u6666666-6666-6666-6666-666666666666',
        'full_name': 'Klaus Richter',
        'email': 'klaus.r@nexassist.internal',
      },
      'owner': {
        'id': 'u1111111-1111-1111-1111-111111111111',
        'full_name': 'Priya Sharma',
        'email': 'operator@nexassist.internal',
      },
      'sla': {
        'response_target': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        'resolution_target': DateTime.now().add(const Duration(hours: 12)).toIso8601String(),
        'responded_at': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
        'is_breached': false,
        'warning_triggered': false,
        'remaining_minutes': 720,
        'progress_percentage': 0.25,
      },
      'ai_triage': {
        'suggested_category': 'Access & Identity Management',
        'suggested_priority': 'P3',
        'suggested_severity': 'Standard Request',
        'confidence_level': 'High',
        'supporting_factors': [
          'Cost-center approval verified via Active Directory',
          'Standard developer role template applies',
        ],
        'suggested_team': 'IAM & Compliance',
      },
    },
    {
      'id': 'c4000000-0000-0000-0000-000000000004',
      'reference_number': 'INC-2026-000038',
      'type': 'incident',
      'title': 'MacBook Pro Battery Swelling & Thermal Throttling',
      'description': 'Trackpad clicking is blocked due to expanding battery cell. Immediate hardware replacement required for safety.',
      'status': 'resolved',
      'priority': 'P2',
      'site': 'Mumbai - Bandra Kurla',
      'service_id': 'HW-LAP-02',
      'version': 4,
      'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'updated_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      'requester': {
        'id': 'u3333333-3333-3333-3333-333333333333',
        'full_name': 'Rahul Joshi',
        'email': 'rahul.requester@nexassist.internal',
      },
      'owner': {
        'id': 'u1111111-1111-1111-1111-111111111111',
        'full_name': 'Priya Sharma',
        'email': 'operator@nexassist.internal',
      },
      'sla': {
        'response_target': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'resolution_target': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
        'responded_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'is_breached': false,
        'warning_triggered': false,
        'remaining_minutes': 0,
        'progress_percentage': 1.0,
      },
      'ai_triage': {
        'suggested_category': 'Hardware Support',
        'suggested_priority': 'P2',
        'suggested_severity': 'Safety Hazard',
        'confidence_level': 'High',
        'supporting_factors': ['Hardware safety battery expansion policy triggered'],
      },
    },
  ];

  static List<Map<String, dynamic>> mockMessages = [
    {
      'id': 'm1',
      'case_id': 'c1000000-0000-0000-0000-000000000001',
      'sender_id': 'u3333333-3333-3333-3333-333333333333',
      'sender_name': 'Rahul Joshi',
      'sender_role': 'requester',
      'body': 'VPN gateway dropped out suddenly for all team members on the 4th floor. We cannot reach production CI/CD runners.',
      'visibility': 'requester_visible',
      'ai_generated': false,
      'created_at': DateTime.now().subtract(const Duration(minutes: 40)).toIso8601String(),
    },
    {
      'id': 'm2',
      'case_id': 'c1000000-0000-0000-0000-000000000001',
      'sender_id': 'u1111111-1111-1111-1111-111111111111',
      'sender_name': 'Priya Sharma (Operator)',
      'sender_role': 'operator',
      'body': 'Investigating IPsec tunnel telemetry on the Pune core firewall. Initiating secondary gateway failover right now.',
      'visibility': 'requester_visible',
      'ai_generated': false,
      'created_at': DateTime.now().subtract(const Duration(minutes: 25)).toIso8601String(),
    },
    {
      'id': 'm3',
      'case_id': 'c1000000-0000-0000-0000-000000000001',
      'sender_id': 'ai_copilot',
      'sender_name': 'NexAssist AI Copilot',
      'sender_role': 'ai',
      'body': 'Automated diagnostics indicate primary gateway packet loss cleared on port 4500. Recommend requesting user verification on secondary SSID.',
      'visibility': 'internal_only',
      'ai_generated': true,
      'created_at': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
    },
  ];

  static List<Map<String, dynamic>> mockArticles = [
    {
      'id': 'kb-01',
      'title': 'FortiClient VPN Error 800 & IPsec Failover SOP',
      'category': 'network',
      'body': '1. Check Active Directory DNS replication state.\n2. Open Command Prompt with admin rights and execute: ipconfig /flushdns\n3. Switch client endpoint to backup gateway: vpn-backup.nexassist.internal on port 4500.\n4. Re-authenticate via Azure AD MFA.',
      'state': 'published',
      'updated_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
    {
      'id': 'kb-02',
      'title': 'CrowdStrike Falcon Sensor Diagnostic on macOS',
      'category': 'security',
      'body': '1. Boot Mac into Recovery Mode.\n2. Execute falconctl unload in terminal.\n3. Verify kernel extension permissions in System Settings > Privacy & Security.\n4. Re-enroll workstation with customer ID checksum.',
      'state': 'published',
      'updated_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
    },
    {
      'id': 'kb-03',
      'title': 'SAP S/4HANA Role Mapping & RFC Access Matrix',
      'category': 'access',
      'body': 'Standard procedure for provisioning finance module sandbox access with read-only RFC connectors and audit logging.',
      'state': 'published',
      'updated_at': DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
    },
  ];

  static Map<String, dynamic> mockInsights = {
    'summary': {
      'total_cases': 48,
      'open_cases': 12,
      'resolved_cases': 36,
      'sla_compliance_rate': 98.4,
      'avg_response_minutes': 4.2,
      'avg_resolution_minutes': 18.5,
    },
    'priority_breakdown': {
      'P1': 2,
      'P2': 5,
      'P3': 18,
      'P4': 23,
    },
    'category_breakdown': {
      'Network': 14,
      'Hardware': 9,
      'Software': 12,
      'Access & IAM': 10,
      'Security': 3,
    },
  };

  /// Handles mock response generation for any API endpoint
  static dynamic handleRequest(String method, String endpoint, {Map<String, dynamic>? body, Map<String, dynamic>? queryParams}) {
    if (endpoint == '/auth/login' && method == 'POST') {
      final email = body?['email'] ?? 'operator@nexassist.internal';
      final profile = mockUsers[email] ?? mockUsers['operator@nexassist.internal']!;
      activeUser = profile;
      return {
        'access_token': 'mock_jwt_access_token_nexassist_live',
        'refresh_token': 'mock_jwt_refresh_token_nexassist_live',
        'user': profile,
      };
    }

    if (endpoint == '/auth/me') {
      return activeUser;
    }

    if (endpoint == '/cases' && method == 'GET') {
      return {
        'items': mockCases,
        'total': mockCases.length,
        'page': 1,
        'page_size': 50,
      };
    }

    if (endpoint.startsWith('/cases/') && endpoint.endsWith('/messages') && method == 'GET') {
      return mockMessages;
    }

    if (endpoint.startsWith('/cases/') && endpoint.endsWith('/messages') && method == 'POST') {
      final newMsg = {
        'id': 'm_${DateTime.now().millisecondsSinceEpoch}',
        'case_id': endpoint.split('/')[2],
        'sender_id': activeUser['id'],
        'sender_name': activeUser['full_name'],
        'sender_role': activeUser['role'],
        'body': body?['body'] ?? '',
        'visibility': body?['visibility'] ?? 'requester_visible',
        'ai_generated': false,
        'created_at': DateTime.now().toIso8601String(),
      };
      mockMessages.add(newMsg);
      return newMsg;
    }

    if (endpoint.startsWith('/cases/') && method == 'GET') {
      final caseId = endpoint.split('/')[2];
      return mockCases.firstWhere(
        (c) => c['id'] == caseId || c['reference_number'] == caseId,
        orElse: () => mockCases.first,
      );
    }

    if (endpoint.startsWith('/cases/') && endpoint.endsWith('/status') && method == 'PATCH') {
      final targetStatus = body?['target_status'] ?? 'in_investigation';
      return {'status': targetStatus, 'version': (body?['version'] ?? 1) + 1};
    }

    if (endpoint == '/knowledge' || endpoint.startsWith('/knowledge')) {
      return {
        'items': mockArticles,
        'total': mockArticles.length,
      };
    }

    if (endpoint == '/reports/insights') {
      return mockInsights;
    }

    if (endpoint == '/reports/export') {
      return {'status': 'success', 'download_url': 'mock_export.csv'};
    }

    return {'status': 'success', 'data': {}};
  }
}
