class TenantEntity {
  final String tenantId;
  final String name;
  final String subdomain;
  final String status; // ACTIVE | SUSPENDED | CANCELED
  final int? ownerUserId;
  final DateTime createdAt;

  TenantEntity({
    required this.tenantId,
    required this.name,
    required this.subdomain,
    required this.status,
    required this.ownerUserId,
    required this.createdAt,
  });

  bool get isActive => status == 'ACTIVE';
}
