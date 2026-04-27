class RetraitEntity {
  final int? retraitId;
  final int caissierId;
  final String motif;
  final double montant;
  final DateTime? dateRetrait;

  RetraitEntity({
    this.retraitId,
    required this.caissierId,
    required this.motif,
    required this.montant,
    this.dateRetrait,
  });
}
