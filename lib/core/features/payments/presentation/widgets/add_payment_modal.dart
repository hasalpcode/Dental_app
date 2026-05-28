import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';
import 'package:flutter/material.dart';

class AddPaymentModal extends StatefulWidget {
  final Function(PaymentEntity) onSubmit;
  final PaymentEntity? payment;
  final List<Member> members;

  const AddPaymentModal({
    super.key,
    required this.onSubmit,
    this.payment,
    required this.members,
  });

  @override
  State<AddPaymentModal> createState() => _AddPaymentModalState();
}

class _AddPaymentModalState extends State<AddPaymentModal> {
  int? selectedMemberId;
  final amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.payment != null) {
      selectedMemberId = widget.payment!.membreId.isNotEmpty
          ? widget.payment!.membreId.first
          : null;
      amountController.text = widget.payment!.montant.toString();
      selectedDate = widget.payment!.dateVersement ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (selectedMemberId == null || amountController.text.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final payment = PaymentEntity(
        id: widget.payment?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        membreId: [selectedMemberId!],
        mois: "${selectedDate.month}",
        montant: double.tryParse(amountController.text) ?? 0,
        dateVersement: selectedDate,
      );

      await widget.onSubmit(payment);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 10),
            ],
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 30),

                    Text(
                      widget.payment == null
                          ? "Ajouter Paiement"
                          : "Modifier Paiement",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // MEMBER
                    DropdownButtonFormField<int>(
                      value: selectedMemberId,
                      items: widget.members
                          .where((m) => m.membreId != null)
                          .map((m) => DropdownMenuItem(
                                value: m.membreId,
                                child: Text(m.displayName),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedMemberId = v),
                      decoration: InputDecoration(
                        labelText: "Membre",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // AMOUNT
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Montant",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // DATE
                    Row(
                      children: [
                        Text(
                          "Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );

                            if (picked != null) {
                              setState(() => selectedDate = picked);
                            }
                          },
                          child: const Text("Choisir la date"),
                        )
                      ],
                    ),

                    const SizedBox(height: 25),

                    // SAVE
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("Enregistrer"),
                      ),
                    ),
                  ],
                ),
              ),

              // CLOSE
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
