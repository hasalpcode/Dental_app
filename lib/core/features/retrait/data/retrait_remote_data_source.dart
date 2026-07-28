import 'dart:convert';

import 'package:dental_app/core/features/retrait/data/retrait_model.dart';
import 'package:dental_app/core/helpers/api_client.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class RetraitRemoteDataSource {
  final ApiClient client;
  RetraitRemoteDataSource(this.client);

  Future<List<RetraitModel>> getRetraits() async {
    final response = await client.get('/finance-service/api/retraits');
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
      '/finance-service/api/retraits',
      body: retrait.toJson(),
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
      '/finance-service/api/retraits/${retrait.retraitId}',
      body: retrait.toJson(),
    );

    return RetraitModel.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteRetrait(String id) async {
    await client.delete('/finance-service/api/retraits/$id');
  }
}
