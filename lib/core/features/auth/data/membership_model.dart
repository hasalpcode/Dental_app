class MembershipModel {
  final int userId;
  final int roleId;
  final String roleName;

  MembershipModel({
    required this.userId,
    required this.roleId,
    required this.roleName,
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    return MembershipModel(
      userId: json['userId'],
      roleId: json['roleId'],
      roleName: json['roleName'] ?? '',
    );
  }
}
