import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String id;
  String name;
  double amount;
  DateTime date;
  String category;
  String? description;

  Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
    this.description,
  });

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      name: data['name'],
      amount: data['amount'].toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      category: data['category'],
      description: data['description'],
    );
  }
}

