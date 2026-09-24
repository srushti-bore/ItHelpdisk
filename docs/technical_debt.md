# NexAssist - Technical Debt & Architectural Resolutions

**Last Updated:** 24 September 2026  
**Status:** Managed / Production-Ready

---

## 1. Resolved Technical Debt

### A. Dynamic API Base URL for Web Deployments
- **Context:** Flutter Web compilation bakes `--dart-define` parameters at build time. Previously `AppConstants.defaultApiBaseUrl` was hardcoded to `http://localhost:8000/api/v1`, which caused browser security alerts on Vercel (`Access other devices on your local network`) and request timeouts.
- **Resolution:**
  1. Updated `AppConstants.defaultApiBaseUrl` to evaluate `const String.fromEnvironment('API_BASE_URL')` first.
  2. Isolated `AppConstants.candidateApiBaseUrls` so Web exclusively targets the configured production URL and skips local private network probes (`10.x.x.x` / `10.0.2.2`).
  3. Replaced `dart:io` in `ApiClient` with standard `http.ClientException` and 15s timeout to ensure 100% web-safe execution.

### B. Supabase PostgreSQL & pgBouncer Pooling Support
- **Context:** Supabase uses pgBouncer transaction poolers on port 6543, which reject named prepared statements from `asyncpg`. Additionally, standard Supabase connection strings use the `postgresql://` scheme instead of `postgresql+asyncpg://`.
- **Resolution:**
  1. Added `@field_validator` in `backend/core/config.py` to auto-translate `postgresql://` and `postgres://` into `postgresql+asyncpg://` for async SQLAlchemy engine and `postgresql://` for sync Alembic engine.
  2. Configured `connect_args={"statement_cache_size": 0}` in `backend/db/session.py` to disable prepared statement caching when using asyncpg with Supabase poolers.

### C. Cross-Origin Resource Sharing (CORS) on Render
- **Context:** Render backend initially allowed only localhost origins. Requests originating from `https://nex-assist-five.vercel.app` were blocked by browser pre-flight CORS checks.
- **Resolution:** Updated `CORSMiddleware` in `backend/main.py` with `allow_origin_regex=r"^https?://(localhost|127\.0\.0\.1)(:\d+)?$|^https://.*\.vercel\.app$"` to dynamically allow all current and future Vercel preview/production deployments.

---

## 2. Active Technical Debt & Planned Improvements

| Area | Item | Impact | Recommended Resolution |
|---|---|---|---|
| **Storage** | Supabase Storage Attachment Upload | Low | Complete multi-part file upload direct to Supabase Storage S3 bucket instead of memory buffer. |
| **Scheduler** | Multi-Worker Sweep Locking | Medium | Add `SELECT FOR UPDATE SKIP LOCKED` on case SLA queries if scaling backend horizontally to multiple Render instances. |
| **Realtime** | WebSocket Case Updates | Low | Add Supabase Realtime / WebSocket stream to replace 30-second polling for active case queues. |
| **Cache** | Redis Layer | Low | Optional Redis instance for token blacklisting and high-frequency knowledge base query caching. |
