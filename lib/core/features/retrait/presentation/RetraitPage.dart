import 'package:dental_app/core/features/members/data/data_remote_source.dart';
import 'package:dental_app/core/features/retrait/data/retrait_remote_data_source.dart';
import 'package:dental_app/core/features/retrait/data/retrait_repository_impl.dart';
import 'package:dental_app/core/features/retrait/domain/entity/retrait_entity.dart';
import 'package:dental_app/core/features/retrait/domain/usecases/add_retrait.dart';
import 'package:dental_app/core/features/retrait/domain/usecases/delete_retrait.dart';
import 'package:dental_app/core/features/retrait/domain/usecases/get_retraits.dart';
import 'package:dental_app/core/features/retrait/domain/usecases/update_retrait.dart';
import 'package:dental_app/core/features/retrait/presentation/bloc/retrait_cubit.dart';
import 'package:dental_app/core/features/retrait/presentation/bloc/retrait_state.dart';
import 'package:dental_app/core/features/retrait/presentation/widgets/add_retrait_modal.dart';
import 'package:dental_app/core/features/retrait/presentation/widgets/retrait_list.dart';
import 'package:dental_app/core/features/members/domain/usecases/get_members.dart';
import 'package:dental_app/core/features/members/data/member_repository_impl.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class RetraitPage extends StatefulWidget {
  const RetraitPage({super.key});

  @override
  State<RetraitPage> createState() => _RetraitPageState();
}

class _RetraitPageState extends State<RetraitPage> {
  late final RetraitRepositoryImpl retraitRepository;
  late final MemberRepositoryImpl memberRepository;

  late final GetRetraits getRetraits;
  late final AddRetrait addRetrait;
  late final UpdateRetrait updateRetrait;
  late final DeleteRetrait deleteRetrait;

  late final GetMembers getMembers;
  late final RetraitCubit retraitCubit;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  final List<int> years = List.generate(5, (i) => DateTime.now().year - i);

  @override
  void initState() {
    super.initState();

    final client = http.Client();

    retraitRepository = RetraitRepositoryImpl(
      RetraitRemoteDataSource(client),
    );

    memberRepository = MemberRepositoryImpl(
      MemberRemoteDataSource(client),
    );

    getRetraits = GetRetraits(retraitRepository);
    addRetrait = AddRetrait(retraitRepository);
    updateRetrait = UpdateRetrait(retraitRepository);
    deleteRetrait = DeleteRetrait(retraitRepository);

    getMembers = GetMembers(memberRepository);

    retraitCubit = RetraitCubit(
      getRetraits,
      getMembers,
      addRetrait,
      updateRetrait,
      deleteRetrait,
    );

    retraitCubit.loadData();
  }

  @override
  void dispose() {
    retraitCubit.close();
    super.dispose();
  }

  Future<void> _loadData() async {
    await retraitCubit.loadData();
  }

  List<RetraitEntity> _filteredRetraits(List<RetraitEntity> retraits) {
    return retraits.where((r) {
      final d = r.dateRetrait;
      if (d == null) return false;
      return d.month == selectedMonth && d.year == selectedYear;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: retraitCubit,
      child: BlocBuilder<RetraitCubit, RetraitState>(
        builder: (context, state) {
          return Scaffold(
            appBar: const CurvedAppBar(title: "Retraits"),
            floatingActionButton: FloatingActionButton(
              onPressed: _openAddModal,
              child: const Icon(Icons.add),
            ),
            body: Stack(
              children: [
                state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButton<int>(
                                    value: selectedMonth,
                                    isExpanded: true,
                                    items: List.generate(12, (i) => i + 1)
                                        .map((m) => DropdownMenuItem(
                                              value: m,
                                              child: Text("Mois $m"),
                                            ))
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => selectedMonth = v!),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButton<int>(
                                    value: selectedYear,
                                    isExpanded: true,
                                    items: years
                                        .map((y) => DropdownMenuItem(
                                              value: y,
                                              child: Text("$y"),
                                            ))
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => selectedYear = v!),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: _loadData,
                              child: RetraitList(
                                retraits: _filteredRetraits(state.retraits),
                                memberMap: state.memberMap,
                                onEdit: (r) async {
                                  await context
                                      .read<RetraitCubit>()
                                      .updateRetrait(r);
                                },
                                onDelete: (id) async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                          'Confirmer la suppression'),
                                      content: const Text(
                                          'Êtes-vous sûr de vouloir supprimer ce retrait?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Annuler'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Supprimer'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed ?? false) {
                                    await context
                                        .read<RetraitCubit>()
                                        .deleteRetrait(id);
                                  }
                                },
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

  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddRetraitModal(
        members: retraitCubit.state.members.map((e) => e.username).toList(),
        onSubmit: (r) async {
          await retraitCubit.addRetrait(r);
        },
      ),
    );
  }
}
