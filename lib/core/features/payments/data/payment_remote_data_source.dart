import 'dart:convert';

import 'package:dental_app/core/features/payments/data/payment_model.dart';
import 'package:dental_app/core/helpers/api_client.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class PaymentRemoteDataSource {
  final ApiClient client;
  PaymentRemoteDataSource(this.client);

  Future<List<PaymentModel>> getPayments() async {
    final response = await client.get('/finance-service/api/versements');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (kDebugMode) print("PAYMENTS RESPONSE: ${response.body}");
      return data.map((e) => PaymentModel.fromJson(e)).toList();
    } else {
      throw Exception('Erreur récupération versements: ${response.statusCode}');
    }
  }

  Future<void> addPayment(PaymentModel payment) async {
    if (kDebugMode) print("Adding payment: ${payment.toJson()}");
    final response = await client.post(
      '/finance-service/api/versements',
      body: payment.toJson(),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      if (kDebugMode) {
        print("Error response: ${response.statusCode} - ${response.body}");
      }
      throw Exception(
          'Erreur ajout versement: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> updatePayment(PaymentModel payment) async {
    final response = await client.put(
      '/finance-service/api/versements/${payment.id}',
      body: payment.toJson(),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          'Erreur modification versement: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deletePayment(String id) async {
    await client.delete('/finance-service/api/versements/$id');
  }
}
