import '../models/floor.dart';
import '../models/route_step.dart';
import '../services/api_client.dart';

/// Abstraction over the mall-nav backend. Screens depend on this interface,
/// not on ApiClient directly, so a fake/mock implementation can stand in
/// during widget tests without a live backend.
abstract class MallNavRepository {
  Future<bool> checkHealth();
  Future<List<Floor>> getFloors();
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
  Future<NavigationRoute> findRoute({required int startNodeId, required int endNodeId}) async {
    final result = await _client.post('/pathfinding/route', {
      'start_node_id': startNodeId,
      'end_node_id': endNodeId,
    });
    return NavigationRoute.fromJson(result as Map<String, dynamic>);
  }
}
