import 'package:dental_app/core/features/auth/providers/auth_provider.dart';
import 'package:dental_app/core/features/members/data/data_remote_source.dart';
import 'package:dental_app/core/features/members/data/member_repository_impl.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/usecases/get_my_member.dart';
import 'package:dental_app/core/features/payments/data/payment_gateway_remote_data_source.dart';
import 'package:dental_app/core/features/payments/data/payment_gateway_repository_impl.dart';
import 'package:dental_app/core/features/payments/domain/usecases/check_payment_status.dart';
import 'package:dental_app/core/features/payments/domain/usecases/initiate_versement_payment.dart';
import 'package:dental_app/core/features/payments/presentation/bloc/pay_versement_cubit.dart';
import 'package:dental_app/core/features/payments/presentation/bloc/pay_versement_state.dart';
import 'package:dental_app/core/helpers/api_client.dart';
import 'package:dental_app/core/helpers/date_helpers.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

const String _waveSenegal = 'WAVE_SENEGAL';
const String _orangeMoneySenegal = 'ORANGE_MONEY_SENEGAL';

class PayVersementPage extends StatefulWidget {
  const PayVersementPage({super.key});

  @override
  State<PayVersementPage> createState() => _PayVersementPageState();
}

class _PayVersementPageState extends State<PayVersementPage> {
  late final PayVersementCubit cubit;

  bool _loadingMember = true;
  Member? _myMember;
  String? _memberError;

  final amountController = TextEditingController();
  final phoneController = TextEditingController();
  int selectedMonth = DateTime.now().month;
  String provider = _waveSenegal;

  @override
  void initState() {
    super.initState();

    final client = ApiClient.instance;
    final paymentGatewayRepo =
        PaymentGatewayRepositoryImpl(PaymentGatewayRemoteDataSource(client));
    cubit = PayVersementCubit(
      InitiateVersementPayment(paymentGatewayRepo),
      CheckPaymentStatus(paymentGatewayRepo),
    );

    _resolveMyMember();
  }

  Future<void> _resolveMyMember() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.userId;
    if (userId == null) {
      setState(() {
        _loadingMember = false;
        _memberError = 'Utilisateur non connecté';
      });
      return;
    }

    try {
      final memberRepo = MemberRepositoryImpl(MemberRemoteDataSource(ApiClient.instance));
      final member = await GetMyMember(memberRepo)(userId);
      setState(() {
        _loadingMember = false;
        _myMember = member;
        if (member == null) {
          _memberError =
              "Aucune fiche membre n'est associée à votre compte. Contactez votre comptable.";
        }
      });
    } catch (e) {
      setState(() {
        _loadingMember = false;
        _memberError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    phoneController.dispose();
    cubit.close();
    super.dispose();
  }

  Future<void> _submit() async {
    final member = _myMember;
    if (member?.membreId == null) return;

    final montant = double.tryParse(amountController.text);
    if (montant == null || montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant invalide')),
      );
      return;
    }
    if (phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Numéro de téléphone requis')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    await cubit.submit(
      membreId: member!.membreId!,
      mois: '$selectedMonth',
      montant: montant,
      provider: provider,
      phoneNumber: phoneController.text.trim(),
      customerName: auth.user?.username,
      customerEmail: auth.user?.email,
    );
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        appBar: const CurvedAppBar(title: 'Payer ma cotisation'),
        body: _loadingMember
            ? const Center(child: CircularProgressIndicator())
            : _memberError != null
                ? _buildMemberError(_memberError!)
                : BlocBuilder<PayVersementCubit, PayVersementState>(
                    builder: (context, state) {
                      switch (state.step) {
                        case PayVersementStep.form:
                          return _buildForm(state);
                        case PayVersementStep.waitingConfirmation:
                          return _buildWaiting(state);
                        case PayVersementStep.success:
                          return _buildSuccess(state);
                        case PayVersementStep.failed:
                          return _buildFailed(state);
                      }
                    },
                  ),
      ),
    );
  }

  Widget _buildMemberError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildForm(PayVersementState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_myMember != null)
            Text(
              'Membre : ${_myMember!.displayName}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          const SizedBox(height: 20),

          const Text('Moyen de paiement',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ProviderCard(
                  label: 'Wave',
                  selected: provider == _waveSenegal,
                  color: const Color(0xff1dc9ff),
                  onTap: () => setState(() => provider = _waveSenegal),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProviderCard(
                  label: 'Orange Money',
                  selected: provider == _orangeMoneySenegal,
                  color: const Color(0xfff08024),
                  onTap: () => setState(() => provider = _orangeMoneySenegal),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          DropdownButtonFormField<int>(
            value: selectedMonth,
            decoration: const InputDecoration(labelText: 'Mois de la cotisation'),
            items: List.generate(12, (i) => i + 1)
                .map((m) => DropdownMenuItem(value: m, child: Text(monthNameFr(m))))
                .toList(),
            onChanged: (v) => setState(() => selectedMonth = v!),
          ),

          const SizedBox(height: 15),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Montant (FCFA)'),
          ),

          const SizedBox(height: 15),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Numéro de téléphone',
              hintText: 'Ex: 77XXXXXXX',
            ),
          ),

          if (state.error != null) ...[
            const SizedBox(height: 15),
            Text(state.error!, style: const TextStyle(color: Colors.red)),
          ],

          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: const Color(0xff0b5260),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: state.isSubmitting
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Payer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaiting(PayVersementState state) {
    final initiation = state.initiation;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_top, size: 56, color: Color(0xff0b5260)),
            const SizedBox(height: 16),
            const Text(
              'Terminez le paiement depuis votre application de paiement, '
              'puis revenez ici.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (initiation != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _openUrl(initiation.checkoutUrl),
                  child: const Text('Ouvrir la page de paiement'),
                ),
              ),
              if (initiation.omUrl != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _openUrl(initiation.omUrl),
                    child: const Text('Ouvrir Orange Money'),
                  ),
                ),
              ],
              if (initiation.maxitUrl != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _openUrl(initiation.maxitUrl),
                    child: const Text('Ouvrir Maxit'),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 24),
            if (state.isChecking) const CircularProgressIndicator(),
            if (!state.isChecking)
              TextButton(
                onPressed: () => cubit.checkNow(initiation!.invoiceToken),
                child: const Text('Vérifier maintenant'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(PayVersementState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text('Paiement confirmé, votre versement a été enregistré.',
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Terminer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailed(PayVersementState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Le paiement a échoué ou a été annulé'
              '${state.status != null ? " (${state.status!.status})" : ""}.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: cubit.reset,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ProviderCard({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: selected ? color : Colors.transparent, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? color : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
