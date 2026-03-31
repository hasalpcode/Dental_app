import 'package:dental_app/core/features/baptemes/data/baptem_repository_impl.dart';
import 'package:dental_app/core/features/baptemes/data/data_source_local_baptem.dart';
import 'package:dental_app/core/features/baptemes/domain/entity/bapteme_entity.dart';
import 'package:dental_app/core/features/baptemes/domain/usecases/get_onebaptem.dart';
import 'package:flutter/material.dart';

class BaptismDetailPage extends StatefulWidget {
  final String baptismId;

  const BaptismDetailPage({super.key, required this.baptismId});

  @override
  State<BaptismDetailPage> createState() => _BaptismDetailPageState();
}

class _BaptismDetailPageState extends State<BaptismDetailPage> {
  late GetBaptismById getDetails;
  late Baptism baptism;

  @override
  void initState() {
    super.initState();

    final repo = BaptismRepositoryImpl(BaptismLocalDataSource());
    getDetails = GetBaptismById(repo);

    baptism = getDetails(widget.baptismId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(baptism.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Lieu: ${baptism.location}"),
          Text("Date: ${_formatDate(baptism.date)}"),

          const SizedBox(height: 20),

          const Text(
            "Cotisations",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          ...baptism.contributions.map((c) {
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(c.member.name),
              subtitle: Text(c.member.email),
              trailing: Text("${c.amount} €"),
            );
          }),

          const SizedBox(height: 20),

          // 🔥 BONUS : total cotisations
          Text(
            "Total: ${_total()} €",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return "${d.day}/${d.month}/${d.year}";
  }

  double _total() {
    return baptism.contributions.fold(0, (sum, c) => sum + c.amount);
  }
}
