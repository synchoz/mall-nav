from typing import List, Optional

from pydantic import BaseModel, ConfigDict


class FloorBase(BaseModel):
    name: str
    level_index: int


class FloorCreate(FloorBase):
    pass


class FloorOut(FloorBase):
    model_config = ConfigDict(from_attributes=True)
    id: int


class BeaconBase(BaseModel):
    floor_id: int
    uuid: str
    major: int
    minor: int
    x: float
    y: float


class BeaconCreate(BeaconBase):
    pass


class BeaconOut(BeaconBase):
    model_config = ConfigDict(from_attributes=True)
    id: int


class NodeBase(BaseModel):
    floor_id: int
    x: float
    y: float
    label: Optional[str] = None


class NodeCreate(NodeBase):
    pass


class NodeOut(NodeBase):
    model_config = ConfigDict(from_attributes=True)
    id: int


class EdgeBase(BaseModel):
    node_a_id: int
    node_b_id: int
    weight: float = 1.0
    edge_type: str = "walk"


class EdgeCreate(EdgeBase):
    pass


class EdgeOut(EdgeBase):
    model_config = ConfigDict(from_attributes=True)
    id: int


class RouteRequest(BaseModel):
    start_node_id: int
    end_node_id: int


class RouteStep(BaseModel):
    node_id: int
    floor_id: int
    x: float
    y: float
    label: Optional[str] = None


class RouteResponse(BaseModel):
    steps: List[RouteStep]
    total_weight: float


class BeaconReading(BaseModel):
    beacon_id: int
    rssi: float


class PositionRequest(BaseModel):
    readings: List[BeaconReading]


class PositionEstimate(BaseModel):
    floor_id: int
    x: float
    y: float
    confidence: float
