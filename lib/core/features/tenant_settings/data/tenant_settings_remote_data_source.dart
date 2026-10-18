import 'dart:convert';

import 'package:dental_app/core/features/tenant_settings/data/tenant_payout_model.dart';
import 'package:dental_app/core/helpers/api_client.dart';

/// Reglage du numero Wave/Orange Money sur lequel finance-service reverse
/// le montant des versements confirmes. Le tenant est resolu cote serveur a
/// partir du JWT (en-tete X-Tenant-Id pose par le gateway), jamais envoye
/// par le client : voir TenantController#getMine/updateMyPayout.
class TenantSettingsRemoteDataSource {
  final ApiClient client;

  TenantSettingsRemoteDataSource(this.client);

  Future<TenantPayoutModel> getMine() async {
    final response = await client.get('/tenant-service/api/tenants/me');
    if (response.statusCode == 200) {
      return TenantPayoutModel.fromJson(jsonDecode(response.body));
    }
    throw Exception(
        'Erreur récupération des infos de la caisse: ${response.statusCode} - ${response.body}');
  }

  Future<TenantPayoutModel> updatePayout({
    required String payoutPhoneNumber,
    required String payoutOperator,
  }) async {
    final response = await client.patch(
      '/tenant-service/api/tenants/me/payout',
      body: {
        'payoutPhoneNumber': payoutPhoneNumber,
        'payoutOperator': payoutOperator,
      },
    );
    if (response.statusCode == 200) {
      return TenantPayoutModel.fromJson(jsonDecode(response.body));
    }
    throw Exception(
        'Erreur mise à jour du numéro de réception: ${response.statusCode} - ${response.body}');
  }
}
