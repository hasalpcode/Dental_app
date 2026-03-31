import 'package:dental_app/core/features/bureaux/data/bureau_local_data_source.dart';
import 'package:dental_app/core/features/bureaux/data/bureau_repository_impl.dart';
import 'package:dental_app/core/features/bureaux/domain/entity/BureauEntity.dart';
import 'package:dental_app/core/features/bureaux/domain/usecases/add_bureau.dart';
import 'package:dental_app/core/features/bureaux/domain/usecases/delete_bureau.dart';
import 'package:dental_app/core/features/bureaux/domain/usecases/get_bureaux.dart';
import 'package:dental_app/core/features/bureaux/domain/usecases/update_bureau.dart';
import 'package:dental_app/core/features/bureaux/presentation/widgets/add_bureau_modal.dart';
import 'package:dental_app/core/features/bureaux/presentation/widgets/bureaux_list.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';
import 'package:flutter/material.dart';

class BureauPage extends StatefulWidget {
  const BureauPage({super.key});

  @override
  State<BureauPage> createState() => _BureauPageState();
}

class _BureauPageState extends State<BureauPage> {
  late final BureauRepositoryImpl repository;
  late final GetBureaux getBureaux;
  late final AddBureau addBureau;
  late final UpdateBureau updateBureau;
  late final DeleteBureau deleteBureau;

  late List<BureauEntity> bureaux;

  List<BureauEntity> get filteredBureaux {
    return bureaux;
  }

  @override
  void initState() {
    super.initState();
    final dataSource = BureauLocalDataSource();
    repository = BureauRepositoryImpl(dataSource);

    getBureaux = GetBureaux(repository);
    addBureau = AddBureau(repository);
    updateBureau = UpdateBureau(repository);
    deleteBureau = DeleteBureau(repository);

    bureaux = getBureaux();
  }

  void _refresh() {
    setState(() => bureaux = getBureaux());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CurvedAppBar(title: "Bureaux"),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddModal,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // 🔹 Filtre mois / année

          // 🔹 Liste filtrée
          Expanded(
            child: BureauxList(
              bureaux: filteredBureaux,
              onEdit: _openEditModal,
              onDelete: (id) {
                deleteBureau(id);
                _refresh();
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Modal ajout
  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBureauModal(
        bureau: null,
        bureaus: ["Bureau A", "Bureau B", "Bureau C"],
        onSubmit: (p) {
          addBureau(p);
          _refresh();
        },
      ),
    );
  }

  // 🔹 Modal édition
  void _openEditModal(BureauEntity bureau) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBureauModal(
        bureau: bureau,
        bureaus: ["Bureau A", "Bureau B", "Bureau C"],
        onSubmit: (p) {
          updateBureau(p);
          _refresh();
        },
      ),
    );
  }
}
