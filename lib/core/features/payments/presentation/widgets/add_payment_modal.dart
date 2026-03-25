import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';
import 'package:flutter/material.dart';

class AddPaymentModal extends StatefulWidget {
  final Function(PaymentEntity) onSubmit;
  final PaymentEntity? payment;
  final List<String> members;

  const AddPaymentModal(
      {super.key, required this.onSubmit, this.payment, required this.members});

  @override
  State<AddPaymentModal> createState() => _AddPaymentModalState();
}

class _AddPaymentModalState extends State<AddPaymentModal> {
  String? selectedMember;
  final amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.payment != null) {
      selectedMember = widget.payment!.memberName;
      amountController.text = widget.payment!.amount.toString();
      selectedDate = widget.payment!.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                        widget.payment == null ? "Add Payment" : "Edit Payment",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    // Member dropdown
                    DropdownButtonFormField<String>(
                      value: selectedMember,
                      items: widget.members
                          .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedMember = v),
                      decoration: InputDecoration(
                        labelText: "Member",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Amount
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Amount",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Date picker
                    Row(
                      children: [
                        Text(
                            "Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null)
                              setState(() => selectedDate = picked);
                          },
                          child: const Text("Pick Date"),
                        )
                      ],
                    ),
                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedMember == null ||
                              amountController.text.isEmpty) return;
                          final payment = PaymentEntity(
                            id: widget.payment?.id ?? DateTime.now().toString(),
                            memberId: selectedMember!,
                            memberName: selectedMember!,
                            amount: double.tryParse(amountController.text) ?? 0,
                            date: selectedDate,
                          );
                          widget.onSubmit(payment);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        child: const Text("Save"),
                      ),
                    )
                  ],
                ),
              ),

              // Close button
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
