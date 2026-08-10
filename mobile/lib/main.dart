import 'package:flutter/material.dart';

import 'repositories/mall_nav_repository.dart';
import 'screens/home_screen.dart';
import 'services/api_client.dart';
import 'services/app_config.dart';

void main() {
  final repository = ApiMallNavRepository(
    ApiClient(baseUrl: AppConfig.apiBaseUrl),
  );
  runApp(MallNavApp(repository: repository));
}

class MallNavApp extends StatelessWidget {
  final MallNavRepository repository;

  const MallNavApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mall Navigation',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: HomeScreen(repository: repository),
    );
  }
}
