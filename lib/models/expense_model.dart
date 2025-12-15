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

  /// Convert Firestore document to Expense object
  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      name: data['name'],
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      category: data['category'],
      description: data['description'],
    );
  }

  /// Convert Expense object to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'date': date,
      'category': category,
      'description': description,
      'createdAt': DateTime.now(),
    };
  }
}
