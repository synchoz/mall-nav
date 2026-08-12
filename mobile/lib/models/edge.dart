class MapEdge {
  final int id;
  final int nodeAId;
  final int nodeBId;
  final double weight;
  final String edgeType;

  const MapEdge({
    required this.id,
    required this.nodeAId,
    required this.nodeBId,
    required this.weight,
    required this.edgeType,
  });

  factory MapEdge.fromJson(Map<String, dynamic> json) {
    return MapEdge(
      id: json['id'] as int,
      nodeAId: json['node_a_id'] as int,
      nodeBId: json['node_b_id'] as int,
      weight: (json['weight'] as num).toDouble(),
      edgeType: json['edge_type'] as String,
    );
  }
}
