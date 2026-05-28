class Member {
  final int? membreId;
  int? userId;
  final String username;
  final String tel;
  final String address;
  final int? bureauId;
  final String? posteId;
  final DateTime? dateAdhesion;
  final String? carteMembre;

  Member({
    this.membreId,
    this.userId,
    required this.username,
    required this.tel,
    required this.address,
    this.bureauId,
    this.posteId,
    this.dateAdhesion,
    this.carteMembre,
  });

  String get displayName {
    if (carteMembre != null && carteMembre!.isNotEmpty) {
      return '$username - ${carteMembre!}';
    }
    return username;
  }
}
