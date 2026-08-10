from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db import get_db
from app.repositories import FloorRepository
from app.schemas import FloorCreate, FloorOut

router = APIRouter(prefix="/floors", tags=["floors"])


@router.get("", response_model=List[FloorOut])
def list_floors(db: Session = Depends(get_db)):
    return FloorRepository(db).list()


@router.post("", response_model=FloorOut, status_code=201)
def create_floor(payload: FloorCreate, db: Session = Depends(get_db)):
    return FloorRepository(db).create(**payload.model_dump())


@router.get("/{floor_id}", response_model=FloorOut)
def get_floor(floor_id: int, db: Session = Depends(get_db)):
    floor = FloorRepository(db).get(floor_id)
    if floor is None:
        raise HTTPException(status_code=404, detail="Floor not found")
    return floor


@router.delete("/{floor_id}", status_code=204)
def delete_floor(floor_id: int, db: Session = Depends(get_db)):
    repo = FloorRepository(db)
    floor = repo.get(floor_id)
    if floor is None:
        raise HTTPException(status_code=404, detail="Floor not found")
    repo.delete(floor)
