import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:flutter/material.dart';

class AddMemberModal extends StatefulWidget {
  final Future<void> Function(Member) onSubmit;
  final Member? member;

  const AddMemberModal({
    super.key,
    required this.onSubmit,
    this.member,
  });

  @override
  State<AddMemberModal> createState() => _AddMemberModalState();
}

class _AddMemberModalState extends State<AddMemberModal> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final carteMembreController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      nameController.text = widget.member!.username;
      phoneController.text = widget.member!.tel;
      addressController.text = widget.member!.addresse;
      carteMembreController.text = widget.member!.carteMembre ?? '';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    carteMembreController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nom et téléphone obligatoires")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final member = Member(
        membreId: widget.member?.membreId ?? null,
        userId: widget.member?.userId ?? null,
        username: nameController.text.trim(),
        tel: phoneController.text.trim(),
        addresse: addressController.text.trim(),
        bureauId: widget.member?.bureauId ?? null,
        posteId: widget.member?.posteId ?? null,
        dateAdhesion: widget.member?.dateAdhesion ?? DateTime.now(),
        carteMembre: carteMembreController.text.trim().isEmpty
            ? null
            : carteMembreController.text.trim(),
      );

      print(
          "Submitting member: ${member.userId}, ${member.username}, ${member.tel}, ${member.addresse}");
      await widget.onSubmit(member);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
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
                      widget.member == null ? "Ajouter Membre" : "Modifier Membre",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xfff08024),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // NAME
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Nom",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // PHONE
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Téléphone",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ADDRESS
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: "Adresse",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // CARTE MEMBRE
                    TextField(
                      controller: carteMembreController,
                      decoration: InputDecoration(
                        labelText: "Carte Membre",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: const Color(0xff0b5260),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Enregistrer"),
                      ),
                    ),
                  ],
                ),
              ),

              // CLOSE BUTTON
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
