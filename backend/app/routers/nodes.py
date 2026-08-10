from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db import get_db
from app.repositories import NodeRepository
from app.schemas import NodeCreate, NodeOut

router = APIRouter(prefix="/nodes", tags=["nodes"])


@router.get("", response_model=List[NodeOut])
def list_nodes(db: Session = Depends(get_db)):
    return NodeRepository(db).list()


@router.post("", response_model=NodeOut, status_code=201)
def create_node(payload: NodeCreate, db: Session = Depends(get_db)):
    return NodeRepository(db).create(**payload.model_dump())


@router.get("/{node_id}", response_model=NodeOut)
def get_node(node_id: int, db: Session = Depends(get_db)):
    node = NodeRepository(db).get(node_id)
    if node is None:
        raise HTTPException(status_code=404, detail="Node not found")
    return node


@router.delete("/{node_id}", status_code=204)
def delete_node(node_id: int, db: Session = Depends(get_db)):
    repo = NodeRepository(db)
    node = repo.get(node_id)
    if node is None:
        raise HTTPException(status_code=404, detail="Node not found")
    repo.delete(node)
