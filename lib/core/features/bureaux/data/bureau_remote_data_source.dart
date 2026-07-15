import 'dart:convert';

import 'package:dental_app/core/features/bureaux/data/bureau_model.dart';
import 'package:dental_app/core/helpers/user_storage.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;

class BureauRemoteDataSource {
  final http.Client client;
  BureauRemoteDataSource(this.client);

  final String baseUrl =
      'https://service-gatway-production.up.railway.app/member-service';

  Future<Map<String, String>> _getHeaders() async {
    final token = await UserStorage.getToken();
    if (token == null) throw Exception('Utilisateur non connecté');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<BureauModel>> getBureaux() async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/bureaux'),
      headers: await _getHeaders(),
    );
    if (kDebugMode) {
      print('BUREAUX STATUS: ${response.statusCode}');
      print('BUREAUX BODY: ${response.body}');
    }
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => BureauModel.fromJson(e)).toList();
    } else {
      throw Exception('Erreur récupération bureaux: ${response.statusCode}');
    }
  }

  Future<void> addBureau(BureauModel bureau) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/bureaux'),
      headers: await _getHeaders(),
      body: jsonEncode(bureau.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          'Erreur ajout bureau: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> updateBureau(BureauModel bureau) async {
    final response = await client.put(
      Uri.parse('$baseUrl/api/bureaux/${bureau.bureauId}'),
      headers: await _getHeaders(),
      body: jsonEncode(bureau.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          'Erreur modification bureau: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteBureau(int bureauId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/api/bureaux/$bureauId'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur suppression bureau: ${response.statusCode}');
    }
  }
}
