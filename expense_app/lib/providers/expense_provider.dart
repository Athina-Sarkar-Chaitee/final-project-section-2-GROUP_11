import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirestoreService service = FirestoreService();

  List<Expense> _items = [];
  List<Expense> get items => _items;

  ExpenseProvider() {
    service.getExpenses().listen((data) {
      _items = data;
      notifyListeners();
    });
  }

  double get total => _items.fold(0, (sum, e) => sum + e.amount);

  Future<void> add(Expense e) => service.addExpense(e);
  Future<void> delete(String id) => service.deleteExpense(id);
}
