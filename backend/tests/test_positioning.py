import pytest

from app.models import Beacon
from app.schemas import BeaconReading
from app.services.positioning import NearestBeaconStrategy


def make_beacon(id, floor_id=1, x=0.0, y=0.0):
    return Beacon(id=id, floor_id=floor_id, uuid="u", major=1, minor=id, x=x, y=y)


def test_estimates_position_at_strongest_beacon():
    beacons = [make_beacon(1, x=0, y=0), make_beacon(2, x=10, y=10)]
    readings = [
        BeaconReading(beacon_id=1, rssi=-70),
        BeaconReading(beacon_id=2, rssi=-40),
    ]

    position = NearestBeaconStrategy().estimate(readings, beacons)

    assert (position.x, position.y) == (10, 10)
    assert 0.5 <= position.confidence <= 1.0


def test_higher_signal_margin_increases_confidence():
    beacons = [make_beacon(1), make_beacon(2)]
    strategy = NearestBeaconStrategy()

    close_call = strategy.estimate(
        [BeaconReading(beacon_id=1, rssi=-50), BeaconReading(beacon_id=2, rssi=-49)],
        beacons,
    )
    clear_win = strategy.estimate(
        [BeaconReading(beacon_id=1, rssi=-50), BeaconReading(beacon_id=2, rssi=-90)],
        beacons,
    )

    assert clear_win.confidence > close_call.confidence


def test_raises_on_empty_readings():
    with pytest.raises(ValueError):
        NearestBeaconStrategy().estimate([], [])


def test_raises_when_no_readings_match_known_beacons():
    beacons = [make_beacon(1)]
    readings = [BeaconReading(beacon_id=999, rssi=-50)]

    with pytest.raises(ValueError):
        NearestBeaconStrategy().estimate(readings, beacons)
