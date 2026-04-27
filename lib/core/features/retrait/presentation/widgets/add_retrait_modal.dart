import 'package:dental_app/core/features/retrait/domain/entity/retrait_entity.dart';
import 'package:flutter/material.dart';

class AddRetraitModal extends StatefulWidget {
  final Function(RetraitEntity) onSubmit;
  final RetraitEntity? retrait;
  final List<String> members;

  const AddRetraitModal({
    super.key,
    required this.onSubmit,
    this.retrait,
    required this.members,
  });

  @override
  State<AddRetraitModal> createState() => _AddRetraitModalState();
}

class _AddRetraitModalState extends State<AddRetraitModal> {
  String? selectedMember;
  final amountController = TextEditingController();
  final motifController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.retrait != null) {
      selectedMember = widget.members[widget.retrait!.caissierId - 1];

      amountController.text = widget.retrait!.montant.toString();
      motifController.text = widget.retrait!.motif;
      selectedDate = widget.retrait!.dateRetrait ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    motifController.dispose();
    super.dispose();
  }

  int _memberToId(String name) {
    return widget.members.indexOf(name) + 1;
  }

  Future<void> _submit() async {
    if (selectedMember == null ||
        amountController.text.isEmpty ||
        motifController.text.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final retrait = RetraitEntity(
        retraitId:
            widget.retrait?.retraitId ?? DateTime.now().millisecondsSinceEpoch,
        caissierId: _memberToId(selectedMember!),
        motif: motifController.text,
        montant: double.tryParse(amountController.text) ?? 0,
        dateRetrait: selectedDate,
      );

      await widget.onSubmit(retrait);
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
                      widget.retrait == null
                          ? "Ajout Retrait"
                          : "Modifier Retrait",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // MEMBER
                    DropdownButtonFormField<String>(
                      value: selectedMember,
                      items: widget.members
                          .map((m) => DropdownMenuItem(
                                value: m,
                                child: Text(m),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedMember = v),
                      decoration: InputDecoration(
                        labelText: "Caissier",
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

                    // MOTIF
                    TextField(
                      controller: motifController,
                      decoration: InputDecoration(
                        labelText: "Motif",
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
                          child: const Text("Date"),
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
