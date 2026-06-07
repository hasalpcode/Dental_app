import 'dart:convert';

import 'package:dental_app/core/features/payments/data/payment_model.dart';
import 'package:dental_app/core/helpers/user_storage.dart';
import 'package:http/http.dart' as http;

class PaymentRemoteDataSource {
  final http.Client client;
  PaymentRemoteDataSource(this.client);

  final String baseUrl = 'https://6db4-46-193-66-177.ngrok-free.app';
  Future<Map<String, String>> _getHeaders() async {
    final token = await UserStorage.getToken();
    if (token == null) throw Exception('Utilisateur non connecté');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<PaymentModel>> getPayments() async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/finance-service/api/versements'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      // show data in console
      print("PAYMENTS RESPONSE: ${response.body}");
      return data.map((e) => PaymentModel.fromJson(e)).toList();
    } else {
      throw Exception('Erreur récupération versements: ${response.statusCode}');
    }
  }

  Future<void> addPayment(PaymentModel payment) async {
    print("Adding payment: ${payment.toJson()}");
    final response = await client.post(
      Uri.parse('$baseUrl/finance-service/api/versements'),
      headers: await _getHeaders(),
      body: jsonEncode(payment.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      print("Error response: ${response.statusCode} - ${response.body}");
      throw Exception(
          'Erreur ajout versement: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> updatePayment(PaymentModel payment) async {
    final response = await client.put(
      Uri.parse('$baseUrl/finance-service/api/versements/${payment.id}'),
      headers: await _getHeaders(),
      body: jsonEncode(payment.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          'Erreur modification versement: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deletePayment(String id) async {
    await client.delete(
      Uri.parse('$baseUrl/finance-service/api/versements/$id'),
      headers: await _getHeaders(),
    );
  }
}
