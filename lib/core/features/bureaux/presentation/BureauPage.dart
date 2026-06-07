import 'package:dental_app/core/features/auth/providers/auth_provider.dart';
import 'package:dental_app/core/features/bureaux/data/bureau_local_data_source.dart';
import 'package:dental_app/core/features/bureaux/data/bureau_repository_impl.dart';
import 'package:dental_app/core/features/bureaux/domain/entity/BureauEntity.dart';
import 'package:dental_app/core/features/bureaux/domain/usecases/add_bureau.dart';
import 'package:dental_app/core/features/bureaux/domain/usecases/delete_bureau.dart';
import 'package:dental_app/core/features/bureaux/domain/usecases/get_bureaux.dart';
import 'package:dental_app/core/features/bureaux/domain/usecases/update_bureau.dart';
import 'package:dental_app/core/features/bureaux/presentation/BureauDetailPage.dart';
import 'package:dental_app/core/features/bureaux/presentation/widgets/add_bureau_modal.dart';
import 'package:dental_app/core/features/bureaux/presentation/widgets/bureaux_list.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  bool isDeleting = false;

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
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final canModify = auth.canModify;

    return Scaffold(
      appBar: const CurvedAppBar(title: "Bureaux"),
      floatingActionButton: canModify
          ? FloatingActionButton(
              onPressed: _openAddModal,
              child: const Icon(Icons.add),
            )
          : null,
      body: Stack(
        children: [
          Column(
            children: [
              // 🔹 Filtre mois / année

              // 🔹 Liste filtrée
              Expanded(
                child: BureauxList(
                  bureaux: filteredBureaux,
                  onDetails: (bureau) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BureauDetailPage(bureau: bureau),
                      ),
                    );
                  },
                  onEdit: canModify ? _openEditModal : null,
                  onDelete: canModify
                      ? (id) async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmer la suppression'),
                              content: const Text(
                                  'Êtes-vous sûr de vouloir supprimer ce bureau?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
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
                              deleteBureau(id);
                              _refresh();
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erreur: $e')),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => isDeleting = false);
                              }
                            }
                          }
                        }
                      : null,
                ),
              ),
            ],
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

  // 🔹 Modal ajout
  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBureauModal(
        bureau: null,
        bureaus: [1, 2, 3],
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
      builder: (_) => BureauDetailPage(bureau: bureau),
      // AddBureauModal(
      //   bureau: bureau,
      //   bureaus: ["Bureau A", "Bureau B", "Bureau C"],
      //   onSubmit: (p) {
      //     updateBureau(p);
      //     _refresh();
      //   },
      // ),
    );
  }
}
