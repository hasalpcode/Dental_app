import 'package:dental_app/core/features/baptemes/domain/entity/bapteme_entity.dart';
import 'package:dental_app/core/features/baptemes/domain/entity/contribution.dart';
import 'package:dental_app/core/features/members/data/member_model.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/presentation/bloc/members_cubit.dart';
import 'package:dental_app/core/helpers/date_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final _nomController = TextEditingController();
  final _lieuController = TextEditingController();
  final _montantController = TextEditingController();

  DateTime? _dateCreation;
  List<Member> _members = [];
  List<Contribution> _contributions = [];
  int? _selectedMemberId;
  bool _isSaving = false;
  bool _isEditing = false;
  bool _loadingMembers = false;

  @override
  void initState() {
    super.initState();
    if (widget.baptism != null) {
      _nomController.text = widget.baptism!.nomComplet;
      _lieuController.text = widget.baptism!.lieu;
      _dateCreation = widget.baptism!.dateCreation;
      _contributions = List.from(widget.baptism!.contributions);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cached = context.read<MembersCubit>().state.members;
      if (cached.isNotEmpty) {
        setState(() => _members = cached.where((m) => m.membreId != null).toList());
      } else {
        _fetchMembers();
      }
    });
  }

  Future<void> _fetchMembers() async {
    setState(() => _loadingMembers = true);
    try {
      await context.read<MembersCubit>().loadMembers();
      if (mounted) {
        setState(() {
          _members = context
              .read<MembersCubit>()
              .state
              .members
              .where((m) => m.membreId != null)
              .toList();
        });
      }
    } finally {
      if (mounted) setState(() => _loadingMembers = false);
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _lieuController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  double get _total => _contributions.fold(0, (s, c) => s + c.montant);

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _handle(),
            _header(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section(Icons.info_outline_rounded, 'Informations'),
                    const SizedBox(height: 14),
                    _textField(_nomController, 'Nom complet', Icons.person_outline),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _textField(_lieuController, 'Lieu', Icons.location_on_outlined),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _dateTile()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _section(Icons.people_outline_rounded, 'Contributions',
                        badge: _contributions.isEmpty
                            ? null
                            : '${_total.toStringAsFixed(0)} FCFA'),
                    const SizedBox(height: 14),
                    _contributionForm(),
                    const SizedBox(height: 14),
                    _contributionList(),
                    const SizedBox(height: 24),
                    _saveButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header widgets ─────────────────────────────────────────────────────────

  Widget _handle() => Container(
        margin: const EdgeInsets.only(top: 10, bottom: 4),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _header() => Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff0b5260), Color(0xff137a8f)],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.church_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              widget.baptism == null ? 'Ajouter Baptême' : 'Modifier Baptême',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      );

  // ── Section separator ──────────────────────────────────────────────────────

  Widget _section(IconData icon, String title, {String? badge}) => Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xff0b5260)),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xff0b5260),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: Colors.grey[200], thickness: 1.5)),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xfff08024).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Color(0xfff08024),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      );

  // ── Form fields ────────────────────────────────────────────────────────────

  Widget _textField(TextEditingController ctrl, String label, IconData icon) =>
      TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: Colors.grey[500]),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      );

  Widget _dateTile() => InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: _dateCreation != null
                    ? const Color(0xff0b5260)
                    : Colors.grey[500],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _dateCreation == null
                      ? 'Date baptême'
                      : formatDateFr(_dateCreation!),
                  style: TextStyle(
                    color: _dateCreation == null ? Colors.grey[500] : Colors.black87,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );

  // ── Contribution form ──────────────────────────────────────────────────────

  Widget _contributionForm() {
    if (_loadingMembers) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_members.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[300], size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Aucun membre disponible.',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        DropdownButtonFormField<int>(
          value: _selectedMemberId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Membre',
            prefixIcon: Icon(Icons.person_search_outlined,
                size: 20, color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          items: _members
              .map((m) => DropdownMenuItem(
                    value: m.membreId,
                    child: Text(m.displayName, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _selectedMemberId = v),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _montantController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Montant FCFA',
                  prefixIcon: Icon(Icons.payments_outlined,
                      size: 20, color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                ElevatedButton(
                  onPressed: _addContribution,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    backgroundColor: _isEditing
                        ? const Color(0xff0b5260)
                        : const Color(0xfff08024),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_isEditing ? Icons.check : Icons.add, size: 18),
                      const SizedBox(width: 4),
                      Text(_isEditing ? 'Màj' : 'Ajouter'),
                    ],
                  ),
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _cancelEdit,
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ── Contribution list ──────────────────────────────────────────────────────

  Widget _contributionList() {
    if (_contributions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(Icons.group_add_outlined, size: 32, color: Colors.grey[300]),
            const SizedBox(height: 6),
            Text('Aucune contribution',
                style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ],
        ),
      );
    }

    return Column(
      children: [
        ..._contributions.map((c) => _contributionTile(c)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Total : ',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            Text(
              '${_total.toStringAsFixed(0)} FCFA',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xff0b5260),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _contributionTile(Contribution c) {
    final name = _memberName(c.membreId);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xff0b5260).withOpacity(0.1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Color(0xff0b5260),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                overflow: TextOverflow.ellipsis),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xfff08024).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${c.montant.toStringAsFixed(0)} FCFA',
              style: const TextStyle(
                color: Color(0xfff08024),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 4),
          _iconBtn(Icons.edit_outlined, const Color(0xff0b5260),
              () => _editContribution(c)),
          _iconBtn(Icons.delete_outline, Colors.red[400]!, () {
            setState(() {
              _contributions.remove(c);
              if (_selectedMemberId == c.membreId) _cancelEdit();
            });
          }),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: 18),
        ),
      );

  Widget _saveButton() => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff0b5260),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text('Enregistrer',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      );

  // ── Logic ──────────────────────────────────────────────────────────────────

  String _memberName(int id) {
    final m = _members.firstWhere(
      (m) => m.membreId == id,
      orElse: () => MemberModel(
          membreId: id, userId: null, name: 'Membre #$id', phone: '', addresse: ''),
    );
    return m.displayName;
  }

  void _addContribution() {
    if (_selectedMemberId == null || _montantController.text.isEmpty) return;
    final montant =
        double.tryParse(_montantController.text.replaceAll(',', '.'));
    if (montant == null || montant <= 0) return;

    if (!_isEditing &&
        _contributions.any((c) => c.membreId == _selectedMemberId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ce membre est déjà ajouté.')),
      );
      return;
    }

    setState(() {
      _contributions
          .add(Contribution(membreId: _selectedMemberId!, montant: montant));
      _selectedMemberId = null;
      _isEditing = false;
      _montantController.clear();
    });
  }

  void _editContribution(Contribution c) {
    setState(() {
      _contributions.remove(c);
      _selectedMemberId = c.membreId;
      _montantController.text = c.montant.toString();
      _isEditing = true;
    });
  }

  void _cancelEdit() {
    setState(() {
      _selectedMemberId = null;
      _isEditing = false;
      _montantController.clear();
    });
  }

  Future<void> _submit() async {
    if (_nomController.text.isEmpty ||
        _lieuController.text.isEmpty ||
        _dateCreation == null) return;

    setState(() => _isSaving = true);
    try {
      await widget.onSubmit(Baptism(
        id: widget.baptism?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        nomComplet: _nomController.text.trim(),
        lieu: _lieuController.text.trim(),
        dateCreation: _dateCreation!,
        contributions: List.from(_contributions),
      ));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateCreation ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dateCreation = picked);
  }
}
