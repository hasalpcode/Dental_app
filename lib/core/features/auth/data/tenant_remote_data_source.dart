import 'dart:convert';

import 'package:dental_app/core/features/auth/data/plan_model.dart';
import 'package:dental_app/core/helpers/api_client.dart';

/// Appels vers tenant-service qui ne nécessitent ni tenant résolu ni JWT
/// (catalogue de plans, consulté avant même la création d'un tenant) — voir
/// PUBLIC_PATHS côté gateway (TenantResolutionFilter / JwtValidationFilter).
class TenantRemoteDataSource {
  final ApiClient client;

  TenantRemoteDataSource(this.client);

  Future<List<PlanModel>> getPlans() async {
    final response = await client.get('/tenant-service/api/plans', auth: false);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => PlanModel.fromJson(e)).toList();
    } else {
      throw Exception('Erreur récupération des plans: ${response.statusCode}');
    }
  }
}
