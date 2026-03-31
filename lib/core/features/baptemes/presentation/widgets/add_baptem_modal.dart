import 'package:flutter/material.dart';
import 'package:dental_app/core/features/baptemes/domain/entity/bapteme_entity.dart';

class AddBaptismModal extends StatefulWidget {
  final Function(Baptism) onSubmit;
  final Baptism? baptism;

  const AddBaptismModal({
    super.key,
    required this.onSubmit,
    this.baptism,
  });

  @override
  State<AddBaptismModal> createState() => _AddBaptismModalState();
}

class _AddBaptismModalState extends State<AddBaptismModal> {
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();

    if (widget.baptism != null) {
      titleController.text = widget.baptism!.title;
      locationController.text = widget.baptism!.location;
      selectedDate = widget.baptism!.date;
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
                      widget.baptism == null
                          ? "Ajouter Baptême"
                          : "Modifier Baptême",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔹 Title
                    TextField(
                      controller: titleController,
                      decoration: _inputDecoration("Titre"),
                    ),

                    const SizedBox(height: 15),

                    // 🔹 Location
                    TextField(
                      controller: locationController,
                      decoration: _inputDecoration("Lieu"),
                    ),

                    const SizedBox(height: 15),

                    // 🔹 Date picker
                    InkWell(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 15),
                        decoration: _boxDecoration(),
                        child: Text(
                          selectedDate == null
                              ? "Choisir une date"
                              : _formatDate(selectedDate!),
                          style: TextStyle(
                            color: selectedDate == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 🔹 Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text("Save"),
                      ),
                    ),
                  ],
                ),
              ),

              // ❌ Close button
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

  // 🔹 Submit
  void _submit() {
    if (titleController.text.isEmpty ||
        locationController.text.isEmpty ||
        selectedDate == null) return;

    final baptism = Baptism(
      id: widget.baptism?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text,
      location: locationController.text,
      date: selectedDate!,
      contributions: widget.baptism?.contributions ?? [],
    );

    widget.onSubmit(baptism);
    Navigator.pop(context);
  }

  // 🔹 Date picker
  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // 🔹 UI helpers
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(15),
    );
  }

  String _formatDate(DateTime d) {
    return "${d.day}/${d.month}/${d.year}";
  }
}
