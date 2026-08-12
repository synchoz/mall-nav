import 'package:flutter/material.dart';

import '../repositories/mall_nav_repository.dart';
import 'admin_screen.dart';
import 'home_screen.dart';
import 'navigate_screen.dart';

class AppShell extends StatefulWidget {
  final MallNavRepository repository;

  const AppShell({super.key, required this.repository});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(repository: widget.repository),
      NavigateScreen(repository: widget.repository),
      AdminScreen(repository: widget.repository),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Status'),
          NavigationDestination(icon: Icon(Icons.directions), label: 'Navigate'),
          NavigationDestination(icon: Icon(Icons.edit_location_alt), label: 'Admin'),
        ],
      ),
    );
  }
}
