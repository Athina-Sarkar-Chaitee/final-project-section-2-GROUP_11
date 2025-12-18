import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final nameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  String category = "Food";

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Add Expense")),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: amountCtrl,
              decoration: InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),

            DropdownButton<String>(
              value: category,
              items: ["Food","Transport","Shopping","Bills","Other"]
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => category = v!),
            ),

            ElevatedButton(
              child: Text("Save"),
              onPressed: () {
                provider.add(
                  Expense(
                    id: "",
                    name: nameCtrl.text,
                    amount: double.parse(amountCtrl.text),
                    date: DateTime.now(),
                    category: category,
                    description: "",
                    createdAt: DateTime.now(),
                  ),
                );
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
