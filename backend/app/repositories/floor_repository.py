from app.models import Floor
from app.repositories.base import Repository


class FloorRepository(Repository[Floor]):
    model = Floor
