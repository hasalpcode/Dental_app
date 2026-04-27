import 'package:dental_app/core/features/bureaux/presentation/BureauPage.dart';
import 'package:dental_app/core/features/members/presentation/MembersPage.dart';
import 'package:dental_app/core/features/payments/presentation/PaymentsPage.dart';
import 'package:dental_app/core/features/projects/presentation/ProjectsPage.dart';
import 'package:dental_app/core/features/retrait/presentation/RetraitPage.dart';
import 'package:dental_app/core/usecases/HomePage.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;

  final pages = const [
    HomePage(),
    MembersPage(),
    PaymentsPage(),
    RetraitPage(),
    ProjectsPage(),
    BureauPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        selectedItemColor: Colors.deepPurple,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard, color: Colors.black), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.people, color: Colors.black), label: "Members"),
          BottomNavigationBarItem(
              icon: Icon(Icons.payment, color: Colors.black),
              label: "Payments"),
          BottomNavigationBarItem(
              icon: Icon(Icons.money_off, color: Colors.black),
              label: "Retraits"),
          BottomNavigationBarItem(
              icon: Icon(Icons.work, color: Colors.black), label: "Projects"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance, color: Colors.black),
              label: "Bureau"),
        ],
      ),
    );
  }
}
