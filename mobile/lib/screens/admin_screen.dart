import 'package:flutter/material.dart';

import '../models/edge.dart';
import '../models/floor.dart';
import '../models/node.dart';
import '../repositories/mall_nav_repository.dart';

class AdminScreen extends StatefulWidget {
  final MallNavRepository repository;

  const AdminScreen({super.key, required this.repository});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Floor> _floors = [];
  List<MapNode> _nodes = [];
  List<MapEdge> _edges = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final floors = await widget.repository.getFloors();
      final nodes = await widget.repository.getNodes();
      final edges = await widget.repository.getEdges();
      setState(() {
        _floors = floors;
        _nodes = nodes;
        _edges = edges;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  String _nodeLabel(int nodeId) {
    final match = _nodes.where((n) => n.id == nodeId);
    if (match.isEmpty) return 'Node #$nodeId';
    return match.first.displayName;
  }

  Future<void> _addFloor() async {
    final nameController = TextEditingController();
    final levelController = TextEditingController(text: '0');

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add floor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(
              controller: levelController,
              decoration: const InputDecoration(labelText: 'Level index'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add')),
        ],
      ),
    );

    if (submitted != true || nameController.text.isEmpty) return;

    try {
      await widget.repository.createFloor(
        name: nameController.text,
        levelIndex: int.tryParse(levelController.text) ?? 0,
      );
      await _refresh();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _addNode() async {
    if (_floors.isEmpty) {
      _showError('Add a floor first');
      return;
    }

    int selectedFloorId = _floors.first.id;
    final xController = TextEditingController(text: '0');
    final yController = TextEditingController(text: '0');
    final labelController = TextEditingController();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add node'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                value: selectedFloorId,
                items: _floors
                    .map((f) => DropdownMenuItem(value: f.id, child: Text(f.name)))
                    .toList(),
                onChanged: (value) => setDialogState(() => selectedFloorId = value!),
              ),
              TextField(
                controller: xController,
                decoration: const InputDecoration(labelText: 'x'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: yController,
                decoration: const InputDecoration(labelText: 'y'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Label (optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add')),
          ],
        ),
      ),
    );

    if (submitted != true) return;

    try {
      await widget.repository.createNode(
        floorId: selectedFloorId,
        x: double.tryParse(xController.text) ?? 0,
        y: double.tryParse(yController.text) ?? 0,
        label: labelController.text.isEmpty ? null : labelController.text,
      );
      await _refresh();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _addEdge() async {
    if (_nodes.length < 2) {
      _showError('Add at least two nodes first');
      return;
    }

    int nodeAId = _nodes[0].id;
    int nodeBId = _nodes[1].id;
    final weightController = TextEditingController(text: '1.0');
    String edgeType = 'walk';

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add edge'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                value: nodeAId,
                items: _nodes
                    .map((n) => DropdownMenuItem(value: n.id, child: Text(n.displayName)))
                    .toList(),
                onChanged: (value) => setDialogState(() => nodeAId = value!),
              ),
              const Icon(Icons.arrow_downward),
              DropdownButton<int>(
                value: nodeBId,
                items: _nodes
                    .map((n) => DropdownMenuItem(value: n.id, child: Text(n.displayName)))
                    .toList(),
                onChanged: (value) => setDialogState(() => nodeBId = value!),
              ),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Weight'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              DropdownButton<String>(
                value: edgeType,
                items: const [
                  DropdownMenuItem(value: 'walk', child: Text('walk')),
                  DropdownMenuItem(value: 'stairs', child: Text('stairs')),
                  DropdownMenuItem(value: 'elevator', child: Text('elevator')),
                ],
                onChanged: (value) => setDialogState(() => edgeType = value!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add')),
          ],
        ),
      ),
    );

    if (submitted != true) return;
    if (nodeAId == nodeBId) {
      _showError('Pick two different nodes');
      return;
    }

    try {
      await widget.repository.createEdge(
        nodeAId: nodeAId,
        nodeBId: nodeBId,
        weight: double.tryParse(weightController.text) ?? 1.0,
        edgeType: edgeType,
      );
      await _refresh();
    } catch (e) {
      _showError(e);
    }
  }

  void _showError(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_loading) const LinearProgressIndicator(),

            _SectionHeader(title: 'Floors', onAdd: _addFloor),
            for (final floor in _floors)
              ListTile(
                leading: const Icon(Icons.layers),
                title: Text(floor.name),
                subtitle: Text('Level ${floor.levelIndex}'),
              ),
            if (_floors.isEmpty) const Text('No floors yet.'),

            const SizedBox(height: 24),
            _SectionHeader(title: 'Nodes', onAdd: _addNode),
            for (final node in _nodes)
              ListTile(
                leading: const Icon(Icons.place),
                title: Text(node.displayName),
                subtitle: Text('Floor ${node.floorId} · (${node.x}, ${node.y})'),
              ),
            if (_nodes.isEmpty) const Text('No nodes yet.'),

            const SizedBox(height: 24),
            _SectionHeader(title: 'Edges', onAdd: _addEdge),
            for (final edge in _edges)
              ListTile(
                leading: const Icon(Icons.route),
                title: Text('${_nodeLabel(edge.nodeAId)} ↔ ${_nodeLabel(edge.nodeBId)}'),
                subtitle: Text('${edge.edgeType} · weight ${edge.weight}'),
              ),
            if (_edges.isEmpty) const Text('No edges yet.'),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;

  const _SectionHeader({required this.title, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        IconButton(icon: const Icon(Icons.add_circle), onPressed: onAdd),
      ],
    );
  }
}
