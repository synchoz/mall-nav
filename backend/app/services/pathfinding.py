import heapq
from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Dict, List

from sqlalchemy.orm import Session

from app.models import Edge, Node
from app.repositories import EdgeRepository, NodeRepository


class PathNotFoundError(Exception):
    """Raised when no walkable route exists between two nodes."""


@dataclass
class Route:
    nodes: List[Node]
    total_weight: float


class PathfindingStrategy(ABC):
    """Algorithm for finding the shortest route through the node/edge graph.

    Edges may cross floors (stairs/elevator edge_type), so a route can span
    multiple floors transparently.
    """

    @abstractmethod
    def find_path(self, nodes: List[Node], edges: List[Edge], start_id: int, end_id: int) -> Route:
        raise NotImplementedError


class DijkstraPathfinder(PathfindingStrategy):
    """Shortest-path strategy using edge weight as walking cost."""

    def find_path(self, nodes: List[Node], edges: List[Edge], start_id: int, end_id: int) -> Route:
        nodes_by_id: Dict[int, Node] = {node.id: node for node in nodes}
        if start_id not in nodes_by_id or end_id not in nodes_by_id:
            raise PathNotFoundError(f"Unknown node id: {start_id} or {end_id}")

        adjacency: Dict[int, List[tuple]] = {node_id: [] for node_id in nodes_by_id}
        for edge in edges:
            adjacency[edge.node_a_id].append((edge.node_b_id, edge.weight))
            adjacency[edge.node_b_id].append((edge.node_a_id, edge.weight))

        distances: Dict[int, float] = {node_id: float("inf") for node_id in nodes_by_id}
        previous: Dict[int, int] = {}
        distances[start_id] = 0.0
        frontier = [(0.0, start_id)]
        visited = set()

        while frontier:
            dist, current = heapq.heappop(frontier)
            if current in visited:
                continue
            visited.add(current)
            if current == end_id:
                break

            for neighbor_id, weight in adjacency[current]:
                candidate = dist + weight
                if candidate < distances[neighbor_id]:
                    distances[neighbor_id] = candidate
                    previous[neighbor_id] = current
                    heapq.heappush(frontier, (candidate, neighbor_id))

        if distances[end_id] == float("inf"):
            raise PathNotFoundError(f"No route between node {start_id} and node {end_id}")

        path_ids = [end_id]
        while path_ids[-1] != start_id:
            path_ids.append(previous[path_ids[-1]])
        path_ids.reverse()

        return Route(
            nodes=[nodes_by_id[node_id] for node_id in path_ids],
            total_weight=distances[end_id],
        )


class PathfindingService:
    """Orchestrates repositories and a pluggable PathfindingStrategy."""

    def __init__(self, db: Session, strategy: PathfindingStrategy | None = None):
        self.node_repo = NodeRepository(db)
        self.edge_repo = EdgeRepository(db)
        self.strategy = strategy or DijkstraPathfinder()

    def find_route(self, start_node_id: int, end_node_id: int) -> Route:
        nodes = self.node_repo.list()
        edges = self.edge_repo.list()
        return self.strategy.find_path(nodes, edges, start_node_id, end_node_id)
