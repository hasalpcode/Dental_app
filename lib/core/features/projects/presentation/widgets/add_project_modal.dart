import 'package:dental_app/core/features/projects/domain/entity/project_entity.dart';
import 'package:flutter/material.dart';

class AddProjectModal extends StatefulWidget {
  final Function(ProjectEntity) onSubmit;
  final ProjectEntity? project;
  final List<int> bureaus; // ✅ IDs bureau

  const AddProjectModal({
    super.key,
    required this.onSubmit,
    this.project,
    required this.bureaus,
  });

  @override
  State<AddProjectModal> createState() => _AddProjectModalState();
}

class _AddProjectModalState extends State<AddProjectModal> {
  int? selectedBureau;

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final budgetController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.project != null) {
      selectedBureau = widget.project!.bureauId;

      nameController.text = widget.project!.libelle;
      descriptionController.text = widget.project!.description ?? '';
      budgetController.text = widget.project!.budget?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    budgetController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (nameController.text.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final project = ProjectEntity(
        projectId: widget.project?.projectId,
        libelle: nameController.text,
        description: descriptionController.text,
        budget: double.tryParse(budgetController.text),
        bureauId: selectedBureau ?? null,
        status: widget.project?.status,
        dateCreation: widget.project?.dateCreation,
      );

      await widget.onSubmit(project);
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
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 30),

                    Text(
                      widget.project == null ? "Add Project" : "Edit Project",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 20),

                    // 🔹 NAME
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Project name",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 🔹 DESCRIPTION
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Description",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 🔹 BUDGET
                    TextField(
                      controller: budgetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Budget",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 🔹 BUREAU
                    DropdownButtonFormField<int>(
                      value: selectedBureau,
                      items: widget.bureaus
                          .map((b) => DropdownMenuItem(
                                value: b,
                                child: Text("Bureau $b"),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedBureau = v),
                      decoration: InputDecoration(
                        labelText: "Bureau",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 🔹 SAVE BUTTON
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
                            : const Text("Save"),
                      ),
                    ),
                  ],
                ),
              ),

              // ❌ CLOSE BUTTON
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
