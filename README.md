# Petly (Pawly)

Pet services platform for Lebanon — connect pet owners with veterinary clinics and pet stores. Phase 1 MVP uses WhatsApp deep links instead of in-app chat or booking.

## Stack

| Layer | Tech |
|-------|------|
| Mobile | Flutter 3 + Riverpod + GoRouter + Dio |
| API | Node.js + Express + TypeScript |
| Database | PostgreSQL 16 (with in-memory fallback for local demos) |

## Quick start

### 1. Backend

```bash
cd backend
cp .env.example .env
npm install
```

**With PostgreSQL (recommended):**

```bash
# from repo root — requires Docker Desktop
docker compose up -d
cd backend
npm run db:seed
npm run dev
```

**Without Docker:** the API auto-falls back to an in-memory store with Lebanon seed data:

```bash
cd backend
npm run dev
```

API: `http://localhost:3000`  
Health: `GET /health`

### 2. Flutter app

```bash
cd mobile
flutter pub get
```

**Android emulator** (default API URL `http://10.0.2.2:3000`):

```bash
flutter run
```

**iOS simulator / Windows desktop** (host loopback):

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

**Physical device** (replace with your machine LAN IP):

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:3000
```

## API endpoints (Phase 1)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | Health check |
| `GET` | `/vets` | List vets (`search`, `open_now`, `emergency`, `lat`, `lng`, `max_distance_km`) |
| `GET` | `/vets/emergency` | Open emergency clinics |
| `GET` | `/vets/:id` | Vet details |
| `GET` | `/stores` | List stores |
| `GET` | `/stores/:id` | Store details |
| `POST` | `/users` | Create / upsert user |
| `GET` | `/users/:id` | Get user |
| `POST` | `/pets` | Add pet |
| `GET` | `/pets?user_id=` | List pets for user |
| `PATCH` | `/pets/:id` | Update pet |
| `DELETE` | `/pets/:id` | Delete pet |

## App structure

```
mobile/lib/
  core/           # theme, constants, providers, widgets, WhatsApp util
  data/           # models, Dio client, repositories
  features/       # home, explore, vets, stores, pets, profile
  routes/         # GoRouter + bottom nav shell
backend/src/
  modules/        # users, pets, vets, stores
  db/             # pool, migrate, seed, memory fallback
```

## Design system

- Primary `#2EC4B6` · Secondary `#FF9F1C` · Background `#F7F9FB` · Text `#1A1A1A`
- Poppins (Google Fonts), 14–16px rounded corners, soft shadows

## Phase 1.5 additions

- **GPS location** — requests when-in-use permission; falls back to Beirut if denied/unavailable. Tap the home location row to refresh.
- **WhatsApp click analytics** — `POST /analytics/whatsapp-clicks` (fire-and-forget from the app). Stats: `GET /analytics/whatsapp-clicks/stats`.
- **Device-bound user** — UUID stored in `shared_preferences`, upserted via `POST /users` with `device_id`. Pets stay tied to that user across launches.
- **Offline / error UX** — top offline banner, shared `AsyncErrorView`, clearer Dio error messages.

### New API endpoints

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/analytics/whatsapp-clicks` | Track WhatsApp tap (`entity_type`, `entity_id`, `user_id`, `device_id`, `source`) |
| `GET` | `/analytics/whatsapp-clicks/stats` | Click totals + recent events |
| `GET` | `/users/by-device/:deviceId` | Lookup device-bound user |

## Roadmap

1. **MVP** — list vets/stores, details, WhatsApp, pets, profile  
1.5. **Validation readiness (done)** — GPS, click analytics, device user, offline UX  
2. **Validation** — partner onboarding workflow, featured listings admin  
3. **Platform core** — appointment requests, Firebase push, vet dashboard  
4. **Marketplace** — products, cart, orders  
5. **Scale** — in-app chat, payments, delivery  

