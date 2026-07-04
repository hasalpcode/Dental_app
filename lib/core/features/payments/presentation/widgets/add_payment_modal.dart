import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';
import 'package:dental_app/core/helpers/date_helpers.dart';
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
  final memberSearchController = TextEditingController();
  TextEditingController? _autocompleteController;
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
    memberSearchController.dispose();
    super.dispose();
  }

  Member? get _selectedMember {
    for (final m in widget.members) {
      if (m.membreId == selectedMemberId) return m;
    }
    return null;
  }

  Member? _findMemberByDisplayName(String text) {
    for (final m in widget.members) {
      if (m.displayName == text) return m;
    }
    return null;
  }

  Future<void> _submit() async {
    if (selectedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Recherchez et sélectionnez un membre')),
      );
      return;
    }
    if (amountController.text.isEmpty) return;

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
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                        color: Color(0xfff08024),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // MEMBER (recherche par numéro de carte ou nom)
                    Autocomplete<Member>(
                      initialValue: TextEditingValue(
                        text: _selectedMember?.displayName ?? '',
                      ),
                      displayStringForOption: (m) => m.displayName,
                      optionsBuilder: (TextEditingValue value) {
                        final query = value.text.trim().toLowerCase();
                        if (query.isEmpty) return const Iterable<Member>.empty();
                        return widget.members.where((m) =>
                            (m.carteMembre?.toLowerCase().contains(query) ??
                                false) ||
                            m.username.toLowerCase().contains(query));
                      },
                      onSelected: (Member selection) {
                        setState(() => selectedMemberId = selection.membreId);
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                        if (_autocompleteController != controller) {
                          _autocompleteController = controller;
                          controller.addListener(() {
                            final match =
                                _findMemberByDisplayName(controller.text.trim());
                            if (match?.membreId != selectedMemberId) {
                              setState(() => selectedMemberId = match?.membreId);
                            }
                          });
                        }
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: "Numéro de carte ou nom du membre",
                            hintText: "Tapez le numéro de carte...",
                            prefixIcon: const Icon(Icons.badge_outlined),
                            suffixIcon: selectedMemberId != null
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : null,
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(15),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxHeight: 220, maxWidth: 320),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.person_outline,
                                        color: Color(0xfff08024)),
                                    title: Text(option.displayName),
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
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
                          "Date: ${formatDateFr(selectedDate)}",
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xfff08024),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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
                          backgroundColor: const Color(0xff0b5260),
                          foregroundColor: Colors.white,
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
