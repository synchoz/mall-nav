import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Resolves the backend base URL for the current run target.
///
/// The Android emulator can't reach the host machine via `localhost` (it
/// needs the special `10.0.2.2` alias), while desktop/web builds talk to
/// `localhost` directly. Override at build time with
/// `--dart-define=API_BASE_URL=https://your-backend` for a real device or
/// the deployed Render URL.
class AppConfig {
  static String get apiBaseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;

    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }
}
