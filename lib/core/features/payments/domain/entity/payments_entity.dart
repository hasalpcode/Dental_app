class PaymentEntity {
  final String? id;
  final List<int> memberIds;
  final String mois;
  final double montant;
  final DateTime? dateVersement;

  PaymentEntity({
    this.id,
    required this.memberIds,
    required this.mois,
    required this.montant,
    this.dateVersement,
  });
}
