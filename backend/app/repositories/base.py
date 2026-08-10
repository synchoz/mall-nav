from typing import Generic, List, Optional, Type, TypeVar

from sqlalchemy.orm import Session

ModelType = TypeVar("ModelType")


class Repository(Generic[ModelType]):
    """Generic CRUD data-access layer over a single SQLAlchemy model.

    Concrete repositories subclass this and set `model`, keeping route
    handlers and services free of raw session/query calls.
    """

    model: Type[ModelType]

    def __init__(self, db: Session):
        self.db = db

    def get(self, id: int) -> Optional[ModelType]:
        return self.db.get(self.model, id)

    def list(self) -> List[ModelType]:
        return self.db.query(self.model).all()

    def create(self, **fields) -> ModelType:
        obj = self.model(**fields)
        self.db.add(obj)
        self.db.commit()
        self.db.refresh(obj)
        return obj

    def update(self, obj: ModelType, **fields) -> ModelType:
        for key, value in fields.items():
            setattr(obj, key, value)
        self.db.commit()
        self.db.refresh(obj)
        return obj

    def delete(self, obj: ModelType) -> None:
        self.db.delete(obj)
        self.db.commit()
