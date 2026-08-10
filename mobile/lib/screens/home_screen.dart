import 'package:flutter/material.dart';

import '../models/floor.dart';
import '../repositories/mall_nav_repository.dart';

class HomeScreen extends StatefulWidget {
  final MallNavRepository repository;

  const HomeScreen({super.key, required this.repository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool? _backendHealthy;
  List<Floor> _floors = [];
  String? _error;
  bool _loading = false;

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
      final healthy = await widget.repository.checkHealth();
      final floors = await widget.repository.getFloors();
      setState(() {
        _backendHealthy = healthy;
        _floors = floors;
      });
    } catch (e) {
      setState(() {
        _backendHealthy = false;
        _error = e.toString();
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mall Navigation')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: Icon(
                  _backendHealthy == true ? Icons.check_circle : Icons.error,
                  color: _backendHealthy == true ? Colors.green : Colors.red,
                ),
                title: Text(_backendHealthy == true ? 'Backend connected' : 'Backend unreachable'),
                subtitle: _error != null ? Text(_error!) : null,
                trailing: _loading ? const CircularProgressIndicator() : null,
              ),
            ),
            const SizedBox(height: 16),
            Text('Floors', style: Theme.of(context).textTheme.titleLarge),
            if (_floors.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No floors yet — add some via the backend API.'),
              ),
            for (final floor in _floors)
              ListTile(
                leading: const Icon(Icons.layers),
                title: Text(floor.name),
                subtitle: Text('Level ${floor.levelIndex}'),
              ),
          ],
        ),
      ),
    );
  }
}
