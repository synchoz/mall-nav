import 'package:flutter_test/flutter_test.dart';

import 'package:mall_nav/main.dart';
import 'package:mall_nav/models/floor.dart';
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
