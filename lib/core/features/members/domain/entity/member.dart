class Member {
  final int? membreId;
  int? userId;
  final String username;
  final String tel;
  final String addresse;
  final int? bureauId;
  final String? posteId;
  final DateTime? dateAdhesion;
  final String? carteMembre;
  final int? roleId;
  final String? role;
  final String? situationMatrimoniale;

  Member({
    this.membreId,
    this.userId,
    required this.username,
    required this.tel,
    required this.addresse,
    this.bureauId,
    this.posteId,
    this.dateAdhesion,
    this.carteMembre,
    this.roleId,
    this.role,
    this.situationMatrimoniale,
  });

  String get displayName {
    if (carteMembre != null && carteMembre!.isNotEmpty) {
      return '$username - ${carteMembre!}';
    }
    return username;
  }

  bool get isMarried => situationMatrimoniale?.toUpperCase() == 'MARIE';
}
