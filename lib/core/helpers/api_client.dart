import 'dart:convert';
import 'dart:io';

import 'package:dental_app/core/config/app_config.dart';
import 'package:dental_app/core/helpers/user_storage.dart';
import 'package:http/http.dart' as http;

/// Client HTTP unique partagé par toute l'app : centralise la base URL et
/// pose automatiquement Authorization + X-Tenant-Subdomain sur chaque
/// requête, au lieu de dupliquer cette logique dans chaque source de
/// données. Le gateway resout le tenant a partir de cet en-tete (ou du
/// Host reel, inapplicable ici puisque l'app n'est pas un navigateur) et
/// rejette toute requete sans tenant resolu — meme les requetes deja
/// authentifiees.
class ApiClient {
  static final ApiClient instance = ApiClient._internal();
  final http.Client _client = http.Client();

  ApiClient._internal();

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    final subdomain = await UserStorage.getSubdomain();
    if (subdomain != null && subdomain.isNotEmpty) {
      headers['X-Tenant-Subdomain'] = subdomain;
    }

    if (auth) {
      final token = await UserStorage.getToken();
      if (token == null) throw Exception('Utilisateur non connecté');
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Uri _uri(String path) => Uri.parse('${AppConfig.baseUrl}$path');

  Future<http.Response> get(String path, {bool auth = true}) async {
    return _client.get(_uri(path), headers: await _headers(auth: auth));
  }

  Future<http.Response> post(String path, {Object? body, bool auth = true}) async {
    return _client.post(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> put(String path, {Object? body, bool auth = true}) async {
    return _client.put(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> patch(String path, {Object? body, bool auth = true}) async {
    return _client.patch(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> delete(String path, {bool auth = true}) async {
    return _client.delete(_uri(path), headers: await _headers(auth: auth));
  }

  /// Requête multipart (upload de fichier) : Content-Type est géré par
  /// MultipartRequest lui-même, seuls Authorization et le tenant sont
  /// posés ici.
  Future<http.StreamedResponse> multipartUpload(
    String path, {
    required File file,
    required String fileField,
  }) async {
    final request = http.MultipartRequest('POST', _uri(path));

    final subdomain = await UserStorage.getSubdomain();
    if (subdomain != null && subdomain.isNotEmpty) {
      request.headers['X-Tenant-Subdomain'] = subdomain;
    }
    final token = await UserStorage.getToken();
    if (token == null) throw Exception('Utilisateur non connecté');
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(await http.MultipartFile.fromPath(fileField, file.path));
    return _client.send(request);
  }
}
