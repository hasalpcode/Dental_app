import 'package:dental_app/core/features/baptemes/data/baptem_repository_impl.dart';
import 'package:dental_app/core/features/baptemes/data/baptem_remote_data_source.dart';
import 'package:dental_app/core/features/baptemes/domain/entity/bapteme_entity.dart';
import 'package:dental_app/core/features/baptemes/domain/usecases/get_onebaptem.dart';
import 'package:dental_app/core/features/members/data/data_remote_source.dart';
import 'package:dental_app/core/features/members/data/member_repository_impl.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/usecases/get_members.dart';
import 'package:dental_app/core/helpers/api_client.dart';
import 'package:dental_app/core/helpers/date_helpers.dart';
import 'package:flutter/material.dart';

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
        BaptismRepositoryImpl(BaptismRemoteDataSource(ApiClient.instance));
    final getBaptismById = GetBaptismById(baptismRepo);

    final memberRepo =
        MemberRepositoryImpl(MemberRemoteDataSource(ApiClient.instance));
    final getMembers = GetMembers(memberRepo);

    final results = await Future.wait([
      getBaptismById(widget.baptismId),
      getMembers(),
    ]);
    final baptism = results[0] as Baptism;
    final members = results[1] as List<Member>;

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Cotisations",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${baptism.contributions.length} contributeur"
                    "${baptism.contributions.length != 1 ? 's' : ''}",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (baptism.contributions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.groups_outlined,
                          size: 40, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('Aucune contribution pour le moment',
                          style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                )
              else
                ...(() {
                  final total = _total(baptism);
                  final sorted = [...baptism.contributions]
                    ..sort((a, b) => b.montant.compareTo(a.montant));
                  return sorted.map((c) {
                    final memberName =
                        memberNames[c.membreId] ?? 'Membre #${c.membreId}';
                    final initial =
                        memberName.isNotEmpty ? memberName[0] : '?';
                    final share = total > 0 ? c.montant / total : 0.0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    const Color(0xff0b5260).withOpacity(0.15),
                                child: Text(
                                  initial.toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xff0b5260),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(memberName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xfff08024)
                                      .withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "${c.montant.toStringAsFixed(0)} Fcfa",
                                  style: const TextStyle(
                                    color: Color(0xfff08024),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: share.clamp(0, 1),
                              minHeight: 6,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation(
                                  Color(0xfff08024)),
                            ),
                          ),
                        ],
                      ),
                    );
                  });
                })(),
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

  String _formatDate(DateTime d) => formatDateFr(d);

  double _total(Baptism baptism) {
    return baptism.contributions.fold(0, (sum, c) => sum + c.montant);
  }
}

class _BaptismDetailData {
  final Baptism baptism;
  final Map<int, String> memberNames;

  _BaptismDetailData(this.baptism, this.memberNames);
}
