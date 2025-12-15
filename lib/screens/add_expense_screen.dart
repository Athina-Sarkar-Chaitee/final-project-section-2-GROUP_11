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
          title:
              Text(widget.expenseId != null ? 'Edit Expense' : 'Add Expense'),
          backgroundColor: Colors.blueAccent),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Expense Name',
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: categories
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => category = val!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        amountController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields')),
                      );
                      return;
                    }

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
                  child: Text(
                      widget.expenseId != null ? 'Update Expense' : 'Save Expense',
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
