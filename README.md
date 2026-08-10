# Mall Navigation App — quickstart

## 0. Prereqs
- Python 3.11+
- Docker Desktop
- Flutter SDK (Android SDK / Visual Studio C++ workload only needed for
  native Android / Windows-desktop builds — web/Chrome works without them)
- Git, GitHub CLI (`gh`)

## 1. Get the code onto GitHub
```bash
cd mall-nav
git init
git add .
git commit -m "Initial scaffold: backend + mobile app, docker-compose, render.yaml"
gh auth login              # first time only
gh repo create mall-nav --private --source=. --remote=origin --push
# or manually: create repo on github.com, then
# git remote add origin <your-repo-url>
# git push -u origin main
```

## 2. Run Postgres locally
```bash
docker compose up -d
```

## 3. Run the backend
```bash
cd backend
python -m venv .venv
source .venv/Scripts/activate    # Windows Git Bash; use .venv\Scripts\Activate.ps1 in PowerShell
pip install -r requirements.txt
cp .env.example .env
alembic upgrade head             # applies the existing migration (floors/beacons/nodes/edges)
uvicorn app.main:app --reload
```
Visit http://localhost:8000/health — should return `{"status":"ok"}`.
Interactive API docs: http://localhost:8000/docs

Endpoints: `/floors`, `/beacons`, `/nodes`, `/edges` (CRUD), plus
`POST /pathfinding/route` and `POST /positioning/estimate`.

## 4. Run backend tests
```bash
pytest
```
15 tests: unit tests for the pathfinding/positioning strategies (pure
logic, no DB) and integration tests for the routers (in-memory SQLite via
`tests/conftest.py`, so no live Postgres needed to run tests or in CI).

## 5. Migrations after model changes
```bash
alembic revision --autogenerate -m "describe the change"
alembic upgrade head
```

## 6. Deploy backend to Render
- Push the repo to GitHub (step 1).
- In the Render dashboard: New > Blueprint, point it at your repo.
  It reads `render.yaml` and creates the web service + Postgres together.
- Every push to `main` auto-deploys.

## 7. Run the Flutter app
```bash
cd mobile
flutter pub get
flutter run -d chrome     # or windows/macos/linux/android once those
                           # toolchains are installed
```
The app talks to `http://localhost:8000` by default (see
`lib/services/app_config.dart`). Point it elsewhere with:
```bash
flutter run -d chrome --dart-define=API_BASE_URL=https://your-backend.onrender.com
```
Add BLE scanning later with:
```bash
flutter pub add flutter_blue_plus
```

## 8. Start Claude Code on this repo
```bash
cd mall-nav
claude
```
Claude Code will pick up `CLAUDE.md` automatically for project context.

## Repo layout
```
mall-nav/
├── CLAUDE.md
├── render.yaml
├── docker-compose.yml
├── backend/
│   ├── alembic/                # migrations
│   ├── app/
│   │   ├── main.py
│   │   ├── db.py
│   │   ├── models.py
│   │   ├── schemas.py          # Pydantic request/response models
│   │   ├── repositories/       # Repository pattern: DB access per model
│   │   ├── services/           # Strategy pattern: pathfinding, positioning
│   │   └── routers/            # FastAPI route handlers
│   ├── tests/
│   ├── requirements.txt
│   └── .env.example
├── mobile/                     # Flutter app
│   ├── lib/
│   │   ├── models/
│   │   ├── services/           # ApiClient, AppConfig
│   │   ├── repositories/       # MallNavRepository interface + impl
│   │   ├── screens/
│   │   └── main.dart
│   └── test/
└── .github/workflows/
    ├── backend-test.yml
    └── mobile-test.yml
```
