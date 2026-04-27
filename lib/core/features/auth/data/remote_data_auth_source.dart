import 'dart:convert';
import 'dart:io';
import 'package:dental_app/core/features/auth/data/user_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSource(this.client);

  // juste pour le ngrok, à remplacer par la methode ci-dessous
  Future<UserModel> login(String email, String password) async {
    final client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

    try {
      final request = await client
          .postUrl(Uri.parse(
              'https://961b-46-193-66-177.ngrok-free.app/user-service/auth/login'))
          .timeout(const Duration(seconds: 10));

      request.headers.set(HttpHeaders.contentTypeHeader, "application/json");
      request.add(utf8.encode(jsonEncode({
        "email": email,
        "password": password,
      })));

      final response = await request.close();

      final responseBody = await response.transform(utf8.decoder).join();
      print('Status code: ${response.statusCode}');
      print('Body: $responseBody');

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(responseBody));
      } else {
        throw Exception(
            "Login failed: ${response.statusCode} - ${responseBody}");
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  // Future<UserModel> login(String email, String password) async {
  //   final response = await client.post(
  //     Uri.parse(
  //         'https://52a5-46-193-66-177.ngrok.free.app/user-service/auth/login'),
  //     body: jsonEncode({
  //       "email": email,
  //       "password": password,
  //     }),
  //     headers: {
  //       "Content-Type": "application/json",
  //     },
  //   );
  //   print(response.statusCode);

  //   if (response.statusCode == 200) {
  //     return UserModel.fromJson(jsonDecode(response.body));
  //   } else {
  //     print("Login failed: ${response.statusCode} - ${response.body}");
  //     throw Exception("Login failed");
  //   }
  // }
}
