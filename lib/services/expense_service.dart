import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseService {
  final CollectionReference expenses =
      FirebaseFirestore.instance.collection('expenses');

  /// Add new expense
  Future<void> addExpense(Map<String, dynamic> data) async {
    await expenses.add(data);
  }

  /// Delete expense by document ID
  Future<void> deleteExpense(String id) async {
    await expenses.doc(id).delete();
  }

  /// Update expense by document ID
  Future<void> updateExpense(String id, Map<String, dynamic> data) async {
    await expenses.doc(id).update(data);
  }

  /// Get real-time stream of expenses ordered by date (descending)
  Stream<QuerySnapshot> getExpenses() {
    return expenses.orderBy('date', descending: true).snapshots();
  }
}
