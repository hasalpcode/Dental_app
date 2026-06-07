import 'package:dental_app/core/features/bureaux/presentation/BureauPage.dart';
import 'package:dental_app/core/features/members/presentation/MembersPage.dart';
import 'package:dental_app/core/features/payments/presentation/PaymentsPage.dart';
import 'package:dental_app/core/features/projects/presentation/ProjectsPage.dart';
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
    BureauPage(),
    ProjectsPage(),
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
              icon: Icon(Icons.home_rounded, color: Colors.black),
              label: "Accueil"),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_alt, color: Colors.black),
              label: "Membres"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.black),
              label: "Finance"),
          BottomNavigationBarItem(
              icon: Icon(Icons.corporate_fare, color: Colors.black),
              label: "Bureaux"),
          BottomNavigationBarItem(
              icon: Icon(Icons.folder_special_rounded, color: Colors.black),
              label: "Projets"),
        ],
      ),
    );
  }
}
