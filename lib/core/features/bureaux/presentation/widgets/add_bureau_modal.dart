import 'package:dental_app/core/features/bureaux/domain/entity/BureauEntity.dart';
import 'package:flutter/material.dart';

class AddBureauModal extends StatefulWidget {
  final Function(BureauEntity) onSubmit;
  final BureauEntity? bureau;
  final List<String> bureaus;

  const AddBureauModal(
      {super.key, required this.onSubmit, this.bureau, required this.bureaus});

  @override
  State<AddBureauModal> createState() => _AddBureauModalState();
}

class _AddBureauModalState extends State<AddBureauModal> {
  String? selectedBureau;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.bureau != null) {
      selectedBureau = widget.bureau!.bureauId;
      nameController.text = widget.bureau!.name;
      descriptionController.text = widget.bureau!.description;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (selectedBureau == null) return;

    setState(() => _isSaving = true);

    try {
      final bureau = BureauEntity(
        name: nameController.text,
        description: descriptionController.text,
        bureauId: selectedBureau!,
      );
      await widget.onSubmit(bureau);
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
            vertical: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 30),
                    Text(widget.bureau == null ? "Add Bureau" : "Edit Bureau",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    // Bureau dropdown
                    DropdownButtonFormField<String>(
                      value: selectedBureau,
                      items: widget.bureaus
                          .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedBureau = v),
                      decoration: InputDecoration(
                        labelText: "Bureau",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none),
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("Save"),
                      ),
                    )
                  ],
                ),
              ),

              // Close button
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
