def test_create_and_list_floors(client):
    response = client.post("/floors", json={"name": "Ground Floor", "level_index": 0})
    assert response.status_code == 201
    created = response.json()
    assert created["name"] == "Ground Floor"

    response = client.get("/floors")
    assert response.status_code == 200
    assert [f["name"] for f in response.json()] == ["Ground Floor"]


def test_get_missing_floor_returns_404(client):
    response = client.get("/floors/999")
    assert response.status_code == 404


def test_delete_floor(client):
    created = client.post("/floors", json={"name": "Level 1", "level_index": 1}).json()

    response = client.delete(f"/floors/{created['id']}")
    assert response.status_code == 204

    assert client.get(f"/floors/{created['id']}").status_code == 404
