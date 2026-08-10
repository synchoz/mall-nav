from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db import get_db
from app.schemas import PositionEstimate, PositionRequest
from app.services import PositioningService

router = APIRouter(prefix="/positioning", tags=["positioning"])


@router.post("/estimate", response_model=PositionEstimate)
def estimate_position(payload: PositionRequest, db: Session = Depends(get_db)):
    service = PositioningService(db)
    try:
        position = service.estimate_position(payload.readings)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    return PositionEstimate(
        floor_id=position.floor_id,
        x=position.x,
        y=position.y,
        confidence=position.confidence,
    )
