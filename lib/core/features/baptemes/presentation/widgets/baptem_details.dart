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
        memberNames[member.membreId!] = member.displayName;
      }
    }

    return _BaptismDetailData(baptism, memberNames);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du baptême'),
        backgroundColor: const Color(0xfff08024),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
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
              // Info card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xfff08024),
                            child: Icon(Icons.church, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              baptism.nomComplet,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Color(0xfff08024)),
                        const SizedBox(width: 8),
                        Text("Lieu : ${baptism.lieu}"),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: Color(0xfff08024)),
                        const SizedBox(width: 8),
                        Text("Date : ${_formatDate(baptism.dateCreation)}"),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Cotisations",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...baptism.contributions.map((c) {
                final memberName =
                    memberNames[c.membreId] ?? 'Membre #${c.membreId}';
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6)
                    ],
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xff0b5260),
                      child: Icon(Icons.person, color: Colors.white, size: 18),
                    ),
                    title: Text(memberName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Text(
                      "${c.montant} Fcfa",
                      style: const TextStyle(
                          color: Color(0xfff08024),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xfff08024), Color(0xfff5a050)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total collecté",
                        style: TextStyle(
                            color: Colors.white70, fontWeight: FontWeight.w500)),
                    Text(
                      "${_total(baptism).toStringAsFixed(0)} Fcfa",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
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
