# AI IT Helpdesk - Technical Debt & Architectural Assessment

**Date:** 17 September 2026  
**Scope:** Backend (FastAPI / PostgreSQL), Client (Flutter), AI Integration (Gemini), DevOps & Deployment

---

## 1. Overview
This document tracks identified areas of technical debt, architectural trade-offs made during rapid development/prototyping, and recommended refactorings for future production milestones.

---

## 2. High-Priority Items (Near-Term)

### 2.1 Storage Provider Integration (Supabase S3)
- **Current State:** File upload endpoints (`POST /cases/{id}/attachments`) use mock in-memory buffer handling when `SUPABASE_URL` is empty.
- **Debt / Risk:** Local server restarts will lose non-persisted attachment binary files.
- **Remediation:** Configure real Supabase Storage bucket with signed URL expiration (15 minutes) and integrate virus scanning (ClamAV) on upload per SRS §7.2.

### 2.2 Redis / Distributed Caching Layer
- **Current State:** Rate-limiting and duplicate detection queries hit PostgreSQL directly.
- **Debt / Risk:** High concurrent traffic on search / duplicate detection can lead to database connection saturation.
- **Remediation:** Introduce Redis for session revocation, token blacklisting, caching Knowledge Base search vectors, and distributed locks for background scheduler jobs.

### 2.3 APScheduler Multi-Worker Concurrency
- **Current State:** 'The Sweep' periodic job runs in-process using APScheduler inside the FastAPI lifespan process.
- **Debt / Risk:** If uvicorn runs with multiple workers (`--workers 4`), multiple instances of 'The Sweep' will run concurrently and may attempt duplicate SLA breach evaluations.
- **Remediation:** Migrate background job execution to Celery with Redis/RabbitMQ broker, or use database-level row locking (`SELECT FOR UPDATE SKIP LOCKED`) during sweep processing.

---

## 3. Medium-Priority Items (Code & Architecture)

### 3.1 Strict Typing & Pydantic Config Validation
- **Current State:** Schemas now use `Union[UUID, str]` for compatibility between SQLAlchemy UUID objects and API input strings.
- **Improvement:** Implement custom Pydantic V2 `Annotated[UUID, PlainSerializer(...)]` types to standardize all ID representations across the codebase without repeating `Union[UUID, str]`.

### 3.2 WebSocket Live Updates for Case Timeline
- **Current State:** Case messages and status updates rely on manual screen refresh or polling upon action completion.
- **Improvement:** Implement FastAPI WebSocket channels or Server-Sent Events (SSE) so operators and requesters see incoming messages and status changes in real-time.

### 3.3 Flutter Client State Management Refactoring
- **Current State:** `CaseDetailScreen` manages message sending, status transition, and assignment with local `setState`.
- **Improvement:** Extract case details logic into dedicated `CaseController` / `Provider` to keep UI components purely declarative and simplify component-level widget testing.

---

## 4. Testing & Quality Assurance Debt

### 4.1 Automated E2E & Integration Test Coverage
- **Current State:** Unit and endpoint tests exist, but full headless browser integration tests are manual due to environment driver restrictions.
- **Remediation:** Add GitHub Actions CI workflow running `pytest` with a dedicated PostgreSQL test container and `flutter test` for widget coverage.

### 4.2 Seed Data vs Production Migrations
- **Current State:** `backend/db/seed.py` creates demo accounts and static cases directly in the database.
- **Remediation:** Ensure seed scripts are strictly isolated to dev/staging environments with environment flag checks (`ENVIRONMENT != 'production'`).

---

## 5. Security & Compliance Checklist

- [x] Passwords hashed using bcrypt (`pwd_context.hash`).
- [x] JWT token expiration enforced (15-min access token in production, 24-hr dev token).
- [x] CORS restricted by regex pattern to localhost origins.
- [x] `.env` secrets excluded from version control via `.gitignore`.
- [ ] Implement CSRF token protection for cookie-based sessions.
- [ ] Configure Content Security Policy (CSP) headers on Flutter Web build output.
