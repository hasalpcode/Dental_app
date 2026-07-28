import 'dart:convert';
import 'package:dental_app/core/features/members/data/member_model.dart';
import 'package:dental_app/core/helpers/api_client.dart';
import 'package:dental_app/core/helpers/user_storage.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

/// role_id 1 = USER (table role) — rôle par défaut d'un membre nouvellement
/// ajouté ; promu ensuite via AuthRemoteDataSource.updateUserRole si besoin.
const int _defaultMemberRoleId = 1;

class MemberRemoteDataSource {
  final ApiClient client;

  MemberRemoteDataSource(this.client);

  Future<List<MemberModel>> getMembers() async {
    final response = await client.get('/member-service/api/membres');

    if (kDebugMode) {
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
    }

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => MemberModel.fromJson(e)).toList();
    } else {
      throw Exception('Erreur récupération membres: ${response.statusCode}');
    }
  }

  Future<MemberModel> addMember(MemberModel member) async {
    final addUserMember = await client.post(
      '/user-service/auth/register',
      body: {
        "username": member.username,
        "email": member.tel,
        "password": "1234",
        "role": "USER",
      },
    );
    if (kDebugMode) {
      print("ADD USER BODY: ${addUserMember.body}");
      print("ADD USER STATUS: ${addUserMember.statusCode}");
    }
    if (addUserMember.statusCode != 200 && addUserMember.statusCode != 201) {
      throw Exception(
          'Erreur création utilisateur pour membre: ${addUserMember.statusCode} - ${addUserMember.body}');
    } else {
      member.userId = jsonDecode(addUserMember.body)['userId'];
    }

    // Sans Membership, ce User ne pourrait jamais se connecter au tenant
    // courant (rejeté "aucun accès à ce tenant" au login).
    final tenantId = await UserStorage.getTenantId();
    if (tenantId == null) throw Exception('Tenant introuvable');

    final membershipResponse = await client.post(
      '/user-service/memberships',
      body: {
        "tenantId": tenantId,
        "userId": member.userId,
        "roleId": _defaultMemberRoleId,
      },
    );
    if (membershipResponse.statusCode != 200 &&
        membershipResponse.statusCode != 201) {
      throw Exception(
          'Erreur création accès pour membre: ${membershipResponse.statusCode} - ${membershipResponse.body}');
    }

    if (kDebugMode) {
      print("Creating member with userId: ${member.userId}");
      print("Member data: ${member.toJson()}");
    }
    final response = await client.post(
      '/member-service/api/membres',
      body: member.toJson(),
    );

    if (kDebugMode) {
      print("ADD STATUS: ${response.statusCode}");
      print("ADD BODY: ${response.body}");
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return MemberModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur ajout membre: ${response.statusCode}'
          '- ${response.body}');
    }
  }

  Future<MemberModel> updateMember(MemberModel member) async {
    final response = await client.put(
      '/member-service/api/membres/${member.membreId}',
      body: member.toJson(),
    );

    if (kDebugMode) {
      print("UPDATE STATUS: ${response.statusCode}");
      print("UPDATE BODY: ${response.body}");
    }

    if (response.statusCode == 200) {
      return MemberModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur update membre: ${response.statusCode}');
    }
  }

  Future<void> deleteMember(int id) async {
    final response = await client.delete('/member-service/api/membres/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur suppression membre: ${response.statusCode}');
    }
  }
}
