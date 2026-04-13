import 'dart:convert';
import 'dart:io';
import 'package:dental_app/core/features/members/data/member_model.dart';
import 'package:dental_app/core/helpers/user_storage.dart';
import 'package:http/http.dart' as http;

class MemberRemoteDataSource {
  final http.Client client;

  MemberRemoteDataSource(this.client);

  final String baseUrl = 'https://af1c-46-193-66-177.ngrok-free.app';

  Future<Map<String, String>> _getHeaders() async {
    final token = await UserStorage.getToken();
    if (token == null) throw Exception('Utilisateur non connecté');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<MemberModel>> getMembers() async {
    final headers = await _getHeaders();

    final response = await client.get(
      Uri.parse('$baseUrl/member-service/api/membres'),
      headers: headers,
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => MemberModel.fromJson(e)).toList();
    } else {
      throw Exception('Erreur récupération membres: ${response.statusCode}');
    }
  }

  Future<MemberModel> addMember(MemberModel member) async {
    final headers = await _getHeaders();

    final addUserMember = await client.post(
      Uri.parse('$baseUrl/user-service/auth/register'),
      headers: headers,
      body: jsonEncode({
        "username": member.username,
        "email": member.username.toLowerCase(),
        "password": "passer",
        "role": "USER",
      }),
    );
    print("ADD USER BODY: ${addUserMember.body}");
    print("ADD USER STATUS: ${addUserMember.statusCode}");
    if (addUserMember.statusCode != 200 && addUserMember.statusCode != 201) {
      throw Exception(
          'Erreur création utilisateur pour membre: ${addUserMember.statusCode} - ${addUserMember.body}');
    } else {
      member.userId = jsonDecode(addUserMember.body)['userId'];
    }

    print("Creating member with userId: ${member.userId}");
    print("Member data: ${member.toJson()}");
    final response = await client.post(
      Uri.parse('$baseUrl/member-service/api/membres'),
      headers: headers,
      body: jsonEncode(member.toJson()),
    );

    print("ADD STATUS: ${response.statusCode}");
    print("ADD BODY: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return MemberModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur ajout membre: ${response.statusCode}'
          '- ${response.body}');
    }
  }

  Future<MemberModel> updateMember(MemberModel member) async {
    final headers = await _getHeaders();

    final response = await client.put(
      Uri.parse('$baseUrl/member-service/api/membres/${member.userId}'),
      headers: headers,
      body: jsonEncode(member.toJson()),
    );

    print("UPDATE STATUS: ${response.statusCode}");
    print("UPDATE BODY: ${response.body}");

    if (response.statusCode == 200) {
      return MemberModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur update membre: ${response.statusCode}');
    }
  }

  Future<void> deleteMember(int id) async {
    final headers = await _getHeaders();
    final response = await client.delete(
      Uri.parse('$baseUrl/member-service/api/membres/$id'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur suppression membre: ${response.statusCode}');
    }
  }
}
