import 'package:flutter/material.dart';

class CurvedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CurvedAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff6A11CB), Color(0xff2575FC)],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  // SizedBox(height: 4),
                  // Text("Manage your association",
                  //     style: TextStyle(color: Colors.white70)),
                ],
              ),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black87),
              )
            ],
          ),
        ),
      ),
    );
  }
}
