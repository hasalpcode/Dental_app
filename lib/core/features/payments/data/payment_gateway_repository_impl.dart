import 'package:dental_app/core/features/payments/data/payment_gateway_remote_data_source.dart';
import 'package:dental_app/core/features/payments/domain/entity/payment_gateway_entity.dart';
import 'package:dental_app/core/features/payments/domain/repository/payment_gateway_repository.dart';

class PaymentGatewayRepositoryImpl implements PaymentGatewayRepository {
  final PaymentGatewayRemoteDataSource dataSource;

  PaymentGatewayRepositoryImpl(this.dataSource);

  @override
  Future<PaymentInitiationEntity> initiateVersementPayment({
    required int membreId,
    required String mois,
    required double montant,
    required String provider,
    required String phoneNumber,
    String? customerName,
    String? customerEmail,
  }) async {
    final result = await dataSource.initiate(
      membreId: membreId,
      mois: mois,
      montant: montant,
      provider: provider,
      phoneNumber: phoneNumber,
      customerName: customerName,
      customerEmail: customerEmail,
    );
    return result.toEntity();
  }

  @override
  Future<PaymentStatusEntity> getPaymentStatus(String invoiceToken) async {
    final result = await dataSource.getStatus(invoiceToken);
    return result.toEntity();
  }
}
