/// Configuration d'environnement de l'app. L'URL de base peut être
/// surchargée au build/run avec :
///   flutter run --dart-define=BASE_URL=https://mon-gateway.example.com
class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
}
