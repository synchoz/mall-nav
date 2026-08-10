import pytest

from app.models import Edge, Node
from app.services.pathfinding import DijkstraPathfinder, PathNotFoundError


def make_node(id, floor_id=1, x=0.0, y=0.0, label=None):
    return Node(id=id, floor_id=floor_id, x=x, y=y, label=label)


def make_edge(id, node_a_id, node_b_id, weight=1.0, edge_type="walk"):
    return Edge(id=id, node_a_id=node_a_id, node_b_id=node_b_id, weight=weight, edge_type=edge_type)


def test_finds_direct_path():
    nodes = [make_node(1), make_node(2)]
    edges = [make_edge(1, 1, 2, weight=5)]

    route = DijkstraPathfinder().find_path(nodes, edges, start_id=1, end_id=2)

    assert [n.id for n in route.nodes] == [1, 2]
    assert route.total_weight == 5


def test_picks_shortest_of_multiple_paths():
    # 1 -> 2 -> 3 costs 2, 1 -> 3 direct costs 10
    nodes = [make_node(1), make_node(2), make_node(3)]
    edges = [
        make_edge(1, 1, 2, weight=1),
        make_edge(2, 2, 3, weight=1),
        make_edge(3, 1, 3, weight=10),
    ]

    route = DijkstraPathfinder().find_path(nodes, edges, start_id=1, end_id=3)

    assert [n.id for n in route.nodes] == [1, 2, 3]
    assert route.total_weight == 2


def test_crosses_floors_via_stairs_edge():
    floor_1_node = make_node(1, floor_id=1)
    floor_2_node = make_node(2, floor_id=2)
    stairs = make_edge(1, 1, 2, weight=3, edge_type="stairs")

    route = DijkstraPathfinder().find_path(
        [floor_1_node, floor_2_node], [stairs], start_id=1, end_id=2
    )

    assert [n.floor_id for n in route.nodes] == [1, 2]


def test_raises_when_no_path_exists():
    nodes = [make_node(1), make_node(2)]
    edges = []  # disconnected

    with pytest.raises(PathNotFoundError):
        DijkstraPathfinder().find_path(nodes, edges, start_id=1, end_id=2)


def test_raises_for_unknown_node_id():
    nodes = [make_node(1)]
    edges = []

    with pytest.raises(PathNotFoundError):
        DijkstraPathfinder().find_path(nodes, edges, start_id=1, end_id=999)
