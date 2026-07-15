import 'package:dental_app/core/features/auth/providers/auth_provider.dart';
import 'package:dental_app/core/features/baptemes/presentation/Baptemes_page.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';
import 'package:dental_app/core/features/payments/data/payment_remote_data_source.dart';
import 'package:dental_app/core/features/payments/data/payment_repository_impl.dart';
import 'package:dental_app/core/features/payments/domain/usecases/get_payments.dart';
import 'package:dental_app/core/features/members/data/data_remote_source.dart';
import 'package:dental_app/core/features/members/data/member_repository_impl.dart';
import 'package:dental_app/core/features/members/domain/usecases/get_members.dart';
import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/retrait/data/retrait_remote_data_source.dart';
import 'package:dental_app/core/features/retrait/data/retrait_repository_impl.dart';
import 'package:dental_app/core/features/retrait/domain/entity/retrait_entity.dart';
import 'package:dental_app/core/features/retrait/domain/usecases/get_retraits.dart';
import 'package:dental_app/core/helpers/api_client.dart';
import 'package:dental_app/core/helpers/date_helpers.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedYear = DateTime.now().year;

  late final PaymentRepositoryImpl paymentRepository;
  late final MemberRepositoryImpl memberRepository;
  late final RetraitRepositoryImpl retraitRepository;
  late final GetPayments getPayments;
  late final GetMembers getMembers;
  late final GetRetraits getRetraits;

  List<PaymentEntity> payments = [];
  List<Member> members = [];
  List<RetraitEntity> retraits = [];

  int totalMembers = 0;
  double totalBalance = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final client = ApiClient.instance;

    paymentRepository = PaymentRepositoryImpl(PaymentRemoteDataSource(client));
    memberRepository = MemberRepositoryImpl(MemberRemoteDataSource(client));
    retraitRepository = RetraitRepositoryImpl(RetraitRemoteDataSource(client));

    getPayments = GetPayments(paymentRepository);
    getMembers = GetMembers(memberRepository);
    getRetraits = GetRetraits(retraitRepository);

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      final results = await Future.wait([
        getPayments(),
        getMembers(),
        getRetraits(),
      ]);

      payments = results[0] as List<PaymentEntity>;
      members = results[1] as List<Member>;
      retraits = results[2] as List<RetraitEntity>;

      totalMembers = members.length;
      final totalVersements =
          payments.fold(0.0, (sum, p) => sum + p.montant);
      final totalRetraits =
          retraits.fold(0.0, (sum, r) => sum + r.montant);
      totalBalance = totalVersements - totalRetraits;
    } catch (e) {
      debugPrint("Erreur chargement dashboard: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  List<double> _getMonthlyData(int year) {
    List<double> monthlyTotals = List.generate(12, (_) => 0);

    for (var payment in payments) {
      final paymentYear = payment.dateVersement?.year ?? year;
      if (paymentYear != year) continue;

      int? monthIndex;
      if (payment.dateVersement != null) {
        monthIndex = payment.dateVersement!.month - 1;
      } else {
        // Fallback: use mois string ("1".."12")
        final moisInt = int.tryParse(payment.mois);
        if (moisInt != null && moisInt >= 1 && moisInt <= 12) {
          monthIndex = moisInt - 1;
        }
      }

      if (monthIndex != null) {
        monthlyTotals[monthIndex] += payment.montant;
      }
    }

    return monthlyTotals;
  }

  Set<int> get _payingMembersThisMonth {
    final now = DateTime.now();
    return payments
        .where((p) {
          final d = p.dateVersement;
          return d != null && d.year == now.year && d.month == now.month;
        })
        .expand((p) => p.membreId)
        .toSet();
  }

  double get _participationRate {
    if (members.isEmpty) return 0;
    return _payingMembersThisMonth.length / members.length;
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: CurvedAppBar(
        title: "DÉNTAL",
        option: auth.user != null
            ? "$_greeting, ${auth.user!.username}"
            : null,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: Column(
                          children: [
                            _FadeSlideIn(child: _buildStatsRow()),
                            const SizedBox(height: 16),
                            _FadeSlideIn(
                              delayMs: 80,
                              child: _buildParticipationCard(),
                            ),
                            const SizedBox(height: 16),
                            _FadeSlideIn(
                              delayMs: 160,
                              child: _buildPaymentChart(),
                            ),
                            const SizedBox(height: 20),
                            _FadeSlideIn(
                              delayMs: 240,
                              child: _buildBaptemeBanner(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  // 🔹 STATS
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard("Membres", totalMembers.toString(), Icons.people,
              const Color(0xfff08024)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard("Solde", "${totalBalance.toStringAsFixed(0)} FCFA",
              Icons.account_balance_wallet, const Color(0xff0b5260)),
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                maxLines: 1,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ),
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  // 🔹 TAUX DE PARTICIPATION
  Widget _buildParticipationCard() {
    final rate = _participationRate;
    final payingCount = _payingMembersThisMonth.length;
    final now = DateTime.now();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Cotisations de ${monthNameFr(now.month)}",
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                "${(rate * 100).toStringAsFixed(0)}%",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xfff08024),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: rate.clamp(0, 1),
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor:
                  const AlwaysStoppedAnimation(Color(0xfff08024)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            totalMembers == 0
                ? "Aucun membre enregistré"
                : "$payingCount sur $totalMembers membres à jour",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // 🔹 CHART AVEC FILTRE
  Widget _buildPaymentChart() {
    final data = _getMonthlyData(selectedYear);
    final double total = data.fold(0, (sum, v) => sum + v);
    final double maxY =
        data.isEmpty ? 1000 : (data.reduce((a, b) => a > b ? a : b) * 1.2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER + FILTRE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Versements mensuels",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<int>(
                  value: selectedYear,
                  underline: const SizedBox(),
                  items: List.generate(4, (i) => DateTime.now().year - i)
                      .map((year) => DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedYear = value!),
                ),
              )
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Total $selectedYear : ${total.toStringAsFixed(0)} FCFA",
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),

          const SizedBox(height: 16),

          // 📊 BAR CHART
          if (data.every((v) => v == 0))
            SizedBox(
              height: 220,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text(
                      "Aucun paiement pour $selectedYear",
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY > 0 ? maxY : 1000,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: const Color(0xff0b5260),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          "${monthNameFr(group.x.toInt() + 1)}\n",
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: "${rod.toY.toStringAsFixed(0)} FCFA",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            frenchMonthAbbreviations[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                  barGroups: List.generate(data.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data[index],
                          width: 14,
                          borderRadius: BorderRadius.circular(6),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xfff08024),
                              Color(0xff0b5260),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        )
                      ],
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 🔹 BAPTÊMES (seul module qui n'a pas d'onglet dans le menu)
  Widget _buildBaptemeBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BaptismPage()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff0b5260), Color(0xff137a8f)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.church_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Baptêmes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Gérer les baptêmes et contributions",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

// 🔹 Petite animation d'entrée en fondu + glissement pour le dashboard
class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int delayMs;

  const _FadeSlideIn({required this.child, this.delayMs = 0});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.05),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
