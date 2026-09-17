import json
import urllib.request
import urllib.parse

base_url = 'http://127.0.0.1:8000/api/v1'

print('===============================================================')
print('STARTING AUTOMATED LIVE API TEST RUN (POSTMAN-EQUIVALENT)')
print('===============================================================')

# 1. Test Health Endpoint
print('\n[1] Testing GET /health ...')
req = urllib.request.Request(f'{base_url}/health')
with urllib.request.urlopen(req) as resp:
    print(f'Status: {resp.status}, Body: {resp.read().decode()}')

# 2. Test Login (Auth)
print('\n[2] Testing POST /auth/login (as Admin) ...')
login_payload = json.dumps({'email': 'admin@ithelpdesk.com', 'password': 'AdminPassword123!'}).encode('utf-8')
req = urllib.request.Request(f'{base_url}/auth/login', data=login_payload, headers={'Content-Type': 'application/json'})
with urllib.request.urlopen(req) as resp:
    data = json.loads(resp.read().decode())
    token = data['access_token']
    user_name = data['user']['full_name']
    user_role = data['user']['role']
    print(f'Status: {resp.status}')
    print(f'Token Generated: Bearer {token[:30]}... (User: {user_name}, Role: {user_role})')

auth_headers = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}

# 3. Test List Cases
print('\n[3] Testing GET /cases (Authenticated) ...')
req = urllib.request.Request(f'{base_url}/cases?page=1&page_size=5', headers=auth_headers)
with urllib.request.urlopen(req) as resp:
    cases_data = json.loads(resp.read().decode())
    print(f'Status: {resp.status}, Total Cases in DB: {cases_data["total"]}')
    for c in cases_data['items'][:3]:
        print(f'  - [{c["reference_number"]}] ({c["priority"]}) {c["title"]} -> Status: {c["status"]}')

# 4. Test Create Case
print('\n[4] Testing POST /cases (Creating Live Incident) ...')
case_payload = json.dumps({
    'type': 'incident',
    'title': 'Postman Live Test: Monitor flickering on Desk 12',
    'description': 'Dual-screen setup is intermittently turning black during video calls.',
    'priority': 'P3',
    'site': 'Pune'
}).encode('utf-8')
req = urllib.request.Request(f'{base_url}/cases', data=case_payload, headers=auth_headers)
with urllib.request.urlopen(req) as resp:
    created = json.loads(resp.read().decode())
    print(f'Status: {resp.status}, Created Case: {created["reference_number"]} - {created["title"]}')

# 5. Test Knowledge Base
print('\n[5] Testing GET /knowledge/articles ...')
req = urllib.request.Request(f'{base_url}/knowledge/articles', headers=auth_headers)
with urllib.request.urlopen(req) as resp:
    kb_data = json.loads(resp.read().decode())
    print(f'Status: {resp.status}, Total SOP Articles: {kb_data["total"]}')
    for kb in kb_data['items']:
        print(f'  - [{kb["category"]}] {kb["title"]}')

# 6. Test Manager Operational Insights
print('\n[6] Testing GET /reports/operational-insights ...')
req = urllib.request.Request(f'{base_url}/reports/operational-insights', headers=auth_headers)
with urllib.request.urlopen(req) as resp:
    rep_data = json.loads(resp.read().decode())
    m = rep_data['metrics']
    print(f'Status: {resp.status}')
    print(f'  Telemetry: Total Cases={m["total_cases"]}, Open={m["open_cases"]}, Resolved={m["resolved_cases"]}, SLA Compliance={m["sla_compliance_rate"]}%, MTTR={m["average_resolution_hours"]}h')

print('\n===============================================================')
print('SUCCESS: ALL 6 API TEST SUITES PASSED WITH 100% (STATUS 200/201)!')
print('===============================================================')
