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
  String sortOption = 'date_desc'; // Options: date_desc, amount_desc, amount_asc

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

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: service.getExpenses(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                // Filter by category (safe, case-insensitive)
                docs = docs.where((doc) {
                  final cat = (doc['category'] ?? 'Other').toString();
                  return filterCategory == 'All' ||
                      cat.toLowerCase() == filterCategory.toLowerCase();
                }).toList();

                // Search filter
                if (searchQuery.isNotEmpty) {
                  docs = docs
                      .where((doc) => (doc['name'] ?? '')
                          .toString()
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                      .toList();
                }

                // Sorting
                docs.sort((a, b) {
                  switch (sortOption) {
                    case 'amount_desc':
                      return (b['amount'] as num)
                          .compareTo(a['amount'] as num);
                    case 'amount_asc':
                      return (a['amount'] as num)
                          .compareTo(b['amount'] as num);
                    case 'date_desc':
                    default:
                      return (b['date'] as Timestamp)
                          .compareTo(a['date'] as Timestamp);
                  }
                });

                // Totals
                double total = 0;
                Map<String, double> categoryTotals = {};

                for (var doc in docs) {
                  double amt = (doc['amount'] ?? 0).toDouble();
                  total += amt;
                  String cat = (doc['category'] ?? 'Other');
                  categoryTotals[cat] = (categoryTotals[cat] ?? 0) + amt;
                }

                if (docs.isEmpty) {
                  return const Center(child: Text('No expenses found'));
                }

                return Column(
                  children: [
                    // Total card
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Card(
                        color: Colors.blue[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Expense: ৳ ${total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: categoryTotals.entries.map((e) {
                                  return Chip(
                                    backgroundColor: Colors.blue[100],
                                    label: Text(
                                      '${e.key}: ৳ ${e.value.toStringAsFixed(2)}',
                                    ),
                                  );
                                }).toList(),
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

                            // LEFT → RIGHT (EDIT)
                            background: Container(
                              color: Colors.green,
                              alignment: Alignment.centerLeft,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                            ),

                            // RIGHT → LEFT (DELETE)
                            secondaryBackground: Container(
                              color: Colors.redAccent,
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),

                            direction: DismissDirection.horizontal,

                            confirmDismiss: (direction) async {
                              if (direction ==
                                  DismissDirection.startToEnd) {
                                // EDIT item
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddExpenseScreen(
                                      expenseId: doc.id,
                                      initialData: doc,
                                    ),
                                  ),
                                );
                                return false;
                              } else {
                                // DELETE CONFIRMATION
                                return await showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title:
                                        const Text('Delete Expense'),
                                    content: const Text(
                                        'Are you sure you want to delete this expense?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },

                            onDismissed: (_) async {
                              await service.deleteExpense(doc.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Expense deleted')),
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
                                  doc['name'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(doc['category'] ?? 'Other'),
                                trailing: Text(
                                  '৳ ${(doc['amount'] ?? 0).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Filter by Category'),
        content: SizedBox(
          width: double.maxFinite,
          height: 250, // Fixed height to avoid Web intrinsic error
          child: ListView(
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

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sort Expenses'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile(
                  title: const Text('Date (Newest first)'),
                  value: 'date_desc',
                  groupValue: sortOption,
                  onChanged: (_) {
                    setState(() => sortOption = 'date_desc');
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: const Text('Amount (High → Low)'),
                  value: 'amount_desc',
                  groupValue: sortOption,
                  onChanged: (_) {
                    setState(() => sortOption = 'amount_desc');
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: const Text('Amount (Low → High)'),
                  value: 'amount_asc',
                  groupValue: sortOption,
                  onChanged: (_) {
                    setState(() => sortOption = 'amount_asc');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
