from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import List

from sqlalchemy.orm import Session

from app.models import Beacon
from app.repositories import BeaconRepository
from app.schemas import BeaconReading


@dataclass
class Position:
    floor_id: int
    x: float
    y: float
    confidence: float


class PositioningStrategy(ABC):
    """Algorithm for turning a set of BLE/WiFi beacon readings into a position."""

    @abstractmethod
    def estimate(self, readings: List[BeaconReading], beacons: List[Beacon]) -> Position:
        raise NotImplementedError


class NearestBeaconStrategy(PositioningStrategy):
    """Estimates position as the location of the strongest-signal beacon.

    A simple, dependency-free baseline; swap in a trilateration or
    fingerprinting strategy later without touching PositioningService or
    its callers.
    """

    def estimate(self, readings: List[BeaconReading], beacons: List[Beacon]) -> Position:
        if not readings:
            raise ValueError("At least one beacon reading is required")

        beacons_by_id = {beacon.id: beacon for beacon in beacons}
        known_readings = [r for r in readings if r.beacon_id in beacons_by_id]
        if not known_readings:
            raise ValueError("None of the reported beacon ids are registered")

        strongest = max(known_readings, key=lambda r: r.rssi)
        beacon = beacons_by_id[strongest.beacon_id]

        second_strongest_rssi = max(
            (r.rssi for r in known_readings if r.beacon_id != strongest.beacon_id),
            default=strongest.rssi - 20,
        )
        margin = max(strongest.rssi - second_strongest_rssi, 0.0)
        confidence = min(1.0, 0.5 + margin / 40.0)

        return Position(floor_id=beacon.floor_id, x=beacon.x, y=beacon.y, confidence=confidence)


class PositioningService:
    """Orchestrates the beacon repository and a pluggable PositioningStrategy."""

    def __init__(self, db: Session, strategy: PositioningStrategy | None = None):
        self.beacon_repo = BeaconRepository(db)
        self.strategy = strategy or NearestBeaconStrategy()

    def estimate_position(self, readings: List[BeaconReading]) -> Position:
        beacon_ids = [r.beacon_id for r in readings]
        beacons = self.beacon_repo.list_by_ids(beacon_ids)
        return self.strategy.estimate(readings, beacons)
