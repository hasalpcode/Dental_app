import 'dart:convert';

import 'package:dental_app/core/features/baptemes/data/baptem_model.dart';
import 'package:dental_app/core/helpers/user_storage.dart';
import 'package:http/http.dart' as http;

class BaptismRemoteDataSource {
  final http.Client client;
  final String baseUrl =
      'https://961b-46-193-66-177.ngrok-free.app/finance-service';

  BaptismRemoteDataSource(this.client);

  Future<Map<String, String>> _getHeaders() async {
    final token = await UserStorage.getToken();
    if (token == null) throw Exception('Utilisateur non connecté');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<BaptismModel>> getBaptisms() async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/api/births'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => BaptismModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Erreur récupération baptêmes: ${response.statusCode}');
    }
  }

  Future<BaptismModel> getBaptismById(String id) async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/api/births/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return BaptismModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur récupération baptême: ${response.statusCode}');
    }
  }

  Future<BaptismModel> addBaptism(BaptismModel baptism) async {
    final headers = await _getHeaders();
    final response = await client.post(
      Uri.parse('$baseUrl/api/births'),
      headers: headers,
      body: jsonEncode(baptism.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return BaptismModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur ajout baptême: ${response.statusCode}');
    }
  }

  Future<BaptismModel> updateBaptism(BaptismModel baptism) async {
    final headers = await _getHeaders();
    final response = await client.put(
      Uri.parse('$baseUrl/api/births/${baptism.id}'),
      headers: headers,
      body: jsonEncode(baptism.toJson()),
    );

    if (response.statusCode == 200) {
      return BaptismModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur modification baptême: ${response.statusCode}');
    }
  }

  Future<void> deleteBaptism(String id) async {
    final headers = await _getHeaders();
    final response = await client.delete(
      Uri.parse('$baseUrl/api/births/$id'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur suppression baptême: ${response.statusCode}');
    }
  }
}
