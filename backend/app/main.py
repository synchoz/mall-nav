from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import beacons, edges, floors, nodes, pathfinding, positioning

app = FastAPI(title="Mall Navigation API")

# All endpoints are public/read-no-auth, so a wildcard origin is fine here.
# The Flutter web build (GitHub Pages) and local dev servers both need this
# to call the API cross-origin from the browser.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(floors.router)
app.include_router(beacons.router)
app.include_router(nodes.router)
app.include_router(edges.router)
app.include_router(pathfinding.router)
app.include_router(positioning.router)


@app.get("/health")
def health():
    return {"status": "ok"}
