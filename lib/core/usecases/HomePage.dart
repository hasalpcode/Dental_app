import 'package:dental_app/core/features/auth/providers/auth_provider.dart';
import 'package:dental_app/core/features/baptemes/presentation/Baptemes_page.dart';
import 'package:dental_app/core/helpers/user_storage.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedYear = 2025;

  final Map<int, List<double>> yearlyData = {
    2023: [400, 600, 900, 700, 1000, 800, 1200, 1300, 900, 1100, 1400, 1500],
    2024: [500, 800, 1200, 900, 1400, 1100, 1500, 1700, 1300, 1600, 1800, 2000],
    2025: [
      600,
      900,
      1400,
      1100,
      1500,
      1300,
      1700,
      1900,
      1500,
      1800,
      2000,
      2200
    ],
  };

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      // 🔥 APP BAR
      appBar: CurvedAppBar(
          title: "DÉNTAL",
          option:
              auth.user != null ? "Bienvenue! ${auth.user!.username}" : null),

      // 🔥 BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatsRow(),
            const SizedBox(height: 16),
            _buildPaymentChart(),
            const SizedBox(height: 20),
            _buildSectionTitle("Quick Actions"),
            const SizedBox(height: 12),
            _buildQuickActions(),
            const SizedBox(height: 20),
            _buildSectionTitle("Recent Activity"),
            const SizedBox(height: 12),
            _buildActivityList(),
          ],
        ),
      ),
    );
  }

  // 🔹 STATS
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard("Members", "120", Icons.people, Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard("Balance", "4,500 FCFA",
              Icons.account_balance_wallet, Colors.green),
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
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
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  // 🔹 CHART AVEC FILTRE
  Widget _buildPaymentChart() {
    final data = yearlyData[selectedYear]!;

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
              const Text("Monthly Payments",
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
                  items: yearlyData.keys.map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value!;
                    });
                  },
                ),
              )
            ],
          ),

          const SizedBox(height: 20),

          // 📊 BAR CHART
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 2500,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          "J",
                          "F",
                          "M",
                          "A",
                          "M",
                          "J",
                          "J",
                          "A",
                          "S",
                          "O",
                          "N",
                          "D"
                        ];
                        return Text(months[value.toInt()]);
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
                            Color(0xff6A11CB),
                            Color(0xff2575FC),
                          ],
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

  // 🔹 TITRE
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  // 🔹 QUICK ACTIONS
  Widget _buildQuickActions() {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _actionCard("Members", Icons.people, Colors.blue),
          _actionCard("Payments", Icons.payment, Colors.green),
          _actionCard("Projects", Icons.work, Colors.orange),
          _actionCard("Bureau", Icons.account_balance, Colors.purple),
          _actionCard(
            "Baptêmes",
            Icons.church,
            Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BaptismPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
    String title,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 ACTIVITÉS
  Widget _buildActivityList() {
    final activities = [
      "John paid monthly fee",
      "New member added",
      "Project created",
    ];

    return Column(
      children: activities.map((e) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 5),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.notifications, color: Colors.deepPurple),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(e)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
