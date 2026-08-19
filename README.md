# Petly (Pawly)

Pet services platform for Lebanon — connect pet owners with veterinary clinics and pet stores. Phase 1 MVP uses WhatsApp deep links instead of in-app chat or booking.

## Stack

| Layer | Tech |
|-------|------|
| Mobile | Flutter 3 + Riverpod + GoRouter + Dio |
| API | Node.js + Express + TypeScript |
| Database | PostgreSQL 16 (Prisma ORM) |

## Quick start

### 1. Backend

```bash
cd backend
cp .env.example .env
npm install
```

PostgreSQL is required (Docker Desktop):

```bash
# from repo root
docker compose up -d
cd backend
npm run db:seed
npm run dev
```

If you previously ran the older SQL migrations against the same Docker volume, reset it once:

```bash
docker compose down -v
docker compose up -d
cd backend
npm run db:seed
```

API: `http://localhost:3000`  
Health: `GET /health`

### 2. Flutter app

```bash
cd mobile
flutter pub get
```

**Android emulator / physical device** (default API `https://petly-6f6c.onrender.com`):

```bash
flutter run
```

The first request after the Render service has been idle can take up to a minute (cold start).

On boot the API applies pending Prisma migrations and ensures demo store items exist for the seeded catalog stores. Production enables Express `trust proxy` (one hop) so rate limiting can use Render’s `X-Forwarded-For` header.

**Local API** (Android emulator → host machine):

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

**iOS simulator / Windows desktop** (local API):

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

### Google Sign-In

Keep email/password. Google only proves identity; the API still issues Petly JWTs.

1. In Google Cloud Console, create OAuth client IDs for **Web**, **Android** (`com.petly.petly` + your SHA-1), and **iOS** (`com.petly.petly`).
2. Backend `.env`: `GOOGLE_CLIENT_IDS=<web-id>,<android-id>,<ios-id>` (used as ID-token `aud`).
3. Flutter: `--dart-define=GOOGLE_WEB_CLIENT_ID=<web-id>` and, on iOS, `--dart-define=GOOGLE_IOS_CLIENT_ID=<ios-id>`. iOS also needs the reversed iOS client ID as a URL scheme in Xcode.
4. Android debug SHA-1: `cd mobile/android && ./gradlew signingReport`

Same Google email as an existing password account links them. Partners can still use Profile → become partner; listing contact stays phone/WhatsApp.

## API endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | Health check |
| `POST` | `/auth/register` | Create account (`name`, `email`, `password`, optional `phone`, `device_id`, `role`: `client` or `partner`) |
| `POST` | `/auth/login` | Email + password (optional `device_id` to link a guest) |
| `POST` | `/auth/oauth` | Google Sign-In (`provider: google`, `id_token`, optional `device_id`, `role`) |
| `POST` | `/auth/refresh` | Rotate tokens (`refresh_token`) |
| `POST` | `/auth/logout` | Revoke a refresh token |
| `GET` | `/auth/me` | Current user (Bearer access token) |
| `POST` | `/auth/forgot-password` | Generic ack (email delivery not wired yet) |
| `POST` | `/auth/become-partner` | Upgrade a signed-in client to partner (rotates tokens) |
| `GET` | `/vets` | List **approved** vets (`search`, `open_now`, `emergency`, `lat`, `lng`, `max_distance_km`) |
| `GET` | `/vets/emergency` | Open emergency clinics (approved only) |
| `GET` | `/vets/:id` | Vet details (404 if missing or not approved) |
| `GET` | `/stores` | List **approved** stores |
| `GET` | `/stores/nearest/items` | In-stock items from the nearest approved store (`lat`, `lng`, `limit`) |
| `GET` | `/stores/:id` | Store details (404 if missing or not approved) |
| `GET` | `/stores/:id/items` | Items listed by an approved store |
| `GET` | `/partners/me/listings` | Partner: own vets + stores (all statuses) |
| `POST` | `/partners/vets` | Partner: create clinic (`pending`) |
| `GET` | `/partners/vets/:id` | Partner: own clinic |
| `PATCH` | `/partners/vets/:id` | Partner: edit clinic (resubmits as `pending`) |
| `POST` | `/partners/stores` | Partner: create store (`pending`) |
| `GET` | `/partners/stores/:id` | Partner: own store |
| `PATCH` | `/partners/stores/:id` | Partner: edit store (resubmits as `pending`) |
| `GET` | `/partners/stores/:id/items` | Partner: items for own store |
| `POST` | `/partners/stores/:id/items` | Partner: add an item (does not change listing status) |
| `PATCH` | `/partners/stores/:id/items/:itemId` | Partner: edit an item |
| `DELETE` | `/partners/stores/:id/items/:itemId` | Partner: delete an item |
| `GET` | `/admin/listings` | Admin: listings by `status` (default `pending`) |
| `PATCH` | `/admin/vets/:id/review` | Admin: approve or reject a clinic |
| `PATCH` | `/admin/stores/:id/review` | Admin: approve or reject a store |
| `POST` | `/users` | Create / upsert guest user |
| `GET` | `/users` | List users (admin) |
| `GET` | `/users/:id` | Get user (self or admin) |
| `POST` | `/pets` | Add pet |
| `GET` | `/pets?user_id=` | List pets for user |
| `PATCH` | `/pets/:id` | Update pet |
| `DELETE` | `/pets/:id` | Delete pet |

## App structure

```
mobile/lib/
  core/           # theme, constants, providers, widgets, auth storage
  data/           # models, Dio client, repositories
  features/       # auth, home, explore, vets, stores, pets, profile, partner
  routes/         # GoRouter + bottom nav shell + auth guards
backend/src/
  modules/        # auth, users, pets, vets, stores, analytics, partners, admin
  middleware/     # validation, requireAuth / requireRole
  db/             # Prisma client, mappers, geo helpers
backend/prisma/     # schema, migrations, seed
```

## Design system

- Primary `#2EC4B6` · Secondary `#FF9F1C` · Background `#F7F9FB` · Text `#1A1A1A`
- Poppins (Google Fonts), 14–16px rounded corners, soft shadows

## Phase 1.5 additions

- **GPS location** — requests when-in-use permission; falls back to Beirut if denied/unavailable. Tap the home location row to refresh.
- **WhatsApp click analytics** — `POST /analytics/whatsapp-clicks` (fire-and-forget from the app). Stats: `GET /analytics/whatsapp-clicks/stats`.
- **Device-bound user** — UUID stored in `shared_preferences`, upserted via `POST /users` with `device_id`. Pets stay tied to that user across launches. Registering/logging in with the same `device_id` upgrades or links the guest account.
- **Auth (Phase 1)** — JWT access + refresh tokens, roles `client | partner | admin`. Default admin: `admin@petly.local` / `changeme-admin` (override with `ADMIN_EMAIL` / `ADMIN_PASSWORD`).
- **Partner onboarding (Phase 2)** — register as partner or upgrade from Profile; submit clinics/stores for review; public Explore only shows `approved` listings. Demo partner: `partner@petly.local` / `changeme-partner`. Admin review is API-only (`/admin/...`).
- **Store items** — partners can catalog products on a store; Home shows a few in-stock items from the nearest store, and the store page lists the full catalog. No cart or checkout yet.
- **Google Sign-In** — `POST /auth/oauth` verifies a Google ID token, links or creates a Petly user (same JWT session as email/password), and can upgrade a guest via `device_id`. Requires `GOOGLE_CLIENT_IDS` on the API and `--dart-define=GOOGLE_WEB_CLIENT_ID=...` in the app.
- **Offline / error UX** — top offline banner, shared `AsyncErrorView`, clearer Dio error messages.

### New API endpoints

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/analytics/whatsapp-clicks` | Track WhatsApp tap (`entity_type`, `entity_id`, `user_id`, `device_id`, `source`) |
| `GET` | `/analytics/whatsapp-clicks/stats` | Click totals + recent events |
| `GET` | `/users/by-device/:deviceId` | Lookup device-bound user |

## Roadmap

See [docs/IMPLEMENTATION_PLAN.md](docs/IMPLEMENTATION_PLAN.md) for the detailed, phased implementation plan (admin dashboard, auth/RBAC, chat, bookings, UI/UX polish, and more).

0. **Foundations (done)** — migrations, validation, security, tokens, CI  
1. **Auth + RBAC (done)** — JWT, roles, login/register, guest linking  
1.5. **Validation readiness (done)** — GPS, click analytics, device user, offline UX  
2. **Partner onboarding** — approval workflow, partner dashboard ([plan](docs/PHASE_2_PLAN.md))  
3. **Platform core** — appointment requests, Firebase push, vet dashboard  
4. **Marketplace** — products, cart, orders  
5. **Scale** — in-app chat, bookings, payments, delivery  

