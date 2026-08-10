from app.models import Edge
from app.repositories.base import Repository


class EdgeRepository(Repository[Edge]):
    model = Edge
