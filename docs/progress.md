# AI IT Helpdesk - Project Progress Report

**Date:** 21 September 2026  
**Active Branch:** `dev`  
**System Architecture:** FastAPI Async Backend (Python 3.13) + PostgreSQL (Alembic) + Flutter Multiplatform Client (Web, Windows, Android) + Google Gemini AI Integration

---

## 1. Executive Summary
The **AI IT Helpdesk** enterprise platform is fully operational, verified, and running locally across both backend services and frontend multiplatform runners. All core workflows—from user authentication and 24/7 wall-clock SLA tracking to AI Triage, Smart Operator Assignment, Contextual Communication Drafts, Knowledge Base Management, and In-Process Background Sweeps—have been tested and verified.

---

## 2. Key Accomplishments & Deliverables

### A. Environment, Multiplatform & Runtime Execution
- **Flutter Multiplatform SDK Configuration:**
  - Initialized Flutter 3.47.4 • Dart 3.13.3 at `D:\flutter`.
  - Configured platform runners for `web` (Chrome / CanvasKit), `windows` (Desktop C++ runner), and `android`.
  - Frontend web client verified and actively running on `http://localhost:3000`.
- **FastAPI Backend Server & In-Process Scheduler:**
  - Configured `.venv` with FastAPI, SQLAlchemy 2.0 (asyncpg & psycopg2), Alembic, Pydantic v2, Google GenAI SDK, and APScheduler.
  - Backend API server verified and running on `http://0.0.0.0:8000` with Swagger docs at `http://localhost:8000/docs`.
  - In-process APScheduler ("The Sweep") successfully registered and actively executing SLA/risk checks every 5 minutes.

### B. Database Schema & Migration Fixes
- **Circular Foreign Key Dependency Resolution:**
  - Resolved circular relationship between `teams.lead_id -> users.id` and `users.team_id -> teams.id` in initial migration `4f99d55923c7_initial_schema.py`.
  - Applied `alembic upgrade head` cleanly creating all 9 database tables: `teams`, `users`, `cases`, `slas`, `ai_triage_results`, `case_risk_assessments`, `escalation_events`, `knowledge_articles`, and `messages`.
- **Demo Data Seeder (`backend/db/seed.py`):**
  - Populated 4 teams (*Tier 1 Service Desk, NOC, Infrastructure & Cloud Ops, IAM*).
  - Seeded 6 role-based demo accounts (*Admin, Operations Manager, Operator Pune, Operator BLR, Knowledge Owner, Requester*).
  - Populated realistic Incident & Service Request cases, SLAs, AI triage records, risk assessments, and SOP Knowledge Base articles.

### C. Backend API & Serialization Fixes
- **Pydantic v2 UUID Serialization:**
  - Updated schemas across `auth.py`, `case.py`, `message.py`, `knowledge.py`, `escalation.py`, `attachment.py`, and `ai.py` to use `Union[UUID, str]`.
  - Eliminated validation errors during JSON serialization from SQLAlchemy ORM models.
- **Graceful AI Degradation (SRS §9):**
  - Updated `GeminiProvider` and `MockAIProvider` to provide deterministic, context-rich fallback responses whenever Gemini API keys are offline or unconfigured.
  - Enabled synchronous offline AI Triage, Continuous Case Summaries, and Communication Drafting.
- **Global Error Handling & CORS:**
  - Corrected `settings` import in `backend/core/exceptions.py`.
  - Configured permissive localhost CORS regex in `backend/main.py` allowing Flutter web (`http://localhost:3000`) and desktop runners.

### D. Frontend Multiplatform & Deployment Enhancements
- **AI Smart Assignment Dialog (`AssignCaseDialog`):**
  - Interactive modal fetching `/api/v1/ai/cases/{id}/smart-assignment`.
  - Displays operator workload, site matching (e.g. Pune/BLR), availability status, and match score points.
  - Enables 1-click assignment via `PATCH /api/v1/cases/{id}/assign`.
- **AI Communication Assistant (`AIDraftDialog`):**
  - Generates Progress Updates, Information Requests, and Resolution drafts with human-in-the-loop review.
  - Automatically posts approved drafts into the requester-visible message stream.
- **Continuous AI Summary & SLA Widgets:**
  - Dynamic summary updates and real-time SLA breach countdowns.
- **Physical Android Device Bridge & Network Resolution:**
  - Resolved physical device connectivity by bridging ports via `adb reverse tcp:8000 tcp:8000`.
  - Updated `AppConstants.defaultApiBaseUrl` to route to `http://localhost:8000/api/v1` across all targets.
  - Deployed and verified on physical hardware device (`CPH2757`).
- **Inno Setup 6 Windows Installer (`IT_Helpdesk-Setup.exe`):**
  - Authored custom Inno Setup script `IT_Helpdesk_Setup.iss`.
  - Compiled release binaries and packaged into standalone 10.7MB single-file installer at `installer_output/IT_Helpdesk-Setup.exe`.
  - Configured automated desktop and Start Menu shortcut creation with bundled uninstaller.

### E. Client Network Resilience & Error Handling (21 Sep 2026 — Evening)
- **ApiClient Network Error Handling (`_executeRequest()` wrapper):**
  - Added centralized network-level exception handling in `client/lib/shared/api_client.dart`.
  - Catches `SocketException`, `TimeoutException`, and `http.ClientException` at the API client layer.
  - Converts raw network failures into structured `ApiException` with user-friendly messages.
  - All HTTP methods (`get`, `post`, `patch`, `delete`) route through `_executeRequest()` with a 15-second timeout.
  - Eliminates vague "unexpected connection error" across all screens (login, cases, reports, knowledge base).
  - Added `debugPrint` logging for network-level failures in Flutter debug console.
- **ADB Reverse Port Bridge Re-establishment:**
  - Re-established physical Android device (`e19e717f`) connectivity via `adb reverse tcp:8000 tcp:8000`.
  - ADB path confirmed at `C:\Users\bores\AppData\Local\Android\Sdk\platform-tools\adb.exe`.
  - Hot restart verified on physical device (1,985ms restart time).

---

## 3. Verified API & Workflow Testing Matrix (All 24 Phase 1 Features)

| Component / Workflow | Endpoint / Method | Status | Notes |
| :--- | :--- | :--- | :--- |
| **System Health** | `GET /api/v1/health` | ✅ Passed | Returns DB status `ok` |
| **Authentication** | `POST /api/v1/auth/login` | ✅ Passed | Returns JWT access & refresh tokens |
| **User Profile** | `GET /api/v1/auth/me` | ✅ Passed | Serializes user profile with UUID |
| **Case Creation** | `POST /api/v1/cases` | ✅ Passed | Starts 24/7 SLA & AI triage |
| **Case Retrieval** | `GET /api/v1/cases/{id}` | ✅ Passed | Returns full detail context |
| **Smart Assignment**| `GET /api/v1/ai/cases/{id}/smart-assignment` | ✅ Passed | Ranks available operators |
| **Case Assignment** | `PATCH /api/v1/cases/{id}/assign` | ✅ Passed | Moves status from `New` to `Assigned` |
| **AI Draft Gen** | `POST /api/v1/ai/cases/{id}/draft` | ✅ Passed | Context-aware draft generation |
| **AI Draft Send** | `POST /api/v1/ai/drafts/{id}/send` | ✅ Passed | Posts message & triggers AI summary |
| **Knowledge Base** | `GET /api/v1/knowledge/articles` | ✅ Passed | Returns published SOP articles |
| **The Sweep (Job)**| APScheduler 5-min interval | ✅ Passed | Evaluates SLA breaches & risk signals |
| **Frontend Web**   | Flutter Web (`:3000`)        | ✅ Passed | Live interactive client UI |
| **Frontend Desktop** | Flutter Windows (`.exe`)     | ✅ Passed | Native C++ Impeller Desktop Runner |
| **Frontend Android** | Physical Phone (`CPH2757`)   | ✅ Passed | Native Vulkan Impeller Android Runner |
| **Windows Installer**| `IT_Helpdesk-Setup.exe` (10.7MB)| ✅ Passed | Inno Setup 6 standalone single-file installer |
| **Network Error Handling** | `ApiClient._executeRequest()` | ✅ Passed | SocketException, TimeoutException, ClientException caught & structured |

### E. Calmdesk Design System UI/UX Overhaul (September 2026)
- **Complete Frontend Modernization (`stitch_calmdesk_it_service_desk`):**
  - Migrated entire Flutter frontend to Calmdesk Mineral Design System with 100% zero-green policy (using slate-teal `#6E9C9B` for resolution tokens).
  - Adopted dual typography standard: **Space Grotesk** for headings/KPI stats and **Public Sans** for body/forms/labels.
  - Implemented 1px hairline rules (`#E7E4DC`), 0 elevation cards, and standardized 8px radii.
- **Redesigned All Primary Screens & Modals:**
  - `Sign in` (`sign_in_sign_up`): Institutional layout, 2.5px left accent AI suggestion card, and 1-tap quick demo login chips.
  - `Service Desk Dashboard` (`operator_dashboard` / `requester_dashboard`): 4 Space Grotesk KPI tiles, AI operator briefing card, and horizontally scrollable queue segment tabs.
  - `Case Ledger`: Space Grotesk IDs, 6px solid dot priority pills (`P1 critical`, `P3 medium`), and sentence-case status badges.
  - `Case Detail Workspace`: Horizontal lifecycle stepper (`• new`, `• in assessment`, `• assigned`), continuous AI triage summary banner, tabbed activity vs internal notes, and AI communication drafting copilot.
  - `Submit a Case`: Step 1 radio switcher, Step 2 character counters (`0/200`, `0/5,000`), and interactive AI clarifying question chips.
  - `Knowledge Base & Manager Insights`: Filterable SOP directory with instant markdown copy and fleet telemetry KPI analytics with Gemini 2.5 synthesis.
- **Physical Hardware Verification:**
  - Built debug APK, installed on physical Android device (`CPH2757`), verified live over ADB reverse bridge with zero errors and zero warnings.

---

## 4. Demo Login Credentials Reference

| Role | Email | Password | Site / Scope |
| :--- | :--- | :--- | :--- |
| **Admin** | `admin@ithelpdesk.com` | `AdminPassword123!` | System Settings & Audit Logs |
| **Manager** | `manager@ithelpdesk.com` | `ManagerPassword123!` | Cross-team Telemetry & Operations |
| **Operator (Pune)** | `operator.pune@ithelpdesk.com` | `OperatorPassword123!` | Pune Desk / Tier 1 Service Desk |
| **Operator (BLR)** | `operator.blr@ithelpdesk.com` | `OperatorPassword123!` | Bengaluru / NOC Operations |
| **Knowledge Owner**| `knowledge.owner@ithelpdesk.com` | `KnowledgePassword123!` | SOP & Knowledge Base Authoring |
| **Requester** | `requester@ithelpdesk.com` | `RequesterPassword123!` | Self-Service Case Submission |


