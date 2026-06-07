import 'package:dental_app/core/features/auth/providers/auth_provider.dart';
import 'package:dental_app/core/features/bureaux/domain/entity/BureauEntity.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';
import 'package:dental_app/core/features/members/data/data_remote_source.dart';
import 'package:dental_app/core/features/members/data/member_repository_impl.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/usecases/get_members.dart';
import 'package:dental_app/core/features/members/domain/usecases/update_member.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class BureauDetailPage extends StatefulWidget {
  final BureauEntity bureau;

  const BureauDetailPage({
    super.key,
    required this.bureau,
  });

  @override
  State<BureauDetailPage> createState() => _BureauDetailPageState();
}

class _BureauDetailPageState extends State<BureauDetailPage> {
  late final MemberRepositoryImpl repository;
  late final GetMembers getMembers;
  late final UpdateMember updateMember;
  List<Member> allMembers = [];
  List<Member> bureauMembers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final dataSource = MemberRemoteDataSource(http.Client());
    repository = MemberRepositoryImpl(dataSource);
    getMembers = GetMembers(repository);
    updateMember = UpdateMember(repository);
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final members = await getMembers();

      setState(() {
        allMembers = members;
        bureauMembers =
            members.where((m) => m.bureauId == widget.bureau.bureauId).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _openAddMemberModal() async {
    if (allMembers.isEmpty) {
      await _loadMembers();
    }

    if (allMembers.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Aucun membre chargé. Réessayez plus tard.')),
        );
      }
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMemberToBureauModal(
        bureauId: widget.bureau.bureauId,
        allMembers: allMembers,
        bureauMembers: bureauMembers,
        onMemberSelected: (member) async {
          try {
            final updatedMember = Member(
              membreId: member.membreId,
              userId: member.userId,
              username: member.username,
              tel: member.tel,
              address: member.address,
              bureauId: widget.bureau.bureauId,
              posteId: null,
              dateAdhesion: member.dateAdhesion,
              carteMembre: member.carteMembre,
            );
            print(
                "Adding member to bureau with userId: ${updatedMember.bureauId}, posteId: ${updatedMember.posteId}");
            await updateMember(updatedMember);
            await _loadMembers();
            if (mounted) Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Membre ajouté au bureau')),
            );
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _removeMemberFromBureau(Member member) async {
    try {
      final updatedMember = Member(
        membreId: member.membreId,
        userId: member.userId,
        username: member.username,
        tel: member.tel,
        address: member.address,
        bureauId: null,
        posteId: null,
        dateAdhesion: member.dateAdhesion,
        carteMembre: member.carteMembre,
      );
      print("Removing member from bureau with userId: ${updatedMember.userId}");
      await updateMember(updatedMember);
      await _loadMembers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Membre retiré du bureau')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final canModify = auth.canModify;

    return Scaffold(
      appBar: CurvedAppBar(
        title: "Détails Bureau",
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      floatingActionButton: canModify
          ? FloatingActionButton(
              onPressed: isLoading ? null : _openAddMemberModal,
              backgroundColor:
                  isLoading ? Colors.grey : const Color(0xfff08024),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // 🔹 Bureau Details Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor:
                                  const Color(0xff0b5260).withOpacity(0.15),
                              child: Text(
                                widget.bureau.name[0],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff0b5260),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.bureau.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ID: ${widget.bureau.bureauId}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Description:',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.bureau.description,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 🔹 Members Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Membres (${bureauMembers.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 🔹 Members List
                  bureauMembers.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 48,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Aucun membre dans ce bureau',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: bureauMembers.length,
                          itemBuilder: (context, index) {
                            final member = bureauMembers[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor:
                                        const Color(0xff0b5260).withOpacity(0.15),
                                    child: Text(
                                      member.username[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff0b5260),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          member.displayName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          member.tel,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (canModify)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Confirmer'),
                                            content: const Text(
                                              'Retirer ce membre du bureau?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Annuler'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _removeMemberFromBureau(
                                                      member);
                                                },
                                                child: const Text(
                                                  'Retirer',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

class AddMemberToBureauModal extends StatefulWidget {
  final int bureauId;
  final List<Member> allMembers;
  final List<Member> bureauMembers;
  final Function(Member) onMemberSelected;

  const AddMemberToBureauModal({
    super.key,
    required this.bureauId,
    required this.allMembers,
    required this.bureauMembers,
    required this.onMemberSelected,
  });

  @override
  State<AddMemberToBureauModal> createState() => _AddMemberToBureauModalState();
}

class _AddMemberToBureauModalState extends State<AddMemberToBureauModal> {
  late TextEditingController _searchController;
  String _searchQuery = '';

  final List<String> _posteOptions = [
    'Président',
    'Vice-président',
    'Secrétaire',
    'Trésorier',
    'Membre',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Member> get _availableMembers {
    final bureauMemberIds = widget.bureauMembers.map((m) => m.membreId).toSet();
    final available =
        widget.allMembers.where((m) => !bureauMemberIds.contains(m.membreId));

    if (_searchQuery.isEmpty) {
      return available.toList();
    }

    final query = _searchQuery.toLowerCase();
    return available
        .where((m) =>
            m.username.toLowerCase().contains(query) ||
            (m.carteMembre?.toLowerCase().contains(query) ?? false))
        .toList();
  }

  Future<void> _choosePostAndSubmit(Member member) async {
    final updatedMember = await showDialog<Member>(
      context: context,
      builder: (context) {
        String? selectedPoste;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Choisir un poste'),
              content: DropdownButtonFormField<String>(
                value: selectedPoste,
                hint: const Text('Sélectionner un poste'),
                items: _posteOptions
                    .map((poste) => DropdownMenuItem(
                          value: poste,
                          child: Text(poste),
                        ))
                    .toList(),
                onChanged: (value) => setStateDialog(() {
                  selectedPoste = value;
                }),
                decoration: const InputDecoration(
                  labelText: 'Poste',
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: selectedPoste == null
                      ? null
                      : () {
                          final result = Member(
                            membreId: member.membreId,
                            userId: member.userId,
                            username: member.username,
                            tel: member.tel,
                            address: member.address,
                            bureauId: widget.bureauId,
                            posteId: selectedPoste,
                            dateAdhesion: member.dateAdhesion,
                            carteMembre: member.carteMembre,
                          );
                          Navigator.pop(context, result);
                        },
                  child: const Text('Valider'),
                ),
              ],
            );
          },
        );
      },
    );

    if (updatedMember != null) {
      widget.onMemberSelected(updatedMember);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ajouter un membre',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 🔹 Search Bar
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher par nom ou carte membre...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 🔹 Members List
              if (_availableMembers.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'Tous les membres sont déjà dans le bureau'
                          : 'Aucun membre trouvé',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _availableMembers.length,
                  itemBuilder: (context, index) {
                    final member = _availableMembers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color(0xff0b5260).withOpacity(0.15),
                        child: Text(
                          member.username[0].toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0b5260),
                          ),
                        ),
                      ),
                      title: Text(member.displayName),
                      subtitle: Text(member.tel),
                      trailing: const Icon(Icons.add_circle_outline,
                          color: Color(0xfff08024)),
                      onTap: () => _choosePostAndSubmit(member),
                    );
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
