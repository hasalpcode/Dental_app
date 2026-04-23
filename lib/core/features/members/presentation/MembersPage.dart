import 'package:dental_app/core/features/members/data/data_remote_source.dart';
import 'package:dental_app/core/features/members/data/member_repository_impl.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/usecases/add_member.dart';
import 'package:dental_app/core/features/members/domain/usecases/delete_member.dart';
import 'package:dental_app/core/features/members/domain/usecases/get_members.dart';
import 'package:dental_app/core/features/members/domain/usecases/update_member.dart';
import 'package:dental_app/core/features/members/presentation/widgets/add_member_modal.dart';
import 'package:dental_app/core/features/members/presentation/widgets/member_list.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  late final MemberRepositoryImpl repository;
  late final GetMembers getMembersUseCase;
  late final AddMember addMemberUseCase;
  late final UpdateMember updateMemberUseCase;
  late final DeleteMember deleteMemberUseCase;

  List<Member> members = [];
  bool isLoading = true;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();

    // Initialisation des sources et repository
    final dataSource = MemberRemoteDataSource(http.Client());
    repository = MemberRepositoryImpl(dataSource);

    getMembersUseCase = GetMembers(repository);
    addMemberUseCase = AddMember(repository);
    updateMemberUseCase = UpdateMember(repository);
    deleteMemberUseCase = DeleteMember(repository);

    // Chargement initial des membres
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => isLoading = true);
    try {
      final fetchedMembers = await getMembersUseCase();
      setState(() {
        members = fetchedMembers;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur récupération membres: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _refresh() async {
    await _loadMembers();
  }

  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMemberModal(
        onSubmit: (m) async {
          try {
            await addMemberUseCase(m);
            await _refresh();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur ajout membre: $e')),
            );
          }
        },
      ),
    );
  }

  void _openEditModal(Member member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMemberModal(
        member: member,
        onSubmit: (m) async {
          try {
            await updateMemberUseCase(m);
            await _refresh();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur modification membre: $e')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CurvedAppBar(title: "Members"),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddModal,
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: MembersList(
                    members: members,
                    onEdit: _openEditModal,
                    onDelete: (id) async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirmer la suppression'),
                          content: const Text(
                              'Êtes-vous sûr de vouloir supprimer ce membre?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Supprimer'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed ?? false) {
                        setState(() => isDeleting = true);
                        try {
                          await deleteMemberUseCase(id);
                          await _refresh();
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur suppression: $e')),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => isDeleting = false);
                          }
                        }
                      }
                    },
                  ),
                ),
          if (isDeleting)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
