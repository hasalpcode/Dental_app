import 'dart:convert';

import 'package:dental_app/core/features/retrait/data/retrait_model.dart';
import 'package:dental_app/core/helpers/user_storage.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;

class RetraitRemoteDataSource {
  final http.Client client;
  RetraitRemoteDataSource(this.client);

  final String baseUrl = 'https://service-gatway-production.up.railway.app';

  Future<Map<String, String>> _getHeaders() async {
    final token = await UserStorage.getToken();
    if (token == null) throw Exception('Utilisateur non connecté');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<RetraitModel>> getRetraits() async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/finance-service/api/retraits'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (kDebugMode) print("RETRAITS RESPONSE: ${response.body}");
      return data.map((e) => RetraitModel.fromJson(e)).toList();
    } else {
      throw Exception('Erreur récupération retraits: ${response.statusCode}');
    }
  }

  Future<RetraitModel> addRetrait(RetraitModel retrait) async {
    if (kDebugMode) print("Adding retrait: ${retrait.toJson()}");
    final response = await client.post(
      Uri.parse('$baseUrl/finance-service/api/retraits'),
      headers: await _getHeaders(),
      body: jsonEncode(retrait.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return RetraitModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Erreur ajout retrait: ${response.statusCode} - ${response.body}');
    }
  }

  Future<RetraitModel> updateRetrait(RetraitModel retrait) async {
    final response = await client.put(
      Uri.parse('$baseUrl/finance-service/api/retraits/${retrait.retraitId}'),
      headers: await _getHeaders(),
      body: jsonEncode(retrait.toJson()),
    );

    return RetraitModel.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteRetrait(String id) async {
    await client.delete(
      Uri.parse('$baseUrl/finance-service/api/retraits/$id'),
      headers: await _getHeaders(),
    );
  }
}
