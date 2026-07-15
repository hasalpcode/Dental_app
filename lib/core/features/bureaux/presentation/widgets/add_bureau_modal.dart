import 'package:dental_app/core/features/bureaux/domain/entity/BureauEntity.dart';
import 'package:flutter/material.dart';

class AddBureauModal extends StatefulWidget {
  final Function(BureauEntity) onSubmit;
  final BureauEntity? bureau;

  const AddBureauModal({super.key, required this.onSubmit, this.bureau});

  @override
  State<AddBureauModal> createState() => _AddBureauModalState();
}

class _AddBureauModalState extends State<AddBureauModal> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.bureau != null) {
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
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom est obligatoire')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final bureau = BureauEntity(
        bureauId: widget.bureau?.bureauId,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
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
    final isEditing = widget.bureau != null;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
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
                    Text(isEditing ? "Modifier Bureau" : "Ajouter Bureau",
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xfff08024))),
                    const SizedBox(height: 20),

                    // NOM
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Nom du bureau",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // DESCRIPTION
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Description",
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
                            backgroundColor: const Color(0xff0b5260),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("Enregistrer"),
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
