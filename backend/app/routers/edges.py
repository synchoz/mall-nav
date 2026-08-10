from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db import get_db
from app.repositories import EdgeRepository
from app.schemas import EdgeCreate, EdgeOut

router = APIRouter(prefix="/edges", tags=["edges"])


@router.get("", response_model=List[EdgeOut])
def list_edges(db: Session = Depends(get_db)):
    return EdgeRepository(db).list()


@router.post("", response_model=EdgeOut, status_code=201)
def create_edge(payload: EdgeCreate, db: Session = Depends(get_db)):
    return EdgeRepository(db).create(**payload.model_dump())


@router.get("/{edge_id}", response_model=EdgeOut)
def get_edge(edge_id: int, db: Session = Depends(get_db)):
    edge = EdgeRepository(db).get(edge_id)
    if edge is None:
        raise HTTPException(status_code=404, detail="Edge not found")
    return edge


@router.delete("/{edge_id}", status_code=204)
def delete_edge(edge_id: int, db: Session = Depends(get_db)):
    repo = EdgeRepository(db)
    edge = repo.get(edge_id)
    if edge is None:
        raise HTTPException(status_code=404, detail="Edge not found")
    repo.delete(edge)
