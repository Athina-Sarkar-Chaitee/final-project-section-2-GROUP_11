import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseService {
  final CollectionReference expenses =
      FirebaseFirestore.instance.collection('expenses');

  // Add expense
  Future<void> addExpense(Map<String, dynamic> data) async {
    await expenses.add(data);
  }

  // Delete expense
  Future<void> deleteExpense(String id) async {
    await expenses.doc(id).delete();
  }

  // Update expense
  Future<void> updateExpense(String id, Map<String, dynamic> data) async {
    await expenses.doc(id).update(data);
  }

  // Stream expenses (real-time)
  Stream<QuerySnapshot> getExpenses() {
    return expenses.orderBy('date', descending: true).snapshots();
  }
}
