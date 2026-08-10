from fastapi import FastAPI

from app.routers import beacons, edges, floors, nodes, pathfinding, positioning

app = FastAPI(title="Mall Navigation API")

app.include_router(floors.router)
app.include_router(beacons.router)
app.include_router(nodes.router)
app.include_router(edges.router)
app.include_router(pathfinding.router)
app.include_router(positioning.router)


@app.get("/health")
def health():
    return {"status": "ok"}
