class TenantOption {
  final String tenantId;
  final String subdomain;
  final String tenantName;

  TenantOption({
    required this.tenantId,
    required this.subdomain,
    required this.tenantName,
  });

  factory TenantOption.fromJson(Map<String, dynamic> json) {
    return TenantOption(
      tenantId: json['tenantId'],
      subdomain: json['subdomain'] ?? '',
      tenantName: json['tenantName'] ?? '',
    );
  }
}
