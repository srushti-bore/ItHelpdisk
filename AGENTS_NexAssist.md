# AI IT Helpdesk — Agent Rules (STRICT MODE)

You are working on **AI IT Helpdesk**.

These rules are **MANDATORY and NON-NEGOTIABLE**.

If any rule conflicts with your behavior → **STOP and ask for clarification**.

---

## 0. Execution Protocol (HARD REQUIREMENT)

1. Before starting ANY task → respond: **"Roger That"**  
2. After completing ANY task → respond: **"Over n Out"**  

3. If user says **"bye"**:
   - Commit all changes  
   - Push to repository  
   - Update progress + technical documentation  
   - Persist session state  
   - Respond: **"Signing off"**  

Failure to follow this = INVALID execution.

---

## 1. Determinism Rules (CRITICAL)

- Every output must be:
  - Deterministic  
  - Reproducible  
  - Based ONLY on defined inputs  

- DO NOT:
  - Guess values  
  - Infer missing fields  
  - Assume defaults not explicitly defined  
  - Generate random structures  

- If required data is missing →  
  **STOP → Ask for clarification**

---

## 2. Source of Truth Enforcement

- PRD and SRS are the ONLY sources of truth  

Rules:

- DO NOT:
  - Invent features  
  - Extend scope  
  - Modify requirements  

- If PRD ≠ SRS:
  → **SRS overrides PRD for implementation**

- If requirement not found in SRS:
  → **DO NOT IMPLEMENT**

---

## 3. Scope Lock (ABSOLUTE)

### Allowed:

- Incident Management  
- Service Request Management  
- Case lifecycle  
- AI-assisted features (as defined in SRS)  
- Notifications  
- Audit logs  
- SLA & Risk tracking  

### Forbidden:

- Any feature not explicitly defined in SRS  
- Any Phase 2 / future feature  
- Any optimization not requested  
- Any architectural enhancement  

Violation = INVALID output.

---

## 4. Architecture Integrity

- Backend = FastAPI  
- Database = PostgreSQL (Supabase)  
- Frontend = Flutter  
- AI = Backend-only integration  

Hard constraints:

- All APIs → `/api/v1/*`  
- No direct DB access from frontend  
- No background workers (Celery, Redis, queues)  
- No architecture changes  

If change required → **ASK FIRST**

---

## 5. API Contract Enforcement

- APIs must match SRS EXACTLY  

DO NOT:

- Add extra fields  
- Remove fields  
- Rename fields  
- Change response structure  

- Use strict formats:
  - Success → defined schema  
  - Error → `{ error: { code, message } }`

- All list APIs MUST:
  - Support pagination  

---

## 6. Data Integrity Rules

- Database schema is FINAL  

DO NOT:

- Modify schema  
- Add columns  
- Change relationships  

- All writes must:
  - Validate inputs  
  - Preserve consistency  

- No fake / demo data allowed  

---

## 7. AI Execution Constraints

AI is LIMITED to:

- Suggestions  
- Drafts  
- Analysis  

AI MUST NOT:

- Perform actions  
- Modify database  
- Auto-trigger workflows  
- Override user decisions  

AI MUST:

- Return confidence (Low / Moderate / High)  
- Provide reasoning  
- Indicate missing data  
- Return "insufficient data" if unsure  

---

## 8. Case System Constraints

Each case MUST include:

- Status  
- Owner OR unassigned state  
- Timeline  
- Audit logs  

DO NOT:

- Delete cases  
- Modify original input  
- Alter audit logs  

---

## 9. Audit & Logging (MANDATORY)

Every critical action MUST log:

- status change  
- assignment  
- escalation  
- AI output  

Logs must be:

- Immutable  
- Append-only  

Failure = INVALID implementation.

---

## 10. SLA & Risk Constraints

- SLA = 24/7 elapsed time ONLY  

Risk must be computed using:

- inactivity  
- SLA thresholds  
- reassignment  
- missing data  

DO NOT:

- Auto-trigger hidden actions  
- Modify case silently  

---

## 11. UI Constraints

- Follow design system strictly  
- No inline styles  
- No hardcoded values  

UI MUST handle:

- loading  
- error  
- empty states  

---

## 12. Networking Constraints

- No API calls from UI directly  
- Use defined service layer  

MUST handle:

- failure  
- timeout  
- offline  

---

## 13. Security Constraints

DO NOT:

- Expose secrets  
- Hardcode credentials  
- Commit `.env`  

MUST:

- Use environment variables  
- Follow authentication rules  
- Enforce RBAC  

---

## 14. Error Handling (STRICT)

- No silent failures  
- Always return structured errors  
- Preserve system stability  

If failure occurs:

→ Return valid error response  
→ Do NOT crash system  

---

## 15. Testing Requirements

- Feature = INCOMPLETE without tests  

Tests REQUIRED for:

- APIs  
- Business logic  
- SLA/Risk logic  

---

## 16. Code Discipline

DO NOT:

- Modify unrelated files  
- Add unnecessary abstraction  
- Duplicate logic  

MUST:

- Keep code minimal  
- Keep code readable  
- Follow defined layers  

---

## 17. Change Control

Before ANY major change:

1. Validate against SRS  
2. Validate against PRD  
3. Ask for approval  

If not approved → DO NOT proceed  

---

## 18. Failure Protocol

If ANY of the following occurs:

- Missing requirement  
- Conflicting instruction  
- Undefined behavior  

→ STOP execution  
→ Ask for clarification  

---

## 19. Completion Criteria

A task is COMPLETE only if:

- Matches SRS exactly  
- No rule violations  
- Includes validation  
- Includes error handling  
- Includes tests  

---

## FINAL RULE

> DO EXACTLY what is defined.  
> DO NOT think beyond scope.  
> DO NOT optimize.  
> DO NOT assume.  

Strict compliance is REQUIRED.