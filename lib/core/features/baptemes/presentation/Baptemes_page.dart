import 'package:dental_app/core/features/auth/providers/auth_provider.dart';
import 'package:dental_app/core/features/baptemes/presentation/widgets/add_baptem_modal.dart';
import 'package:dental_app/core/features/baptemes/presentation/widgets/baptem_list.dart';
import 'package:dental_app/core/features/members/data/data_remote_source.dart';
import 'package:dental_app/core/features/members/data/member_repository_impl.dart';
import 'package:dental_app/core/features/members/domain/usecases/get_my_member.dart';
import 'package:dental_app/core/helpers/api_client.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  bool _checkingAccess = true;
  bool _hasAccess = false;

  List<Baptism> get filteredBaptisms => baptisms;

  @override
  void initState() {
    super.initState();

    final dataSource = BaptismRemoteDataSource(ApiClient.instance);
    repository = BaptismRepositoryImpl(dataSource);

    getBaptisms = GetBaptisms(repository);
    addBaptism = AddBaptism(repository);
    updateBaptism = UpdateBaptism(repository);
    deleteBaptism = DeleteBaptism(repository);

    _checkAccess();
  }

  /// Le module baptêmes ne concerne que les couples mariés : ADMIN/COMPTABLE
  /// y ont toujours accès, un membre simple seulement si sa fiche est mariée.
  Future<void> _checkAccess() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (auth.canModify || auth.isComptable) {
      setState(() {
        _hasAccess = true;
        _checkingAccess = false;
      });
      _loadBaptisms();
      return;
    }

    final userId = auth.user?.userId;
    bool hasAccess = false;
    if (userId != null) {
      try {
        final memberRepo =
            MemberRepositoryImpl(MemberRemoteDataSource(ApiClient.instance));
        final member = await GetMyMember(memberRepo)(userId);
        hasAccess = member?.isMarried ?? false;
      } catch (_) {
        hasAccess = false;
      }
    }

    if (!mounted) return;
    setState(() {
      _hasAccess = hasAccess;
      _checkingAccess = false;
    });
    if (hasAccess) _loadBaptisms();
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
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final canManageBaptisms = auth.canModify || auth.isComptable;

    if (_checkingAccess) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasAccess) {
      return Scaffold(
        appBar: CurvedAppBar(
          title: "Baptêmes",
          leading: BackButton(onPressed: () => Navigator.pop(context)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "Ce module est réservé aux membres mariés.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CurvedAppBar(
        title: "Baptêmes",
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      floatingActionButton: canManageBaptisms
          ? FloatingActionButton(
              onPressed: _openAddModal,
              backgroundColor: const Color(0xff0b5260),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: BaptismsList(
                    baptisms: filteredBaptisms,
                    onEdit: canManageBaptisms ? _openEditModal : null,
                    onDelete: canManageBaptisms
                        ? (id) async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmer la suppression'),
                                content: const Text(
                                    'Êtes-vous sûr de vouloir supprimer ce baptême?'),
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
                                await deleteBaptism(id);
                                await _refresh();
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Erreur suppression: $e')),
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
