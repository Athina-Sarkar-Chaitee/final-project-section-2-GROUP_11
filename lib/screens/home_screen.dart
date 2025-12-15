import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/expense_service.dart';
import '../services/auth_service.dart';
import 'add_expense_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExpenseService service = ExpenseService();
  final AuthService authService = AuthService();

  String searchQuery = '';
  String filterCategory = 'All';
  bool sortByAmount = false;
  bool sortByDate = true;

  final categories = [
    'All',
    'Food',
    'Transport',
    'Entertainment',
    'Shopping',
    'Bills',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Colors.blueAccent,
        actions: [
          // 🔴 LOGOUT BUTTON (STEP 5)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),

          // Expense list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: service.getExpenses(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                // Filter by category
                if (filterCategory != 'All') {
                  docs = docs
                      .where((doc) => doc['category'] == filterCategory)
                      .toList();
                }

                // Search filter
                if (searchQuery.isNotEmpty) {
                  docs = docs
                      .where((doc) => doc['name']
                          .toString()
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                      .toList();
                }

                // Sorting
                docs.sort((a, b) {
                  if (sortByDate) {
                    return (b['date'] as Timestamp)
                        .compareTo(a['date'] as Timestamp);
                  } else if (sortByAmount) {
                    return (b['amount'] as num)
                        .compareTo(a['amount'] as num);
                  }
                  return 0;
                });

                // Totals
                double total = 0;
                Map<String, double> categoryTotals = {};

                for (var doc in docs) {
                  double amt = (doc['amount'] as num).toDouble();
                  total += amt;
                  String cat = doc['category'];
                  categoryTotals[cat] = (categoryTotals[cat] ?? 0) + amt;
                }

                return Column(
                  children: [
                    // Totals card
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Card(
                        color: Colors.blue[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Expense: ৳ $total',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                children: categoryTotals.entries
                                    .map(
                                      (e) => Chip(
                                        backgroundColor: Colors.blue[100],
                                        label: Text(
                                          '${e.key}: ৳ ${e.value.toStringAsFixed(2)}',
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Expense list
                    Expanded(
                      child: ListView(
                        children: docs.map((doc) {
                          return Dismissible(
                            key: Key(doc.id),
                            background: Container(
                              color: Colors.redAccent,
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              service.deleteExpense(doc.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Expense deleted'),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                  doc['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(doc['category']),
                                trailing: Text(
                                  '৳ ${doc['amount']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
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
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Filter Dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Filter by Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: categories.map((cat) {
              return RadioListTile(
                title: Text(cat),
                value: cat,
                groupValue: filterCategory,
                onChanged: (val) {
                  setState(() => filterCategory = val.toString());
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Sort Dialog
  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sort Expenses'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Date (Newest first)'),
              value: 'date',
              groupValue: sortByDate ? 'date' : 'amount',
              onChanged: (val) {
                setState(() {
                  sortByDate = true;
                  sortByAmount = false;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Amount (High to Low)'),
              value: 'amount',
              groupValue: sortByDate ? 'date' : 'amount',
              onChanged: (val) {
                setState(() {
                  sortByDate = false;
                  sortByAmount = true;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
