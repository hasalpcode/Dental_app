import 'dart:convert';

import 'package:dental_app/core/features/baptemes/data/baptem_model.dart';
import 'package:dental_app/core/helpers/api_client.dart';

class BaptismRemoteDataSource {
  final ApiClient client;

  BaptismRemoteDataSource(this.client);

  Future<List<BaptismModel>> getBaptisms() async {
    final response = await client.get('/finance-service/api/births');

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
    final response = await client.get('/finance-service/api/births/$id');

    if (response.statusCode == 200) {
      return BaptismModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur récupération baptême: ${response.statusCode}');
    }
  }

  Future<BaptismModel> addBaptism(BaptismModel baptism) async {
    final response = await client.post(
      '/finance-service/api/births',
      body: baptism.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return BaptismModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur ajout baptême: ${response.statusCode}');
    }
  }

  Future<BaptismModel> updateBaptism(BaptismModel baptism) async {
    final response = await client.put(
      '/finance-service/api/births/${baptism.id}',
      body: baptism.toJson(),
    );

    if (response.statusCode == 200) {
      return BaptismModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur modification baptême: ${response.statusCode}');
    }
  }

  Future<void> deleteBaptism(String id) async {
    final response = await client.delete('/finance-service/api/births/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur suppression baptême: ${response.statusCode}');
    }
  }
}
