import 'package:dental_app/core/features/baptemes/data/baptem_repository_impl.dart';
import 'package:dental_app/core/features/baptemes/data/baptem_remote_data_source.dart';
import 'package:dental_app/core/features/baptemes/domain/entity/bapteme_entity.dart';
import 'package:dental_app/core/features/baptemes/domain/usecases/get_onebaptem.dart';
import 'package:dental_app/core/features/members/data/data_remote_source.dart';
import 'package:dental_app/core/features/members/data/member_repository_impl.dart';
import 'package:dental_app/core/features/members/domain/usecases/get_members.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BaptismDetailPage extends StatefulWidget {
  final String baptismId;

  const BaptismDetailPage({super.key, required this.baptismId});

  @override
  State<BaptismDetailPage> createState() => _BaptismDetailPageState();
}

class _BaptismDetailPageState extends State<BaptismDetailPage> {
  late final Future<_BaptismDetailData> detailFuture;

  @override
  void initState() {
    super.initState();
    detailFuture = _loadDetailData();
  }

  Future<_BaptismDetailData> _loadDetailData() async {
    final baptismRepo =
        BaptismRepositoryImpl(BaptismRemoteDataSource(http.Client()));
    final getBaptismById = GetBaptismById(baptismRepo);

    final memberRepo =
        MemberRepositoryImpl(MemberRemoteDataSource(http.Client()));
    final getMembers = GetMembers(memberRepo);

    final baptism = await getBaptismById(widget.baptismId);
    final members = await getMembers();

    final memberNames = <int, String>{};
    for (final member in members) {
      if (member.membreId != null) {
        memberNames[member.membreId!] = member.username;
      }
    }

    return _BaptismDetailData(baptism, memberNames);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails du baptême')),
      body: FutureBuilder<_BaptismDetailData>(
        future: detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur récupération : ${snapshot.error}'),
            );
          }

          final data = snapshot.data!;
          final baptism = data.baptism;
          final memberNames = data.memberNames;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text("Lieu: ${baptism.lieu}"),
              Text("Date de création: ${_formatDate(baptism.dateCreation)}"),
              const SizedBox(height: 20),
              const Text(
                "Cotisations",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...baptism.contributions.map((c) {
                final memberName =
                    memberNames[c.membreId] ?? 'Membre #${c.membreId}';
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(memberName),
                  subtitle: Text('ID: ${c.membreId}'),
                  trailing: Text("${c.montant} €"),
                );
              }),
              const SizedBox(height: 20),
              Text(
                "Total: ${_total(baptism)} €",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime d) {
    return "${d.day}/${d.month}/${d.year}";
  }

  double _total(Baptism baptism) {
    return baptism.contributions.fold(0, (sum, c) => sum + c.montant);
  }
}

class _BaptismDetailData {
  final Baptism baptism;
  final Map<int, String> memberNames;

  _BaptismDetailData(this.baptism, this.memberNames);
}
