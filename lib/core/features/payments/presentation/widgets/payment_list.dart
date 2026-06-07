import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:flutter/material.dart';
import 'payment_tile.dart';

class PaymentsList extends StatefulWidget {
  final List<PaymentEntity> payments;
  final Map<int, Member> memberMap;
  final Function(PaymentEntity)? onEdit;
  final Function(String)? onDelete;
  final String searchQuery;

  const PaymentsList({
    super.key,
    required this.payments,
    required this.memberMap,
    this.onEdit,
    this.onDelete,
    this.searchQuery = '',
  });

  @override
  State<PaymentsList> createState() => _PaymentsListState();
}

class _PaymentsListState extends State<PaymentsList> {
  static const int _pageSize = 10;
  int _currentPage = 0;

  List<PaymentEntity> get _filtered {
    if (widget.searchQuery.isEmpty) return widget.payments;
    final query = widget.searchQuery.toLowerCase();
    return widget.payments.where((payment) {
      final memberId =
          payment.membreId.isNotEmpty ? payment.membreId[0] : null;
      if (memberId == null) return false;
      final member = widget.memberMap[memberId];
      if (member == null) return false;
      return member.username.toLowerCase().contains(query) ||
          (member.carteMembre?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  void didUpdateWidget(PaymentsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.payments != widget.payments ||
        oldWidget.searchQuery != widget.searchQuery) {
      _currentPage = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final totalPages = (filtered.length / _pageSize).ceil();
    final safePage = totalPages == 0 ? 0 : _currentPage.clamp(0, totalPages - 1);

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            widget.searchQuery.isEmpty
                ? 'Aucun paiement'
                : 'Aucun paiement trouvé pour "${widget.searchQuery}"',
          ),
        ),
      );
    }

    final start = safePage * _pageSize;
    final end = (start + _pageSize).clamp(0, filtered.length);
    final pageItems = filtered.sublist(start, end);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            itemCount: pageItems.length,
            itemBuilder: (_, i) {
              final p = pageItems[i];
              return PaymentTile(
                payment: p,
                memberMap: widget.memberMap,
                onEdit: widget.onEdit != null ? () => widget.onEdit!(p) : null,
                onDelete: widget.onDelete != null
                    ? () {
                        final id = p.id;
                        if (id != null && id.isNotEmpty) {
                          widget.onDelete!(id);
                        }
                      }
                    : null,
              );
            },
          ),
        ),
        if (totalPages > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: safePage > 0
                      ? () => setState(() => _currentPage = safePage - 1)
                      : null,
                ),
                Text(
                  '${safePage + 1} / $totalPages',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: safePage < totalPages - 1
                      ? () => setState(() => _currentPage = safePage + 1)
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
