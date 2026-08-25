import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/edge.dart';
import '../models/node.dart';

/// Simple interactive floor map: nodes/edges plotted on an auto-scaled
/// canvas, pannable/zoomable, with tap-to-select and route highlighting.
///
/// v1 has no background image — it's just the graph. When floor-plan
/// images are added later, [_MapTransform] is the piece to reuse: it's
/// already isolated from drawing, so a background image can be painted
/// first using the same x/y -> canvas mapping.
class FloorMap extends StatelessWidget {
  final List<MapNode> nodes;
  final List<MapEdge> edges;
  final int? startNodeId;
  final int? endNodeId;
  final List<Offset> pathPoints;
  final ValueChanged<int>? onNodeTap;

  const FloorMap({
    super.key,
    required this.nodes,
    required this.edges,
    this.startNodeId,
    this.endNodeId,
    this.pathPoints = const [],
    this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return const Center(child: Text('No nodes on this floor yet.'));
    }

    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final transform = _MapTransform(nodes, size);
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Stack(
                children: [
                  CustomPaint(
                    size: size,
                    painter: _FloorMapPainter(
                      nodes: nodes,
                      edges: edges,
                      pathPoints: pathPoints,
                      transform: transform,
                    ),
                  ),
                  for (final node in nodes) _buildNodeMarker(node, transform),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNodeMarker(MapNode node, _MapTransform transform) {
    final pos = transform.toCanvas(node.x, node.y);
    const double diameter = 20;
    final Color color;
    if (node.id == startNodeId) {
      color = Colors.green;
    } else if (node.id == endNodeId) {
      color = Colors.redAccent;
    } else {
      color = Colors.blueGrey;
    }

    return Positioned(
      left: pos.dx - diameter / 2,
      top: pos.dy - diameter / 2,
      child: GestureDetector(
        onTap: onNodeTap == null ? null : () => onNodeTap!(node.id),
        child: Tooltip(
          message: node.displayName,
          child: Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}

/// Maps node data coordinates to canvas pixels, fitting all nodes with
/// padding regardless of the coordinate range they were authored in.
class _MapTransform {
  static const double _padding = 24;

  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final Size canvasSize;

  _MapTransform(List<MapNode> nodes, this.canvasSize)
      : minX = nodes.map((n) => n.x).reduce(math.min),
        maxX = nodes.map((n) => n.x).reduce(math.max),
        minY = nodes.map((n) => n.y).reduce(math.min),
        maxY = nodes.map((n) => n.y).reduce(math.max);

  Offset toCanvas(double x, double y) {
    final rangeX = (maxX - minX).abs() < 1e-6 ? 1.0 : maxX - minX;
    final rangeY = (maxY - minY).abs() < 1e-6 ? 1.0 : maxY - minY;
    final usableW = math.max(canvasSize.width - _padding * 2, 1.0);
    final usableH = math.max(canvasSize.height - _padding * 2, 1.0);
    return Offset(
      _padding + (x - minX) / rangeX * usableW,
      _padding + (y - minY) / rangeY * usableH,
    );
  }
}

class _FloorMapPainter extends CustomPainter {
  final List<MapNode> nodes;
  final List<MapEdge> edges;
  final List<Offset> pathPoints;
  final _MapTransform transform;

  _FloorMapPainter({
    required this.nodes,
    required this.edges,
    required this.pathPoints,
    required this.transform,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodeById = {for (final n in nodes) n.id: n};

    final edgePaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2;
    for (final edge in edges) {
      final a = nodeById[edge.nodeAId];
      final b = nodeById[edge.nodeBId];
      if (a == null || b == null) continue;
      canvas.drawLine(transform.toCanvas(a.x, a.y), transform.toCanvas(b.x, b.y), edgePaint);
    }

    if (pathPoints.length > 1) {
      final pathPaint = Paint()
        ..color = Colors.deepOrange
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < pathPoints.length - 1; i++) {
        canvas.drawLine(
          transform.toCanvas(pathPoints[i].dx, pathPoints[i].dy),
          transform.toCanvas(pathPoints[i + 1].dx, pathPoints[i + 1].dy),
          pathPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FloorMapPainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.edges != edges ||
        oldDelegate.pathPoints != pathPoints;
  }
}
