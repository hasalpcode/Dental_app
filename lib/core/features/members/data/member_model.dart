import 'package:dental_app/core/features/members/domain/entity/member.dart';

class MemberModel extends Member {
  MemberModel({
    int? membreId,
    required String name,
    required String phone,
    required String address,
    int? userId,
    String? bureauId,
    String? posteId,
    DateTime? dateAdhesion,
  }) : super(
          membreId: membreId,
          userId: userId,
          username: name,
          tel: phone,
          address: address,
          bureauId: bureauId,
          posteId: posteId,
          dateAdhesion: dateAdhesion,
        );

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      membreId: json['memberId']?.toInt() ?? null,
      userId: json['userId']?.toInt() ?? null,
      name: json['username'] ?? '',
      phone: json['tel'] ?? '',
      address: json['adresse'] ?? '',
      bureauId: json['bureauId']?.toString(),
      posteId: json['posteId']?.toString(),
      dateAdhesion: json['dateAdhesion'] != null
          ? DateTime.tryParse(json['dateAdhesion'])
          : null,
    );
  }

  @override
  String toString() {
    return 'Member(id: $membreId, username: $username)';
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': membreId,
      'userId': userId,
      'username': username,
      'tel': tel,
      'adresse': address,
      'bureauId': bureauId,
      'posteId': posteId,
      'dateAdhesion': dateAdhesion?.toIso8601String(),
    };
  }

  factory MemberModel.fromEntity(Member member) {
    return MemberModel(
      membreId: member.membreId,
      name: member.username,
      phone: member.tel,
      address: member.address,
      bureauId: member.bureauId,
      posteId: member.posteId,
      dateAdhesion: member.dateAdhesion,
    );
  }
}
