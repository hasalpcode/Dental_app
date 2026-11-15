class PaymentEntity {
  final String? id;
  final List<int> membreId;
  final String mois;
  final int? annee;
  final double montant;
  final DateTime? dateVersement;

  PaymentEntity({
    this.id,
    required this.membreId,
    required this.mois,
    this.annee,
    required this.montant,
    this.dateVersement,
  });
}
