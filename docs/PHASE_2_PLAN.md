# Phase 2 execution plan — Partner onboarding & approval

Hand this file to a **new Cloud Agent**. It is the runbook for implementing Phase 2 of Petly. Do not start Phase 3, 5, 6, 7, or 8.

**Source of truth for sequencing:** `docs/IMPLEMENTATION_PLAN.md`  
**This file:** locked product decisions, API contracts, files to touch, tests, and Definition of Done.

---

## Prompt for the implementing agent

Copy this into the new agent:

> Implement **Phase 2 — Partner onboarding & approval** exactly as specified in `docs/PHASE_2_PLAN.md`. Work on a new branch off latest `main`. Do not implement Phase 3 (admin dashboard UI), chat, bookings, push, marketplace, or delivery. Follow existing backend module conventions (zod + `validateBody`, `AppError`, `requireAuth` / `requireRole`, Prisma) and Flutter feature-first structure (Riverpod, GoRouter, existing tokens/widgets). Land schema + public-listing filter + partner APIs + partner Flutter screens + tests. Include a **minimal admin review API** (no Flutter admin UI). Update `docs/IMPLEMENTATION_PLAN.md` and `README.md` when the phase is done. Attach testing evidence to the PR.

---

## Goal

A clinic or store owner can:

1. Register (or upgrade) as a **partner**.
2. Submit a vet and/or store listing. New and edited listings go to **`pending`**.
3. Manage their listing’s **hours** and **services** from a partner dashboard.
4. See status (`pending` / `approved` / `rejected`) and any rejection reason.

Clients keep browsing **approved** listings only. WhatsApp contact is unchanged.

## Non-goals (do not build)

| Item | Why |
| --- | --- |
| Flutter admin approvals queue, client management, featured toggles, audit log UI | Phase 3 |
| Full paginated admin CRUD for all listings/users | Phase 3 |
| In-app chat, bookings, FCM, payments, delivery | Phases 5–8 |
| Image upload to S3/Cloudinary | Cross-cutting; keep existing `image_url` string (optional URL or `asset:…`) |
| Email delivery for “your listing was approved” | No mailer yet |
| Changing the public olive/forest/cornsilk/copper palette | Phase 4 already done |

**Allowed exception:** a small **admin review API** so listings can leave `pending` and so tests can complete the loop. No admin screens.

---

## Current state (do not rediscover)

Repo: `backend/` (Express + Prisma + Postgres) and `mobile/` (Flutter + Riverpod + GoRouter).

Already done:

- JWT access + refresh, roles `client | partner | admin`, `requireAuth` / `requireRole` in `backend/src/middleware/requireAuth.ts`.
- Register always creates `role: client` (`backend/src/modules/auth/auth.service.ts`). JWT payload includes `role`; after a role change you **must re-issue tokens**.
- Public `GET /vets`, `GET /vets/emergency`, `GET /vets/:id`, `GET /stores`, `GET /stores/:id` — no create/update, **no `status` filter**.
- `Vet` / `Store` have `verified`, `featured`, `is_open_now`, services (vets only), `image_url`. **No `owner_user_id`.**
- Seeded catalog in `backend/prisma/seed.ts` (6 vets, 5 stores). Seed skip-if-data-exists must still leave those rows **approved** after migrate.
- Guest device users remain; partners are authenticated accounts.
- Tests: `node --test` in `backend/src/**/*.test.ts` (serial, shared Postgres). Flutter: `flutter analyze` + `flutter test`. CI in `.github/workflows/ci.yml`.

Public catalog must **not** go empty after this phase: backfill existing rows to `status = approved`.

---

## Locked product decisions

1. **Listing status enum:** `pending | approved | rejected`. No `draft`. Submit = create as `pending`.
2. **Any partner edit of an approved listing sets `status = pending`**, clears `reviewed_at` / `reviewer_id`, sets `submitted_at = now()`, and sets `rejection_reason = null`. Rejected listings can be edited and resubmitted (`pending`).
3. **Public list + public get** only return `status = approved`. Pending/rejected `GET /vets/:id` and `GET /stores/:id` return **404** to clients/guests (do not leak unapproved listings). Owner and admin may fetch their non-approved listing via partner/admin routes, not the public GET.
4. **`verified` stays a separate badge.** Do not treat `verified` as approval. Seeded clinics can stay `verified: true` and `status: approved`.
5. **Ownership:** `owner_user_id` is required for partner-created listings. Seeded catalog listings may have `owner_user_id = null` until a partner claims them. **Do not build a claim-existing-listing flow in this phase** (avoids fights over seeded demo data). Partners only create new listings they own.
6. **One partner may own multiple vets and multiple stores.**
7. **Become a partner:**
   - `POST /auth/register` accepts optional `role: "client" | "partner"` (default `client`). Never accept `admin`.
   - Authenticated clients can `POST /auth/become-partner`. Re-issue access + refresh tokens with `role: partner`. Idempotent if already partner. **403** if admin (admins are not partners).
8. **Hours:** JSON column `hours` on both `vets` and `stores` (see schema below). Keep `is_open_now` as a partner-editable boolean used by existing filters; do **not** auto-compute from hours in this phase (timezone edge cases). Partner UI edits both.
9. **Stores get `services String[]`** (default `[]`) so hours/services management is the same as vets.
10. **Minimal admin review API** is in scope. Flutter admin UI is not.
11. **Featured** stays admin-only. Partners cannot set `featured` or `verified`. Ignore those fields on partner create/update payloads.

---

## Schema

New Prisma enum + fields. Create a **new Prisma Migrate** under `backend/prisma/migrations/` (follow existing timestamp-folder style). Do not edit old migrations.

```prisma
enum ListingStatus {
  pending
  approved
  rejected
}

model User {
  // existing fields...
  ownedVets   Vet[]   @relation("VetOwner")
  ownedStores Store[] @relation("StoreOwner")
  reviewedVets   Vet[]   @relation("VetReviewer")
  reviewedStores Store[] @relation("StoreReviewer")
}

model Vet {
  // existing fields...
  ownerUserId      String?        @map("owner_user_id") @db.Uuid
  status           ListingStatus  @default(approved)
  rejectionReason  String?        @map("rejection_reason") @db.VarChar(500)
  submittedAt      DateTime?      @map("submitted_at") @db.Timestamptz
  reviewedAt       DateTime?      @map("reviewed_at") @db.Timestamptz
  reviewerId       String?        @map("reviewer_id") @db.Uuid
  hours            Json?

  owner    User? @relation("VetOwner", fields: [ownerUserId], references: [id], onDelete: SetNull)
  reviewer User? @relation("VetReviewer", fields: [reviewerId], references: [id], onDelete: SetNull)

  @@index([status])
  @@index([ownerUserId])
}

model Store {
  // existing fields...
  services         String[]       @default([])
  ownerUserId      String?        @map("owner_user_id") @db.Uuid
  status           ListingStatus  @default(approved)
  rejectionReason  String?        @map("rejection_reason") @db.VarChar(500)
  submittedAt      DateTime?      @map("submitted_at") @db.Timestamptz
  reviewedAt       DateTime?      @map("reviewed_at") @db.Timestamptz
  reviewerId       String?        @map("reviewer_id") @db.Uuid
  hours            Json?

  owner    User? @relation("StoreOwner", fields: [ownerUserId], references: [id], onDelete: SetNull)
  reviewer User? @relation("StoreReviewer", fields: [reviewerId], references: [id], onDelete: SetNull)

  @@index([status])
  @@index([ownerUserId])
}
```

**Default `approved`:** existing seed rows stay public after migrate without a data backfill. Partner-created rows **must set `pending` in the service**, not rely on the DB default.

**Hours JSON shape** (validate with zod; store as Prisma `Json`):

```json
{
  "timezone": "Asia/Beirut",
  "weekly": [
    { "day": 0, "closed": true },
    { "day": 1, "open": "09:00", "close": "18:00" }
  ]
}
```

- `day`: `0 = Sunday` … `6 = Saturday`.
- Either `closed: true` **or** both `open` and `close` as `HH:mm` 24h.
- `weekly` max 7 unique days. Missing days = closed.
- `hours` is optional on create.

SQL migration should add columns with `status` default `'approved'` so current catalog stays visible.

---

## API contracts

Reuse snake_case JSON like the rest of the API. Use `validateBody` + zod. Errors via `next(err)` / `AppError`.

### Public (unchanged paths, new filter)

| Method | Path | Auth | Behavior |
| --- | --- | --- | --- |
| `GET` | `/vets` | none | Only `status = approved`. Same query filters as today. |
| `GET` | `/vets/emergency` | none | Approved + emergency + open_now. |
| `GET` | `/vets/:id` | none | 404 if missing **or not approved**. |
| `GET` | `/stores` | none | Only approved. |
| `GET` | `/stores/:id` | none | 404 if missing **or not approved**. |

Public JSON may include `status: "approved"` and `hours` (clients can show hours on detail). Do **not** include `rejection_reason`, `reviewer_id`, or other review internals on public payloads.

### Auth

| Method | Path | Auth | Behavior |
| --- | --- | --- | --- |
| `POST` | `/auth/register` | none | Optional `role: "client" \| "partner"`. Default client. Reject `admin`. |
| `POST` | `/auth/become-partner` | `requireAuth` | `client` → `partner`; rotate tokens (same shape as login). Already partner: still return a fresh session. Admin: 403. |

### Partner (new module)

Mount at `/partners`. All routes: `requireAuth` + `requireRole('partner')`.

| Method | Path | Behavior |
| --- | --- | --- |
| `GET` | `/partners/me/listings` | `{ vets: Vet[], stores: Store[] }` owned by `req.auth.userId`, **all statuses**. Include `status`, `rejection_reason`, `submitted_at`, `hours`. |
| `POST` | `/partners/vets` | Create; `owner_user_id = req.auth.userId`; `status = pending`; `submitted_at = now()`. 201. |
| `GET` | `/partners/vets/:id` | Owner only; 404 otherwise. |
| `PATCH` | `/partners/vets/:id` | Owner only. Apply fields; set `pending` as in decision 2. Cannot change `featured`, `verified`, `owner_user_id`, `status` directly. |
| `POST` | `/partners/stores` | Same as vets. |
| `GET` | `/partners/stores/:id` | Owner only. |
| `PATCH` | `/partners/stores/:id` | Owner only; same pending rules. |

**Create vet body (zod):**

- required: `name`, `phone`, `location`
- optional: `latitude`, `longitude`, `services` (string array, max 20, each max 80 chars), `is_emergency`, `is_open_now`, `image_url` (string max 500), `hours`

**Create store body:**

- required: `name`, `location`, `type`
- optional: `phone`, lat/lng, `services`, `is_open_now`, `image_url`, `hours`

**Patch:** all of the above optional; at least one field required.

Do not add partner DELETE in this phase (admin delete is Phase 3).

### Admin review (minimal, new module)

Mount at `/admin`. All routes: `requireAuth` + `requireRole('admin')`.

| Method | Path | Behavior |
| --- | --- | --- |
| `GET` | `/admin/listings?status=pending` | `{ vets, stores }` filtered by status (default `pending`). No pagination required. |
| `PATCH` | `/admin/vets/:id/review` | Body `{ status: "approved" \| "rejected", rejection_reason?: string }`. Rejected **requires** `rejection_reason` (min 3 chars). Set `reviewed_at`, `reviewer_id = req.auth.userId`. Approved clears `rejection_reason`. 409 if listing is not `pending`. |
| `PATCH` | `/admin/stores/:id/review` | Same. |

This is enough for tests and curl. **Do not** add Flutter screens for these.

---

## Backend implementation notes

**New files (suggested):**

- `backend/src/modules/partners/partners.routes.ts`
- `backend/src/modules/partners/partners.service.ts`
- `backend/src/modules/partners/partners.types.ts`
- `backend/src/modules/partners/partners.test.ts` (supertest, follow `auth.test.ts`)
- `backend/src/modules/admin/admin.routes.ts`
- `backend/src/modules/admin/admin.service.ts`
- `backend/src/modules/admin/admin.test.ts`

**Touch existing:**

- `backend/prisma/schema.prisma` + new migration
- `backend/prisma/seed.ts` — seed a partner account (see credentials below); existing vets/stores stay approved (DB default). Optional: one pending vet owned by the partner for local demo.
- `backend/src/app.ts` — mount `/partners` and `/admin`
- `backend/src/db/mappers.ts` — map new fields; public vs partner/admin mapper if needed
- `backend/src/modules/vets/vets.service.ts` / `stores.service.ts` — `where: { status: 'approved' }` on public list/get
- `backend/src/modules/vets/vets.types.ts` / `stores.types.ts`
- `backend/src/modules/auth/auth.routes.ts` / `auth.service.ts` / `auth.types.ts` — register role + become-partner
- `backend/src/modules/vets/vets.service.test.ts` — public list must not return a pending vet you create in the test

**Authorship checks:** compare `listing.ownerUserId === req.auth.userId`. 404 (not 403) for the wrong owner so IDs are not enumerable.

**Hours validator:** shared zod schema in e.g. `backend/src/modules/listings/hours.schema.ts` used by partners create/patch.

---

## Seed / local demo accounts

Keep existing admin:

- `admin@petly.local` / `changeme-admin` (`ADMIN_EMAIL` / `ADMIN_PASSWORD`)

Add partner (upsert by email, bcrypt same as `ensureAdmin`):

- email `partner@petly.local`
- password `changeme-partner`
- role `partner`
- name `Demo Partner`

If you add a demo pending listing, name it clearly (e.g. `Pending Partner Clinic`) so it is obvious it must **not** appear on Home/Explore.

---

## Flutter implementation notes

Match existing patterns: `features/<name>/presentation` + `providers`, repositories in `data/repositories`, models in `data/models`, GoRouter in `mobile/lib/routes/app_router.dart`. Use `AppTokens`, `SoftCard`, `AuthScaffold` / `PetlyBackground` / `AsyncErrorView`. Do not introduce a new palette.

### Models

- Extend `Vet` / `Store` with optional `status`, `rejectionReason`, `hours`, `services` (stores), `submittedAt`. Public list parsing must still work if those keys are present.
- Hours: small `ListingHours` model (`timezone`, `weekly` entries).

### Data layer

- `mobile/lib/data/repositories/partners_repository.dart` — listings, create, patch.
- `mobile/lib/data/repositories/auth_repository.dart` — register `role` param; `becomePartner()`.
- Reuse `ApiClient` (bearer + refresh). Do not add a second Dio.

### Auth / register

- Register screen: optional toggle **“I’m a clinic or store owner”** that sends `role: partner`. Default off (client).
- After become-partner, persist new tokens via existing `authProvider` (same as login).

### Routes (partner-gated)

Redirect: if location starts with `/partner` and user is not `role == partner`, send to `/profile` (or login). Guests cannot open partner routes.

| Path | Screen |
| --- | --- |
| `/partner` | Dashboard: my vets + stores, status chips, CTA to add vet/store |
| `/partner/vets/new` | Create vet form |
| `/partner/vets/:id/edit` | Edit vet (hours, services, contact, flags except featured/verified) |
| `/partner/stores/new` | Create store form |
| `/partner/stores/:id/edit` | Edit store |

Do **not** add a fifth bottom-nav tab. Entry points:

- Profile: **“Partner dashboard”** when `role == partner`.
- Profile: **“List your clinic or store”** when `role == client` (not guest) → confirm → `become-partner` → `/partner`.
- Guests see a short line: sign in / register as partner to list a business.

### UX requirements

- Status chip: Pending / Approved / Rejected. Rejected shows `rejection_reason`.
- After save, copy: “Submitted for review. It will appear in Explore once approved.”
- Hours editor: 7-day list, closed toggle, open/close time fields. Default timezone `Asia/Beirut`.
- Services: chip input or comma-separated field (keep it simple; vets already use `List<String>`).
- Empty dashboard: illustration/`EmptyState` + add clinic / add store.
- Reuse form validation style from `add_pet_screen.dart` / register.

### Tests

- Widget/unit tests for: status chip rendering; hours model parse; partner dashboard empty state; register includes partner role flag if that’s a pure widget.
- Extend `mobile/test/listing_models_test.dart` for new JSON fields.
- `flutter analyze` must be clean.

---

## Suggested implementation order

Do this in order; keep the branch committable after each chunk.

1. **Schema + migration + mappers + public filter.** Tests: pending vet is absent from `listVets` / `getVetById` (404); approved still lists. Seed still works (`db:seed`).
2. **Auth:** register `role`, `POST /auth/become-partner` + token rotation. Tests in `auth.test.ts`.
3. **Partner service/routes.** Tests: create pending; public list ignores it; owner GET works; other partner 404; PATCH approved → pending; cannot set featured.
4. **Admin review API.** Tests: approve then public GET 200; reject requires reason; non-admin 403; review of non-pending 409.
5. **Flutter models/repos/register toggle/become-partner.**
6. **Partner dashboard + forms + hours editor + profile entry points + route guards.**
7. **Docs:** mark Phase 2 done in `docs/IMPLEMENTATION_PLAN.md` and `README.md` roadmap; keep this file as historical runbook or add a one-line “implemented” note at the top.
8. **Testing gate** (below) and PR with evidence.

---

## Testing gate (Definition of Done)

From `docs/IMPLEMENTATION_PLAN.md`. Phase 2 is not done until all of this passes.

### Automated

```bash
# backend (Postgres via docker compose from repo root)
docker compose up -d
cd backend && npx prisma migrate deploy && npm test && npm run build

# mobile
cd mobile && flutter analyze && flutter test
```

Required cases (implement as tests, not only manual):

- Public `GET /vets` / `/stores` never returns `pending` or `rejected`.
- Public `GET /:id` 404s for pending.
- Partner create → pending; owner can see it on `/partners/me/listings`.
- Client cannot call `/partners/*` (403).
- Unauthenticated partner routes 401.
- Admin approve → public GET 200; admin reject without reason 400; partner edit of approved → pending again.
- Register `role: partner` works; `role: admin` rejected.
- `become-partner` upgrades client and new access token has `role: partner`.
- Seeded/default listings remain visible as approved after migrate.

### Manual / E2E (attach screenshots or a short video to the PR)

Against local Postgres + `flutter run` (or web):

1. Register as partner (toggle on) → Partner dashboard empty → create a vet with hours + services → status Pending → confirm it does **not** show on Home/Explore.
2. `PATCH` approve as admin (curl or HTTP file using `admin@petly.local`) → listing appears on Explore / detail; WhatsApp still works.
3. Edit the approved listing as partner → status back to Pending → disappears from Explore.
4. Admin reject with reason → partner edit screen shows the reason.
5. Client account: Profile “List your clinic or store” → become partner → can create a store.
6. Guest: no partner dashboard; existing guest pet flow still works.
7. Regression: login/register as client, add pet, browse vets/stores, WhatsApp tap.

### Regression

- CI backend + mobile jobs green.
- Default admin can still log in.
- Phase 4 UI (palette, paw background, listing photos) unchanged for public screens.

---

## Docs to update when implementing (not now)

When Phase 2 code lands, the implementing agent should:

- Mark Phase 2 **done** in `docs/IMPLEMENTATION_PLAN.md` (same style as Phase 1 / 4).
- Add a short **Phase 2** bullet list to `README.md` (endpoints + partner flow).
- Point `CLAUDE.md` “current state” at Phase 2 done / Phase 3 next.
- Add partner + admin review rows to the README API table.

Do **not** expand this runbook into Phase 3 work.

---

## Files likely involved (checklist)

**Backend:** `prisma/schema.prisma`, new migration, `prisma/seed.ts`, `src/app.ts`, `src/db/mappers.ts`, `modules/vets/*`, `modules/stores/*`, `modules/auth/*`, new `modules/partners/*`, new `modules/admin/*`.

**Mobile:** `data/models/vet.dart`, `store.dart`, new hours model, `data/repositories/auth_repository.dart`, new `partners_repository.dart`, `features/auth/presentation/register_screen.dart`, `features/profile/presentation/profile_screen.dart`, `routes/app_router.dart`, new `features/partner/**`, tests under `mobile/test/`.

---

## Out-of-scope reminders for reviewers

If a PR includes Flutter admin, audit logs, pagination dashboards, Socket.IO, bookings, or FCM, it has slipped into a later phase. Send that work back.
