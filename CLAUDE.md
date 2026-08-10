# Mall Navigation App

## What this is
Indoor mall navigation (no GPS) using WiFi/BLE signal positioning and
per-floor pathfinding. Python backend, Flutter frontend (Android primary
target, iOS/desktop are build targets from the same codebase).

## Architecture
- backend/  — FastAPI + Postgres, positioning + pathfinding API
- mobile/   — Flutter app (not yet scaffolded — run `flutter create mobile`
  from repo root, see README.md)
- Desktop build of mobile/ is used to test the UI without real BLE/WiFi
  hardware, using mocked scan data.

## Backend
- Framework: FastAPI, SQLAlchemy, Alembic for migrations
- DB: Postgres (Render managed instance in prod, Docker Compose locally)
- Run locally: `cd backend && uvicorn app.main:app --reload`
- Migrations: `alembic revision --autogenerate -m "message"`, then
  `alembic upgrade head`
- Env vars: DATABASE_URL (see backend/.env.example)
- Health check: GET /health

## Mobile (once scaffolded)
- Framework: Flutter
- BLE plugin: flutter_blue_plus (add when scanning work starts)
- Run desktop (for testing without real scans): `flutter run -d macos`
  (or windows/linux)
- Run Android: `flutter run -d <device>`

## Data model (backend/app/models.py)
- floors: id, name, level_index
- beacons: id, floor_id, uuid, major, minor, x, y
- nodes: id, floor_id, x, y, label (walkable graph point)
- edges: id, node_a_id, node_b_id, weight, edge_type
  (walk / stairs / elevator — stairs/elevator edges connect nodes on
  different floors)

## Deployment
- Render auto-deploys the backend on push to main. Infra defined in
  render.yaml (web service + Postgres).
- GitHub Actions runs backend tests on every push/PR
  (.github/workflows/backend-test.yml).

## Conventions
- Backend code lives entirely under backend/app/
- Add new endpoints as routers under backend/app/routers/, included in main.py
- Keep positioning logic (positioning.py) and pathfinding logic
  (pathfinding.py) separate from route handlers

## Current status
- Backend: models, Alembic migrations (initial migration applied locally),
  CRUD routers for floors/beacons/nodes/edges, and pathfinding/positioning
  endpoints are implemented. Data access goes through a Repository layer
  (backend/app/repositories/), and pathfinding/positioning logic is built
  as swappable Strategy implementations (backend/app/services/) — Dijkstra
  for routing, nearest-beacon for positioning. 15 backend tests passing
  (unit tests for strategies + integration tests for routers, run against
  in-memory SQLite so CI needs no live DB).
- Mobile: Flutter app scaffolded in mobile/ with a layered structure
  (models/, services/ for the HTTP client + config, repositories/ for an
  interface + API-backed implementation, screens/). Home screen shows
  live backend connectivity + floor list. Widget test uses a fake
  repository. Runs on web (Chrome) today; Android/Windows-desktop builds
  need the Android SDK / Visual Studio C++ workload installed locally.
- Not yet deployed to Render; GitHub repo not yet created.

## Next milestone
- Push to GitHub, connect Render (backend + Postgres via render.yaml),
  confirm CI is green, then start on BLE/WiFi scanning
  (flutter_blue_plus) to feed the positioning endpoint real readings.
