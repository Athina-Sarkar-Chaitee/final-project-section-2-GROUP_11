import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/expense_service.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final ExpenseService service = ExpenseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getExpenses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          double total = 0;
          snapshot.data!.docs.forEach((doc) {
            total += (doc['amount'] as num).toDouble();
          });

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Total Expense: ৳ $total',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return Dismissible(
                      key: Key(doc.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        service.deleteExpense(doc.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Expense deleted')),
                        );
                      },
                      child: ListTile(
                        title: Text(doc['name']),
                        subtitle: Text(doc['category']),
                        trailing: Text('৳ ${doc['amount']}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddExpenseScreen(
                                expenseId: doc.id,
                                initialData: doc,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
