# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Petly (Pawly) — a pet services platform for Lebanon connecting pet owners with veterinary clinics and pet stores. Phase 1 MVP uses WhatsApp deep links instead of in-app chat or booking. Two-package repo: `backend` (Node/Express/TypeScript API) and `mobile` (Flutter app).

## Commands

### Backend (`backend/`)

```bash
docker compose up -d          # start Postgres 16 (from repo root)
npm run dev --prefix backend  # or: cd backend && npm run dev  — tsx watch, http://localhost:3000
npm run db:seed --prefix backend
npm test --prefix backend     # runs all backend/src/**/*.test.ts via node --test
```

- Run a single backend test file: `cd backend && NODE_ENV=test node --import tsx --test src/modules/auth/auth.test.ts`
- Tests run with `--test-concurrency=1` (see `backend/package.json`) — they share one Postgres instance, don't parallelize test runs.
- `npm run build` runs `prisma generate && tsc`; `npm run db:migrate` for a new local migration, `db:migrate:deploy` to apply pending ones.
- If you previously ran older SQL migrations against the same Docker volume: `docker compose down -v && docker compose up -d && npm run db:seed`.
- Env is loaded from `backend/.env` (copy from `.env.example`). Postgres is required — there is no in-memory/sqlite fallback.

### Mobile (`mobile/`)

```bash
cd mobile && flutter pub get
flutter run                                                     # defaults to the hosted Render API
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000      # Android emulator -> local backend
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000     # iOS sim / desktop -> local backend
flutter analyze
flutter test                                                     # or: flutter test test/some_test.dart
```

### CI

`.github/workflows/ci.yml` runs two independent jobs on push/PR: `backend` (Postgres service container → `prisma migrate deploy` → `npm run build` → `npm test`) and `mobile` (`flutter analyze` → `flutter test`). Mirror these steps locally before assuming a change is green.

## Architecture

### Backend — modular Express, Prisma/Postgres

`backend/src/app.ts` wires middleware (helmet, CORS allowlist via `CORS_ORIGINS`, global rate limiter, JSON body parsing) and mounts one router per domain module under `backend/src/modules/{auth,users,pets,vets,stores,analytics,partners,admin}`. Each module is self-contained: `*.routes.ts` (Router + zod schemas + `validateBody`), `*.service.ts` (business logic, talks to Prisma), `*.types.ts`, and colocated `*.test.ts`.

- `backend/src/config/env.ts` is the single source of parsed env vars (JWT secret/TTLs, rate limits, CORS origins, `isProduction`) — read from there, not `process.env` directly, in new code.
- `backend/src/db/prisma.ts` exports the shared `PrismaClient` singleton and `deployMigrations()` (invoked by `server.ts` on boot, and separately by CI/`db:migrate:deploy`). `backend/src/db/mappers.ts` / `geo.ts` hold DB-row → API-shape mapping and distance/geo query helpers.
- Auth: JWT access + refresh tokens (`modules/auth/auth.tokens.ts` signs/verifies; refresh tokens are hashed and rows tracked in `RefreshToken` for revocation). `middleware/requireAuth.ts` populates `req.auth = { userId, role }`; `requireRole(...)` gates by `UserRole` (`client | partner | admin`). A default admin is ensured on boot via `ensureAdmin()` (`ADMIN_EMAIL`/`ADMIN_PASSWORD` env vars). A demo partner is ensured via `ensurePartner()` (`partner@petly.local` / `changeme-partner`).
- Public catalog (`GET /vets`, `GET /stores`) only returns `status = approved`. Partners create/edit listings at `/partners`; admins review at `/admin`.
- Guest/device-bound users: the mobile app generates a UUID `device_id` and upserts a user via `POST /users`; logging in/registering with the same `device_id` links or upgrades that guest account instead of creating a duplicate.
- Validation is zod-schema-first: routes define a schema and wrap the handler in `validateBody(schema)` (`middleware/validate.ts`), which 400s with a field-path-annotated message on failure and replaces `req.body` with the parsed/coerced value.
- Errors flow through `next(err)` to `middleware/errorHandler.ts`'s `AppError`-aware `errorHandler`/`notFoundHandler` — don't send error responses directly from route handlers.
- Prisma schema (`backend/prisma/schema.prisma`): `User` (role/status enums, unique email/phone/device_id), `Pet` (cascade-deletes with user), `Vet`/`Store` (geo fields + `featured`/`verified`/open-now flags for listing filters), `WhatsAppClick` (analytics events), `RefreshToken`.

### Mobile — Flutter, Riverpod, GoRouter, feature-first

`mobile/lib/features/{auth,home,explore,vets,stores,pets,profile,partner}` each hold their own `presentation/` (screens/widgets) and sometimes `providers/`. Shared code lives in `core/` (theme, constants, auth token storage, cross-feature Riverpod providers, reusable widgets) and `data/` (Dio-based `ApiClient`, typed models, repositories — one repository per backend module, mirroring the API surface).

- `data/api/api_client.dart` is the single Dio wrapper: it attaches the bearer access token to every request except anonymous auth paths, and on a 401 it acquires a `_refreshLock` (so concurrent 401s only trigger one refresh), retries the original request once, and calls `onSessionExpired` if refresh fails. Prefer extending this client over creating new Dio instances.
- `routes/app_router.dart` defines a single `GoRouter` (via `routerProvider`) with auth-aware `redirect` logic driven by `authProvider`; `routes/shell_screen.dart` hosts the bottom-nav shell.
- `core/constants/app_constants.dart` holds the `AppColors` palette (currently the olive/forest/cornsilk/copper set — this supersedes the older teal/orange palette described in older docs) and `apiBaseUrl`, overridable via `--dart-define=API_BASE_URL=...` at build/run time — there is no `.env` for mobile.
- Location: GPS is requested when-in-use and falls back to a hardcoded Beirut coordinate (`AppConstants.defaultLat/Lng`) if denied/unavailable.
- WhatsApp deep links (`core/utils/whatsapp.dart`) are the Phase 1 substitute for in-app chat/booking; taps are fire-and-forget POSTed to `/analytics/whatsapp-clicks`.

### Cross-cutting

- The mobile app and backend are versioned/deployed independently; the mobile default `apiBaseUrl` points at a hosted Render deployment (`petly-6f6c.onrender.com`), which cold-starts after idling — expect the first request after inactivity to take up to a minute.
- See `docs/IMPLEMENTATION_PLAN.md` for the full phased roadmap (partner onboarding, appointment requests/push, marketplace, in-app chat/payments) — current state is Phase 1.5 (auth/RBAC + GPS + click analytics + device-bound guest users), described in README.md. Next implementation: Phase 2 — follow `docs/PHASE_2_PLAN.md`.
