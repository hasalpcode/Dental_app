import 'package:flutter/material.dart';
import '../../domain/entity/member.dart';

class MemberTile extends StatelessWidget {
  final Member member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MemberTile({
    super.key,
    required this.member,
    required this.onEdit,
    required this.onDelete,
  });

  Color getAvatarColor(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal
    ];
    return colors[name.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: getAvatarColor(member.name).withOpacity(0.2),
            child: Text(
              member.name[0],
              style: TextStyle(
                fontSize: 22,
                color: getAvatarColor(member.name),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(member.email,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: Colors.orange)),
              IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red)),
            ],
          )
        ],
      ),
    );
  }
}
