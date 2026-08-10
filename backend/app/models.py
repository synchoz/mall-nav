from sqlalchemy import Column, Float, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from app.db import Base


class Floor(Base):
    __tablename__ = "floors"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    level_index = Column(Integer, nullable=False)  # 0 = ground, 1 = first, etc.

    beacons = relationship("Beacon", back_populates="floor")
    nodes = relationship("Node", back_populates="floor")


class Beacon(Base):
    __tablename__ = "beacons"

    id = Column(Integer, primary_key=True)
    floor_id = Column(Integer, ForeignKey("floors.id"), nullable=False)
    uuid = Column(String, nullable=False)
    major = Column(Integer, nullable=False)
    minor = Column(Integer, nullable=False)
    x = Column(Float, nullable=False)
    y = Column(Float, nullable=False)

    floor = relationship("Floor", back_populates="beacons")


class Node(Base):
    __tablename__ = "nodes"

    id = Column(Integer, primary_key=True)
    floor_id = Column(Integer, ForeignKey("floors.id"), nullable=False)
    x = Column(Float, nullable=False)
    y = Column(Float, nullable=False)
    label = Column(String, nullable=True)  # e.g. "Store: Zara", "Elevator A"

    floor = relationship("Floor", back_populates="nodes")


class Edge(Base):
    __tablename__ = "edges"

    id = Column(Integer, primary_key=True)
    node_a_id = Column(Integer, ForeignKey("nodes.id"), nullable=False)
    node_b_id = Column(Integer, ForeignKey("nodes.id"), nullable=False)
    weight = Column(Float, nullable=False, default=1.0)
    edge_type = Column(String, nullable=False, default="walk")  # walk, stairs, elevator
