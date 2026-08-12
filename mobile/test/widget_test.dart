import 'package:flutter_test/flutter_test.dart';

import 'package:mall_nav/main.dart';
import 'package:mall_nav/models/edge.dart';
import 'package:mall_nav/models/floor.dart';
import 'package:mall_nav/models/node.dart';
import 'package:mall_nav/models/route_step.dart';
import 'package:mall_nav/repositories/mall_nav_repository.dart';

/// Fake implementation of the repository interface, standing in for a real
/// backend so this widget test doesn't need a running server.
class FakeMallNavRepository implements MallNavRepository {
  @override
  Future<bool> checkHealth() async => true;

  @override
  Future<List<Floor>> getFloors() async => [
        const Floor(id: 1, name: 'Ground Floor', levelIndex: 0),
      ];

  @override
  Future<Floor> createFloor({required String name, required int levelIndex}) async {
    return Floor(id: 2, name: name, levelIndex: levelIndex);
  }

  @override
  Future<List<MapNode>> getNodes() async => [];

  @override
  Future<MapNode> createNode({
    required int floorId,
    required double x,
    required double y,
    String? label,
  }) async {
    return MapNode(id: 1, floorId: floorId, x: x, y: y, label: label);
  }

  @override
  Future<List<MapEdge>> getEdges() async => [];

  @override
  Future<MapEdge> createEdge({
    required int nodeAId,
    required int nodeBId,
    double weight = 1.0,
    String edgeType = 'walk',
  }) async {
    return MapEdge(id: 1, nodeAId: nodeAId, nodeBId: nodeBId, weight: weight, edgeType: edgeType);
  }

  @override
  Future<NavigationRoute> findRoute({required int startNodeId, required int endNodeId}) async {
    return const NavigationRoute(steps: [], totalWeight: 0);
  }
}

void main() {
  testWidgets('shows backend status and floor list', (WidgetTester tester) async {
    await tester.pumpWidget(MallNavApp(repository: FakeMallNavRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Backend connected'), findsOneWidget);
    expect(find.text('Ground Floor'), findsOneWidget);
  });
}
