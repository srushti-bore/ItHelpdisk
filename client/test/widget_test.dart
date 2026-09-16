import 'package:flutter_test/flutter_test.dart';
import 'package:it_helpdesk_client/shared/models/case_model.dart';
import 'package:it_helpdesk_client/shared/models/user_model.dart';

void main() {
  test('UserModel JSON deserialization', () {
    final json = {
      'id': 'usr-123',
      'email': 'requester@test.com',
      'full_name': 'Test Requester',
      'role': 'requester',
      'auth_provider': 'password',
      'site': 'Pune',
      'availability_status': 'available',
      'email_verified': true,
      'is_active': true,
    };

    final user = UserModel.fromJson(json);
    assert(user.id == 'usr-123');
    assert(user.email == 'requester@test.com');
    assert(user.role == 'requester');
    assert(user.site == 'Pune');
  });

  test('CaseModel JSON deserialization', () {
    final json = {
      'id': 'case-123',
      'reference_number': 'INC-2026-000001',
      'type': 'incident',
      'title': 'Network Issue',
      'description': 'Wi-Fi not connecting',
      'status': 'new',
      'priority': 'P1',
      'requester_id': 'usr-123',
      'version': 1,
      'created_at': '2026-09-16T12:00:00Z',
      'updated_at': '2026-09-16T12:00:00Z',
    };

    final c = CaseModel.fromJson(json);
    assert(c.referenceNumber == 'INC-2026-000001');
    assert(c.priority == 'P1');
    assert(c.status == 'new');
  });
}
