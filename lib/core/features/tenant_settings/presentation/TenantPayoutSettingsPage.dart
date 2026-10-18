import 'package:dental_app/core/features/tenant_settings/data/tenant_settings_remote_data_source.dart';
import 'package:dental_app/core/helpers/api_client.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';
import 'package:flutter/material.dart';

const String _waveSenegal = 'WAVE_SENEGAL';
const String _orangeMoneySenegal = 'ORANGE_MONEY_SENEGAL';

/// Reglage reserve a l'admin du tenant : le numero Wave/Orange Money sur
/// lequel finance-service reverse automatiquement le montant de chaque
/// versement confirme par un membre (voir PaymentServiceImpl#disburseToTenant).
class TenantPayoutSettingsPage extends StatefulWidget {
  const TenantPayoutSettingsPage({super.key});

  @override
  State<TenantPayoutSettingsPage> createState() =>
      _TenantPayoutSettingsPageState();
}

class _TenantPayoutSettingsPageState extends State<TenantPayoutSettingsPage> {
  late final TenantSettingsRemoteDataSource dataSource;

  final phoneController = TextEditingController();
  String operator = _waveSenegal;

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    dataSource = TenantSettingsRemoteDataSource(ApiClient.instance);
    _load();
  }

  Future<void> _load() async {
    try {
      final tenant = await dataSource.getMine();
      setState(() {
        phoneController.text = tenant.payoutPhoneNumber ?? '';
        operator = tenant.payoutOperator ?? _waveSenegal;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _save() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Numéro requis')),
      );
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await dataSource.updatePayout(
        payoutPhoneNumber: phone,
        payoutOperator: operator,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Numéro de réception enregistré')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CurvedAppBar(title: 'Réception des paiements'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Numéro Wave ou Orange Money sur lequel vous recevez "
                    "le montant des cotisations payées par les membres.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  const Text('Opérateur',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _OperatorCard(
                          label: 'Wave',
                          selected: operator == _waveSenegal,
                          color: const Color(0xff1dc9ff),
                          onTap: () => setState(() => operator = _waveSenegal),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _OperatorCard(
                          label: 'Orange Money',
                          selected: operator == _orangeMoneySenegal,
                          color: const Color(0xfff08024),
                          onTap: () =>
                              setState(() => operator = _orangeMoneySenegal),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Numéro de réception',
                      hintText: 'Ex: 77XXXXXXX',
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 15),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],

                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: const Color(0xff0b5260),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _OperatorCard extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _OperatorCard({
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
          border:
              Border.all(color: selected ? color : Colors.transparent, width: 2),
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
