import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

class FirestoreService {
  final _col = FirebaseFirestore.instance.collection('expenses');

  Stream<List<Expense>> getExpenses() {
    return _col.snapshots().map((snap) =>
        snap.docs.map((d) => Expense.fromMap(d.id, d.data())).toList()
    );
  }

  Future<void> addExpense(Expense e) => _col.add(e.toMap());
  Future<void> updateExpense(Expense e) => _col.doc(e.id).set(e.toMap());
  Future<void> deleteExpense(String id) => _col.doc(id).delete();
}
