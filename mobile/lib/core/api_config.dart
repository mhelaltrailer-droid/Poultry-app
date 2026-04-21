import 'api_config_io.dart' if (dart.library.html) 'api_config_web.dart' as _host;

/// Override: `flutter run -d chrome --dart-define=API_BASE=http://192.168.x.x:4000`
const String _envApiBase = String.fromEnvironment('API_BASE', defaultValue: '');

String resolveApiBase() {
  if (_envApiBase.isNotEmpty) return _envApiBase;
  return _host.defaultApiHost();
}
