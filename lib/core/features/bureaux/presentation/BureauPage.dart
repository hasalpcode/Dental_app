import 'package:dental_app/core/features/auth/providers/auth_provider.dart';
import 'package:dental_app/core/features/bureaux/data/bureau_remote_data_source.dart';
import 'package:dental_app/core/features/bureaux/data/bureau_repository_impl.dart';
import 'package:dental_app/core/features/bureaux/domain/entity/BureauEntity.dart';
import 'package:dental_app/core/features/bureaux/domain/usecases/add_bureau.dart';
import 'package:dental_app/core/features/bureaux/domain/usecases/delete_bureau.dart';
import 'package:dental_app/core/features/bureaux/domain/usecases/get_bureaux.dart';
import 'package:dental_app/core/features/bureaux/domain/usecases/update_bureau.dart';
import 'package:dental_app/core/features/bureaux/presentation/BureauDetailPage.dart';
import 'package:dental_app/core/features/bureaux/presentation/widgets/add_bureau_modal.dart';
import 'package:dental_app/core/features/bureaux/presentation/widgets/bureaux_list.dart';
import 'package:dental_app/core/helpers/api_client.dart';
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

  List<BureauEntity> bureaux = [];
  bool isLoading = false;
  bool isDeleting = false;
  String? error;

  @override
  void initState() {
    super.initState();
    repository = BureauRepositoryImpl(BureauRemoteDataSource(ApiClient.instance));
    getBureaux = GetBureaux(repository);
    addBureau = AddBureau(repository);
    updateBureau = UpdateBureau(repository);
    deleteBureau = DeleteBureau(repository);
    _loadBureaux();
  }

  Future<void> _loadBureaux() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data = await getBureaux();
      if (mounted) setState(() => bureaux = data);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canModify =
        Provider.of<AuthProvider>(context, listen: false).canModify;

    return Scaffold(
      appBar: const CurvedAppBar(title: "Bureaux"),
      floatingActionButton: canModify
          ? FloatingActionButton(
              onPressed: _openAddModal,
              backgroundColor: const Color(0xff0b5260),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadBureaux,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(error!,
                                style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _loadBureaux,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff0b5260),
                                  foregroundColor: Colors.white),
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    : BureauxList(
                        bureaux: bureaux,
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
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Supprimer'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed ?? false) {
                                  setState(() => isDeleting = true);
                                  try {
                                    await deleteBureau(id);
                                    await _loadBureaux();
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text('Erreur: $e')));
                                    }
                                  } finally {
                                    if (mounted)
                                      setState(() => isDeleting = false);
                                  }
                                }
                              }
                            : null,
                      ),
          ),
          if (isDeleting)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
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
      builder: (_) => AddBureauModal(
        bureau: null,
        onSubmit: (b) async {
          await addBureau(b);
          await _loadBureaux();
        },
      ),
    );
  }

  void _openEditModal(BureauEntity bureau) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBureauModal(
        bureau: bureau,
        onSubmit: (b) async {
          await updateBureau(b);
          await _loadBureaux();
        },
      ),
    );
  }
}
