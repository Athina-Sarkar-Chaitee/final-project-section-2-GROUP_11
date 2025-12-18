import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final items = provider.items;

    return Scaffold(
      appBar: AppBar(
        title: Text("Expenses (${provider.total})"),
      ),

      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i) {
          final e = items[i];
          return ListTile(
            title: Text(e.name),
            subtitle: Text("${e.amount} • ${e.category}"),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => provider.delete(e.id),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddExpenseScreen()),
          );
        },
      ),
    );
  }
}
