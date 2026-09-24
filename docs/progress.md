# NexAssist - Project Progress & Deployment Report

**Date:** 24 September 2026  
**Active Branch:** `dev` / `main` (Synced)  
**System Architecture:** FastAPI Async Backend (Python 3.13 on Render) + Cloud PostgreSQL (Supabase) + Flutter Web (Vercel) + Windows Desktop & Android + Google Gemini AI Integration

---

## 1. Executive Summary
The **NexAssist** (formerly AI IT Helpdesk) enterprise technical operations platform is fully rebranded, architected, and deployed across a production-grade cloud stack:
- **Cloud Database:** Supabase PostgreSQL with 9 Alembic tables and full demo seed data.
- **Cloud Backend:** FastAPI on Render (`https://nexassist-backend.onrender.com`) with in-process APScheduler ('The Sweep').
- **Cloud Frontend:** Flutter Web on Vercel (`https://nex-assist-five.vercel.app`) with the Calmdesk Mineral Design System.
- **Local Runners:** Windows Desktop C++ runner and Android physical device runner via ADB reverse bridge.

---

## 2. Key Accomplishments & Deliverables

### A. Cloud Infrastructure & Live Deployment
- **Supabase Cloud Database:**
  - Database schema created with 9 core tables migrated via Alembic (`teams`, `users`, `cases`, `slas`, `ai_triage_results`, `case_risk_assessments`, `escalation_events`, `knowledge_articles`, `messages`).
  - Seed script executed (`python -m backend.db.seed`) populating 6 role-based demo accounts, 4 enterprise teams, active cases, SLA policies, and SOP articles.
  - Storage bucket `attachments` initialized for case files.
- **Render Backend Web Service:**
  - Service configured on Python 3.13 with Gunicorn/Uvicorn worker.
  - Supabase connection pooling compatibility configured (`statement_cache_size=0` for asyncpg/pgBouncer).
  - Dynamic `DATABASE_URL` scheme auto-converter (`postgresql://` -> `postgresql+asyncpg://`).
  - Permissive CORS regex middleware allowing all `*.vercel.app` domains, `localhost:3000`, `localhost:8000`, and custom origins.
- **Vercel Frontend Web Deployment:**
  - Configured custom Flutter Web build script with `--dart-define=API_BASE_URL=$API_BASE_URL`.
  - Added `vercel.json` SPA rewrite rules for clean client-side routing.
  - Dynamic `AppConstants.defaultApiBaseUrl` and `candidateApiBaseUrls` extracting build-time environment variables.
  - Eliminated web-incompatible `dart:io` imports in favor of `http.ClientException` and 15s timeout.

### B. UI/UX Rebranding — Calmdesk Mineral Design System
- **Design Philosophy:** `#F7F6F3` calm mineral canvas, zero elevation, clean `#E3E1DC` borders, `#2D5BE3` cobalt primary accent, zero pure green.
- **Dual Typography System:** `Space Grotesk` for high-impact metric headers and navigation titles; `Public Sans` for readable body text and technical logs.
- **Comprehensive Screen Polish:** Overhauled Login, Executive Dashboard, Case Management, Case Detail (with Live Sweep SLA Progress), Knowledge Base (SOP articles), and Operational Insights.

---

## 3. Deployment Matrix & Live Endpoints

| Component | Platform / Host | Live URL / Target | Status |
|---|---|---|---|
| **Frontend Web** | Vercel | `https://nex-assist-five.vercel.app` | [x] Deployed |
| **Backend API** | Render | `https://nexassist-backend.onrender.com` | [x] Live |
| **API Health Check** | Render | `https://nexassist-backend.onrender.com/api/v1/health` | [x] Live |
| **Cloud Database** | Supabase | `aws-0-ap-southeast-1.pooler.supabase.com:6543` | [x] Seeded |
| **Desktop Client** | Windows C++ | `client/build/windows/runner/Release` | [x] Verified |
| **Mobile Client** | Android APK | `client/build/app/outputs/flutter-apk` | [x] Verified |

---

## 4. Demo Accounts & Verification Reference

| Role | Email | Password | Assigned Scope |
|---|---|---|---|
| **Admin** | `admin@ithelpdesk.com` | `AdminPassword123!` | Global administration, team & user management |
| **Manager** | `manager@ithelpdesk.com` | `ManagerPassword123!` | Queue triage, escalation overrides, SLA telemetry |
| **Operator (Pune)** | `operator.pune@ithelpdesk.com` | `OperatorPassword123!` | Pune hardware/network case handling |
| **Operator (BLR)** | `operator.blr@ithelpdesk.com` | `OperatorPassword123!` | Bengaluru cloud/identity case handling |
| **Knowledge Owner** | `knowledge.owner@ithelpdesk.com` | `KnowledgePassword123!` | SOP article curation & publishing |
| **Requester** | `requester@ithelpdesk.com` | `RequesterPassword123!` | Self-service portal & ticket submission |
