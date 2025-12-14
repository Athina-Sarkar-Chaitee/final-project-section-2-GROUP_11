import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddExpenseScreen extends StatefulWidget {
  final String? expenseId;
  final DocumentSnapshot? initialData;

  const AddExpenseScreen({super.key, this.expenseId, this.initialData});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final ExpenseService service = ExpenseService();

  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  String category = 'Food';
  final categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Shopping',
    'Bills',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      nameController.text = widget.initialData!['name'];
      amountController.text = widget.initialData!['amount'].toString();
      category = widget.initialData!['category'];
      descriptionController.text =
          widget.initialData!['description'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.expenseId != null ? 'Edit Expense' : 'Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Expense Name'),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: category,
              items: categories
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => category = val!),
            ),
            TextField(
              controller: descriptionController,
              decoration:
                  const InputDecoration(labelText: 'Description (optional)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final data = {
                  'name': nameController.text,
                  'amount': double.parse(amountController.text),
                  'category': category,
                  'description': descriptionController.text,
                  'date': DateTime.now(),
                  'createdAt': DateTime.now(),
                };

                if (widget.expenseId != null) {
                  await service.updateExpense(widget.expenseId!, data);
                } else {
                  await service.addExpense(data);
                }

                Navigator.pop(context);
              },
              child: Text(widget.expenseId != null ? 'Update Expense' : 'Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
