import 'package:dental_app/core/features/superadmin/domain/entity/tenant_entity.dart';

class TenantModel extends TenantEntity {
  TenantModel({
    required super.tenantId,
    required super.name,
    required super.subdomain,
    required super.status,
    required super.ownerUserId,
    required super.createdAt,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      tenantId: json['tenantId'],
      name: json['name'] ?? '',
      subdomain: json['subdomain'] ?? '',
      status: json['status'] ?? 'ACTIVE',
      ownerUserId: json['ownerUserId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
