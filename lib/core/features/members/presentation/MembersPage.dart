import 'package:dental_app/core/features/members/data/data_remote_source.dart';
import 'package:dental_app/core/features/members/data/member_repository_impl.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/usecases/add_member.dart';
import 'package:dental_app/core/features/members/domain/usecases/delete_member.dart';
import 'package:dental_app/core/features/members/domain/usecases/get_members.dart';
import 'package:dental_app/core/features/members/domain/usecases/update_member.dart';
import 'package:dental_app/core/features/members/presentation/bloc/members_cubit.dart';
import 'package:dental_app/core/features/members/presentation/bloc/members_state.dart';
import 'package:dental_app/core/features/members/presentation/widgets/add_member_modal.dart';
import 'package:dental_app/core/features/members/presentation/widgets/member_list.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:dental_app/core/features/auth/providers/auth_provider.dart';

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
  late final MembersCubit membersCubit;
  late TextEditingController searchController;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchController.addListener(() {
      setState(() => searchQuery = searchController.text);
    });

    final dataSource = MemberRemoteDataSource(http.Client());
    repository = MemberRepositoryImpl(dataSource);

    getMembersUseCase = GetMembers(repository);
    addMemberUseCase = AddMember(repository);
    updateMemberUseCase = UpdateMember(repository);
    deleteMemberUseCase = DeleteMember(repository);

    membersCubit = MembersCubit(
      getMembersUseCase,
      addMemberUseCase,
      updateMemberUseCase,
      deleteMemberUseCase,
    );

    membersCubit.loadMembers();
  }

  @override
  void dispose() {
    searchController.dispose();
    membersCubit.close();
    super.dispose();
  }

  Future<void> _refresh() async {
    await membersCubit.loadMembers();
  }

  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMemberModal(
        onSubmit: (m) async {
          try {
            await membersCubit.addMember(m);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur ajout membre: $e')),
              );
            }
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
            await membersCubit.updateMember(m);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur modification membre: $e')),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: membersCubit,
      child: BlocBuilder<MembersCubit, MembersState>(
        builder: (context, state) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          final canModify = auth.canModify;

          return Scaffold(
            appBar: const CurvedAppBar(title: "Membres"),
            floatingActionButton: canModify
                ? FloatingActionButton(
                    onPressed: _openAddModal,
                    backgroundColor: const Color(0xff0b5260),
                    child: const Icon(Icons.add, color: Colors.white),
                  )
                : null,
            body: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher par nom, téléphone ou carte...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() => searchQuery = '');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: state.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : RefreshIndicator(
                              onRefresh: _refresh,
                              child: MembersList(
                                members: state.members,
                                searchQuery: searchQuery,
                                onEdit: canModify ? _openEditModal : null,
                                onDelete: canModify
                                    ? (id) async {
                                        final confirmed =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                                'Confirmer la suppression'),
                                            content: const Text(
                                                'Êtes-vous sûr de vouloir supprimer ce membre?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text('Annuler'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text('Supprimer'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmed ?? false) {
                                          await context
                                              .read<MembersCubit>()
                                              .deleteMember(id);
                                        }
                                      }
                                    : null,
                              ),
                            ),
                    ),
                  ],
                ),
                if (state.isDeleting)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
