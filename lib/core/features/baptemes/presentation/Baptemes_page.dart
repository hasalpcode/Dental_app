import 'package:dental_app/core/features/baptemes/presentation/widgets/add_baptem_modal.dart';
import 'package:dental_app/core/features/baptemes/presentation/widgets/baptem_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:dental_app/core/usecases/curved_appbar.dart';

// DATA
import 'package:dental_app/core/features/baptemes/data/baptem_repository_impl.dart';
import 'package:dental_app/core/features/baptemes/data/baptem_remote_data_source.dart';

// DOMAIN
import 'package:dental_app/core/features/baptemes/domain/entity/bapteme_entity.dart';

import 'package:dental_app/core/features/baptemes/domain/usecases/add_baptem.dart';
import 'package:dental_app/core/features/baptemes/domain/usecases/delete_baptem.dart';
import 'package:dental_app/core/features/baptemes/domain/usecases/get_baptems.dart';
import 'package:dental_app/core/features/baptemes/domain/usecases/update_baptem.dart';

class BaptismPage extends StatefulWidget {
  const BaptismPage({super.key});

  @override
  State<BaptismPage> createState() => _BaptismPageState();
}

class _BaptismPageState extends State<BaptismPage> {
  late final BaptismRepositoryImpl repository;
  late final GetBaptisms getBaptisms;
  late final AddBaptism addBaptism;
  late final UpdateBaptism updateBaptism;
  late final DeleteBaptism deleteBaptism;

  List<Baptism> baptisms = [];
  bool isLoading = true;
  bool isDeleting = false;

  List<Baptism> get filteredBaptisms => baptisms;

  @override
  void initState() {
    super.initState();

    final dataSource = BaptismRemoteDataSource(http.Client());
    repository = BaptismRepositoryImpl(dataSource);

    getBaptisms = GetBaptisms(repository);
    addBaptism = AddBaptism(repository);
    updateBaptism = UpdateBaptism(repository);
    deleteBaptism = DeleteBaptism(repository);

    _loadBaptisms();
  }

  Future<void> _loadBaptisms() async {
    setState(() => isLoading = true);
    try {
      final fetched = await getBaptisms();
      setState(() => baptisms = fetched);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur récupération baptêmes: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _refresh() async {
    await _loadBaptisms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CurvedAppBar(
        title: "Baptêmes",
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddModal,
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: BaptismsList(
                    baptisms: filteredBaptisms,
                    onEdit: _openEditModal,
                    onDelete: (id) async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirmer la suppression'),
                          content: const Text(
                              'Êtes-vous sûr de vouloir supprimer ce baptême?'),
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
                          await deleteBaptism(id);
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

  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBaptismModal(
        baptism: null,
        onSubmit: (b) async {
          try {
            await addBaptism(b);
            await _refresh();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur ajout: $e')),
            );
          }
        },
      ),
    );
  }

  void _openEditModal(Baptism baptism) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBaptismModal(
        baptism: baptism,
        onSubmit: (b) async {
          try {
            await updateBaptism(b);
            await _refresh();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur modification: $e')),
            );
          }
        },
      ),
    );
  }
}
