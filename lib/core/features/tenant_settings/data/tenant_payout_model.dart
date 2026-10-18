class TenantPayoutModel {
  final String? payoutPhoneNumber;
  final String? payoutOperator;

  TenantPayoutModel({this.payoutPhoneNumber, this.payoutOperator});

  factory TenantPayoutModel.fromJson(Map<String, dynamic> json) {
    return TenantPayoutModel(
      payoutPhoneNumber: json['payoutPhoneNumber'],
      payoutOperator: json['payoutOperator'],
    );
  }
}
