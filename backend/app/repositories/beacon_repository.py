from typing import List

from app.models import Beacon
from app.repositories.base import Repository


class BeaconRepository(Repository[Beacon]):
    model = Beacon

    def list_by_ids(self, ids: List[int]) -> List[Beacon]:
        if not ids:
            return []
        return self.db.query(Beacon).filter(Beacon.id.in_(ids)).all()
