import 'package:dental_app/core/features/baptemes/presentation/widgets/add_baptem_modal.dart';
import 'package:dental_app/core/features/baptemes/presentation/widgets/baptem_list.dart';
import 'package:flutter/material.dart';

import 'package:dental_app/core/usecases/curved_appbar.dart';

// DATA
import 'package:dental_app/core/features/baptemes/data/baptem_repository_impl.dart';
import 'package:dental_app/core/features/baptemes/data/data_source_local_baptem.dart';

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

  late List<Baptism> baptisms;

  List<Baptism> get filteredBaptisms => baptisms;

  @override
  void initState() {
    super.initState();

    final dataSource = BaptismLocalDataSource();
    repository = BaptismRepositoryImpl(dataSource);

    getBaptisms = GetBaptisms(repository);
    addBaptism = AddBaptism(repository);
    updateBaptism = UpdateBaptism(repository);
    deleteBaptism = DeleteBaptism(repository);

    baptisms = getBaptisms();
  }

  void _refresh() {
    setState(() {
      baptisms = getBaptisms();
    });
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

      // 🔥 simplifié
      body: BaptismsList(
        baptisms: filteredBaptisms,
        onEdit: _openEditModal,
        onDelete: (id) {
          deleteBaptism(id);
          _refresh();
        },
      ),
    );
  }

  // 🔹 Modal ajout
  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBaptismModal(
        baptism: null,
        onSubmit: (b) {
          addBaptism(b);
          _refresh();
        },
      ),
    );
  }

  // 🔹 Modal édition
  void _openEditModal(Baptism baptism) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBaptismModal(
        baptism: baptism,
        onSubmit: (b) {
          updateBaptism(b);
          _refresh();
        },
      ),
    );
  }
}
