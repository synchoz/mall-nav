from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db import get_db
from app.repositories import BeaconRepository
from app.schemas import BeaconCreate, BeaconOut

router = APIRouter(prefix="/beacons", tags=["beacons"])


@router.get("", response_model=List[BeaconOut])
def list_beacons(db: Session = Depends(get_db)):
    return BeaconRepository(db).list()


@router.post("", response_model=BeaconOut, status_code=201)
def create_beacon(payload: BeaconCreate, db: Session = Depends(get_db)):
    return BeaconRepository(db).create(**payload.model_dump())


@router.get("/{beacon_id}", response_model=BeaconOut)
def get_beacon(beacon_id: int, db: Session = Depends(get_db)):
    beacon = BeaconRepository(db).get(beacon_id)
    if beacon is None:
        raise HTTPException(status_code=404, detail="Beacon not found")
    return beacon


@router.delete("/{beacon_id}", status_code=204)
def delete_beacon(beacon_id: int, db: Session = Depends(get_db)):
    repo = BeaconRepository(db)
    beacon = repo.get(beacon_id)
    if beacon is None:
        raise HTTPException(status_code=404, detail="Beacon not found")
    repo.delete(beacon)
