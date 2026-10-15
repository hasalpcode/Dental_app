import 'dart:convert';

import 'package:dental_app/core/features/payments/data/payment_gateway_model.dart';
import 'package:dental_app/core/helpers/api_client.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class PaymentGatewayRemoteDataSource {
  final ApiClient client;

  PaymentGatewayRemoteDataSource(this.client);

  Future<PaymentInitiationModel> initiate({
    required int membreId,
    required String mois,
    required double montant,
    required String provider,
    required String phoneNumber,
    String? customerName,
    String? customerEmail,
  }) async {
    final response = await client.post(
      '/finance-service/api/payments/versement/initiate',
      body: {
        'membreId': membreId,
        'mois': mois,
        'montant': montant,
        'provider': provider,
        'phoneNumber': phoneNumber,
        'customerName': customerName,
        'customerEmail': customerEmail,
      },
    );

    if (kDebugMode) {
      print('INITIATE PAYMENT STATUS: ${response.statusCode}');
      print('INITIATE PAYMENT BODY: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PaymentInitiationModel.fromJson(jsonDecode(response.body));
    }
    throw Exception(
        'Erreur initialisation du paiement: ${response.statusCode} - ${response.body}');
  }

  Future<PaymentStatusModel> getStatus(String invoiceToken) async {
    final response =
        await client.get('/finance-service/api/payments/$invoiceToken/status');

    if (response.statusCode == 200) {
      return PaymentStatusModel.fromJson(jsonDecode(response.body));
    }
    throw Exception(
        'Erreur vérification du statut: ${response.statusCode} - ${response.body}');
  }
}
