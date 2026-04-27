class PaymentEntity {
  final String? id;
  final List<int> membreId;
  final String mois;
  final double montant;
  final DateTime? dateVersement;

  PaymentEntity({
    this.id,
    required this.membreId,
    required this.mois,
    required this.montant,
    this.dateVersement,
  });
}
