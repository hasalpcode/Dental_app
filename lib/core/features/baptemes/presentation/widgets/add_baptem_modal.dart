import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dental_app/core/features/baptemes/domain/entity/bapteme_entity.dart';
import 'package:dental_app/core/features/baptemes/domain/entity/contribution.dart';
import 'package:dental_app/core/features/members/data/data_remote_source.dart';
import 'package:dental_app/core/features/members/data/member_model.dart';
import 'package:dental_app/core/features/members/data/member_repository_impl.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/usecases/get_members.dart';

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
  final nomCompletController = TextEditingController();
  final lieuController = TextEditingController();
  final montantController = TextEditingController();
  DateTime? dateCreation;

  List<Member> _members = [];
  List<Contribution> _contributions = [];
  int? _selectedMemberId;
  bool _isSaving = false;
  late final Future<void> _membersFuture;

  @override
  void initState() {
    super.initState();

    if (widget.baptism != null) {
      nomCompletController.text = widget.baptism!.nomComplet;
      lieuController.text = widget.baptism!.lieu;
      dateCreation = widget.baptism!.dateCreation;
      _contributions = List.from(widget.baptism!.contributions);
    }

    _membersFuture = _loadMembers();
  }

  Future<void> _loadMembers() async {
    final repo = MemberRepositoryImpl(MemberRemoteDataSource(http.Client()));
    final getMembers = GetMembers(repo);
    final members = await getMembers();
    setState(() {
      _members = members.where((m) => m.membreId != null).toList();
    });
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
                    TextField(
                      controller: nomCompletController,
                      decoration: _inputDecoration("Nom complet"),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: lieuController,
                      decoration: _inputDecoration("Lieu"),
                    ),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 15),
                        decoration: _boxDecoration(),
                        child: Text(
                          dateCreation == null
                              ? "Choisir une date"
                              : _formatDate(dateCreation!),
                          style: TextStyle(
                            color: dateCreation == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Contributions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<void>(
                      future: _membersFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (_members.isEmpty) {
                          return const Text(
                            'Aucun membre disponible. Rechargez la page ou vérifiez la connexion.',
                            style: TextStyle(color: Colors.red),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DropdownButtonFormField<int>(
                              value: _selectedMemberId,
                              decoration: _inputDecoration('Membre'),
                              items: _members
                                  .map((member) => DropdownMenuItem(
                                        value: member.membreId,
                                        child: Text(member.username),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedMemberId = value;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: montantController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: false,
                              ),
                              decoration: _inputDecoration('Montant FCFA'),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _addContribution,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text('Ajouter contribution'),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    if (_contributions.isEmpty)
                      const Text('Aucune contribution ajoutée.')
                    else
                      Column(
                        children: _contributions.map((contribution) {
                          final memberName = _memberName(contribution.membreId);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(memberName),
                              subtitle: Text('ID: ${contribution.membreId}'),
                              trailing: Text(
                                  '${contribution.montant.toStringAsFixed(2)} FCFA'),
                              leading: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _contributions.remove(contribution);
                                  });
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 25),
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

  String _memberName(int membreId) {
    final member = _members.firstWhere(
      (m) => m.membreId == membreId,
      orElse: () => MemberModel(
        membreId: membreId,
        userId: null,
        name: 'Membre #$membreId',
        phone: '',
        address: '',
      ),
    );
    return member.username;
  }

  void _addContribution() {
    if (_selectedMemberId == null || montantController.text.isEmpty) {
      return;
    }

    final montant =
        double.tryParse(montantController.text.replaceAll(',', '.'));
    if (montant == null || montant <= 0) return;

    if (_contributions.any((c) => c.membreId == _selectedMemberId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ce membre est déjà ajouté.')),
      );
      return;
    }

    setState(() {
      _contributions.add(
        Contribution(
          membreId: _selectedMemberId!,
          montant: montant,
        ),
      );
      _selectedMemberId = null;
      montantController.clear();
    });
  }

  void _submit() async {
    if (nomCompletController.text.isEmpty ||
        lieuController.text.isEmpty ||
        dateCreation == null) return;

    setState(() => _isSaving = true);

    try {
      final baptism = Baptism(
        id: widget.baptism?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        nomComplet: nomCompletController.text,
        lieu: lieuController.text,
        dateCreation: dateCreation!,
        contributions: List.from(_contributions),
      );

      await widget.onSubmit(baptism);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateCreation ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => dateCreation = picked);
    }
  }

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
