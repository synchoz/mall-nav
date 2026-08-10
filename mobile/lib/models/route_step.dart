class RouteStep {
  final int nodeId;
  final int floorId;
  final double x;
  final double y;
  final String? label;

  const RouteStep({
    required this.nodeId,
    required this.floorId,
    required this.x,
    required this.y,
    this.label,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      nodeId: json['node_id'] as int,
      floorId: json['floor_id'] as int,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      label: json['label'] as String?,
    );
  }
}

class NavigationRoute {
  final List<RouteStep> steps;
  final double totalWeight;

  const NavigationRoute({required this.steps, required this.totalWeight});

  factory NavigationRoute.fromJson(Map<String, dynamic> json) {
    return NavigationRoute(
      steps: (json['steps'] as List)
          .map((step) => RouteStep.fromJson(step as Map<String, dynamic>))
          .toList(),
      totalWeight: (json['total_weight'] as num).toDouble(),
    );
  }
}
