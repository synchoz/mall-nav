import '../models/edge.dart';
import '../models/floor.dart';
import '../models/node.dart';
import '../models/route_step.dart';
import '../services/api_client.dart';

/// Abstraction over the mall-nav backend. Screens depend on this interface,
/// not on ApiClient directly, so a fake/mock implementation can stand in
/// during widget tests without a live backend.
abstract class MallNavRepository {
  Future<bool> checkHealth();

  Future<List<Floor>> getFloors();
  Future<Floor> createFloor({required String name, required int levelIndex});

  Future<List<MapNode>> getNodes();
  Future<MapNode> createNode({
    required int floorId,
    required double x,
    required double y,
    String? label,
  });

  Future<List<MapEdge>> getEdges();
  Future<MapEdge> createEdge({
    required int nodeAId,
    required int nodeBId,
    double weight,
    String edgeType,
  });

  Future<NavigationRoute> findRoute({required int startNodeId, required int endNodeId});
}

class ApiMallNavRepository implements MallNavRepository {
  final ApiClient _client;

  ApiMallNavRepository(this._client);

  @override
  Future<bool> checkHealth() async {
    final result = await _client.get('/health');
    return result is Map && result['status'] == 'ok';
  }

  @override
  Future<List<Floor>> getFloors() async {
    final result = await _client.get('/floors') as List;
    return result.map((json) => Floor.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Floor> createFloor({required String name, required int levelIndex}) async {
    final result = await _client.post('/floors', {'name': name, 'level_index': levelIndex});
    return Floor.fromJson(result as Map<String, dynamic>);
  }

  @override
  Future<List<MapNode>> getNodes() async {
    final result = await _client.get('/nodes') as List;
    return result.map((json) => MapNode.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<MapNode> createNode({
    required int floorId,
    required double x,
    required double y,
    String? label,
  }) async {
    final result = await _client.post('/nodes', {
      'floor_id': floorId,
      'x': x,
      'y': y,
      'label': label,
    });
    return MapNode.fromJson(result as Map<String, dynamic>);
  }

  @override
  Future<List<MapEdge>> getEdges() async {
    final result = await _client.get('/edges') as List;
    return result.map((json) => MapEdge.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<MapEdge> createEdge({
    required int nodeAId,
    required int nodeBId,
    double weight = 1.0,
    String edgeType = 'walk',
  }) async {
    final result = await _client.post('/edges', {
      'node_a_id': nodeAId,
      'node_b_id': nodeBId,
      'weight': weight,
      'edge_type': edgeType,
    });
    return MapEdge.fromJson(result as Map<String, dynamic>);
  }

  @override
  Future<NavigationRoute> findRoute({required int startNodeId, required int endNodeId}) async {
    final result = await _client.post('/pathfinding/route', {
      'start_node_id': startNodeId,
      'end_node_id': endNodeId,
    });
    return NavigationRoute.fromJson(result as Map<String, dynamic>);
  }
}
