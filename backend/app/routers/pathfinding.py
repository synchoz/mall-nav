from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db import get_db
from app.schemas import RouteRequest, RouteResponse, RouteStep
from app.services import PathfindingService, PathNotFoundError

router = APIRouter(prefix="/pathfinding", tags=["pathfinding"])


@router.post("/route", response_model=RouteResponse)
def find_route(payload: RouteRequest, db: Session = Depends(get_db)):
    service = PathfindingService(db)
    try:
        route = service.find_route(payload.start_node_id, payload.end_node_id)
    except PathNotFoundError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc

    return RouteResponse(
        steps=[
            RouteStep(node_id=node.id, floor_id=node.floor_id, x=node.x, y=node.y, label=node.label)
            for node in route.nodes
        ],
        total_weight=route.total_weight,
    )
