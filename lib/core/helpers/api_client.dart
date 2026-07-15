import 'package:http/http.dart' as http;

/// Client HTTP unique partagé par toute l'application, pour réutiliser
/// la connexion (keep-alive) au lieu d'ouvrir un nouveau socket TCP/TLS
/// à chaque écran ou chaque requête.
class ApiClient {
  static final http.Client instance = http.Client();
}
