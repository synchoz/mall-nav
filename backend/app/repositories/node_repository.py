from app.models import Node
from app.repositories.base import Repository


class NodeRepository(Repository[Node]):
    model = Node
