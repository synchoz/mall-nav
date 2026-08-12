import 'package:flutter/material.dart';

import '../models/node.dart';
import '../models/route_step.dart';
import '../repositories/mall_nav_repository.dart';
import '../services/api_client.dart';

class NavigateScreen extends StatefulWidget {
  final MallNavRepository repository;

  const NavigateScreen({super.key, required this.repository});

  @override
  State<NavigateScreen> createState() => _NavigateScreenState();
}

class _NavigateScreenState extends State<NavigateScreen> {
  List<MapNode> _nodes = [];
  int? _startNodeId;
  int? _endNodeId;
  NavigationRoute? _route;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadNodes();
  }

  Future<void> _loadNodes() async {
    setState(() => _loading = true);
    try {
      final nodes = await widget.repository.getNodes();
      setState(() {
        _nodes = nodes;
        _startNodeId = nodes.isNotEmpty ? nodes.first.id : null;
        _endNodeId = nodes.length > 1 ? nodes[1].id : null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _findRoute() async {
    if (_startNodeId == null || _endNodeId == null) return;
    setState(() {
      _loading = true;
      _error = null;
      _route = null;
    });
    try {
      final route = await widget.repository.findRoute(
        startNodeId: _startNodeId!,
        endNodeId: _endNodeId!,
      );
      setState(() => _route = route);
    } on ApiException catch (e) {
      setState(() => _error = e.statusCode == 404
          ? 'No route exists between those two points.'
          : e.toString());
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  String _nodeLabel(MapNode node) => '${node.displayName} (floor ${node.floorId})';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigate')),
      body: RefreshIndicator(
        onRefresh: _loadNodes,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_nodes.isEmpty && !_loading)
              const Text('No nodes yet — add some in the Admin tab first.'),
            if (_nodes.isNotEmpty) ...[
              DropdownButtonFormField<int>(
                initialValue: _startNodeId,
                decoration: const InputDecoration(labelText: 'Start'),
                items: _nodes
                    .map((n) => DropdownMenuItem(value: n.id, child: Text(_nodeLabel(n))))
                    .toList(),
                onChanged: (value) => setState(() => _startNodeId = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _endNodeId,
                decoration: const InputDecoration(labelText: 'Destination'),
                items: _nodes
                    .map((n) => DropdownMenuItem(value: n.id, child: Text(_nodeLabel(n))))
                    .toList(),
                onChanged: (value) => setState(() => _endNodeId = value),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loading ? null : _findRoute,
                icon: const Icon(Icons.directions),
                label: const Text('Find route'),
              ),
            ],
            if (_loading) const Padding(padding: EdgeInsets.only(top: 16), child: LinearProgressIndicator()),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_route != null) ...[
              const SizedBox(height: 24),
              Text('Route (total distance: ${_route!.totalWeight})',
                  style: Theme.of(context).textTheme.titleMedium),
              for (var i = 0; i < _route!.steps.length; i++) ...[
                ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(_route!.steps[i].label ?? 'Node #${_route!.steps[i].nodeId}'),
                  subtitle: Text(
                      'Floor ${_route!.steps[i].floorId} · (${_route!.steps[i].x}, ${_route!.steps[i].y})'),
                ),
                if (i < _route!.steps.length - 1) const Icon(Icons.arrow_downward),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
