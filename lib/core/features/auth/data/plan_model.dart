class PlanModel {
  final String planId;
  final String name;
  final int maxMembers;
  final double pricePerMonth;

  PlanModel({
    required this.planId,
    required this.name,
    required this.maxMembers,
    required this.pricePerMonth,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      planId: json['planId'],
      name: json['name'] ?? '',
      maxMembers: json['maxMembers'] ?? 0,
      pricePerMonth: (json['pricePerMonth'] as num?)?.toDouble() ?? 0,
    );
  }
}
