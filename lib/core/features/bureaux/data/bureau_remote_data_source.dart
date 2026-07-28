import 'dart:convert';

import 'package:dental_app/core/features/bureaux/data/bureau_model.dart';
import 'package:dental_app/core/helpers/api_client.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class BureauRemoteDataSource {
  final ApiClient client;
  BureauRemoteDataSource(this.client);

  Future<List<BureauModel>> getBureaux() async {
    final response = await client.get('/member-service/api/bureaux');
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
      '/member-service/api/bureaux',
      body: bureau.toJson(),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          'Erreur ajout bureau: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> updateBureau(BureauModel bureau) async {
    final response = await client.put(
      '/member-service/api/bureaux/${bureau.bureauId}',
      body: bureau.toJson(),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          'Erreur modification bureau: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteBureau(int bureauId) async {
    final response = await client.delete('/member-service/api/bureaux/$bureauId');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur suppression bureau: ${response.statusCode}');
    }
  }
}
