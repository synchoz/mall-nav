class MapNode {
  final int id;
  final int floorId;
  final double x;
  final double y;
  final String? label;

  const MapNode({
    required this.id,
    required this.floorId,
    required this.x,
    required this.y,
    this.label,
  });

  factory MapNode.fromJson(Map<String, dynamic> json) {
    return MapNode(
      id: json['id'] as int,
      floorId: json['floor_id'] as int,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      label: json['label'] as String?,
    );
  }

  String get displayName => label != null && label!.isNotEmpty ? label! : 'Node #$id';
}
