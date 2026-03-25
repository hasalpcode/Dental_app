import 'package:dental_app/core/features/projects/domain/entity/project_entity.dart';
import 'package:flutter/material.dart';

class AddProjectModal extends StatefulWidget {
  final Function(ProjectEntity) onSubmit;
  final ProjectEntity? project;
  final List<String> bureaus;

  const AddProjectModal(
      {super.key, required this.onSubmit, this.project, required this.bureaus});

  @override
  State<AddProjectModal> createState() => _AddProjectModalState();
}

class _AddProjectModalState extends State<AddProjectModal> {
  String? selectedBureau;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      selectedBureau = widget.project!.bureauId;
      nameController.text = widget.project!.name;
      descriptionController.text = widget.project!.description;
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
                    Text(
                        widget.project == null ? "Add Project" : "Edit Project",
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
                        onPressed: () {
                          if (selectedBureau == null) return;
                          final project = ProjectEntity(
                            id: widget.project?.id ?? DateTime.now().toString(),
                            bureauId: selectedBureau!,
                            name: nameController.text,
                            description: descriptionController.text,
                          );
                          widget.onSubmit(project);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        child: const Text("Save"),
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
