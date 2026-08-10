def _create_floor(client):
    return client.post("/floors", json={"name": "Ground Floor", "level_index": 0}).json()["id"]


def _create_node(client, floor_id, x, y, label=None):
    return client.post(
        "/nodes", json={"floor_id": floor_id, "x": x, "y": y, "label": label}
    ).json()["id"]


def test_route_endpoint_returns_shortest_path(client):
    floor_id = _create_floor(client)
    n1 = _create_node(client, floor_id, 0, 0, "Entrance")
    n2 = _create_node(client, floor_id, 10, 0, "Food Court")
    client.post("/edges", json={"node_a_id": n1, "node_b_id": n2, "weight": 10, "edge_type": "walk"})

    response = client.post("/pathfinding/route", json={"start_node_id": n1, "end_node_id": n2})

    assert response.status_code == 200
    body = response.json()
    assert [step["node_id"] for step in body["steps"]] == [n1, n2]
    assert body["total_weight"] == 10


def test_route_endpoint_404s_when_unreachable(client):
    floor_id = _create_floor(client)
    n1 = _create_node(client, floor_id, 0, 0)
    n2 = _create_node(client, floor_id, 10, 0)
    # no edge between them

    response = client.post("/pathfinding/route", json={"start_node_id": n1, "end_node_id": n2})

    assert response.status_code == 404
