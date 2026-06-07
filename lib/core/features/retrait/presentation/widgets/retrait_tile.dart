import 'package:flutter/material.dart';
import 'package:dental_app/core/features/retrait/domain/entity/retrait_entity.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';

class RetraitTile extends StatelessWidget {
  final RetraitEntity retrait;
  final Map<int, Member> memberMap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RetraitTile({
    super.key,
    required this.retrait,
    required this.memberMap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final member = memberMap[retrait.caissierId];

    final username = member?.username ?? "Unknown";

    final date = retrait.dateRetrait;

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
            backgroundColor: const Color(0xff0b5260).withOpacity(0.15),
            child: Text(
              username.isNotEmpty ? username[0] : "?",
              style: const TextStyle(
                  color: Color(0xff0b5260), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member?.displayName ?? username,
                    style: TextStyle(fontSize: 13, color: Colors.blue[700])),
                const SizedBox(height: 4),
                Text(
                  "${retrait.montant} Fcfa",
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  retrait.motif,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  date != null ? "${date.day}/${date.month}/${date.year}" : "",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (onEdit != null || onDelete != null)
            Row(
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: onEdit,
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
              ],
            )
        ],
      ),
    );
  }
}
