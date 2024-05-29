// search_expense_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SalesManSearchExpenseScreen extends StatefulWidget {
  const SalesManSearchExpenseScreen({super.key});

  @override
  _SalesManSearchExpenseScreenState createState() =>
      _SalesManSearchExpenseScreenState();
}

class _SalesManSearchExpenseScreenState
    extends State<SalesManSearchExpenseScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Stream<QuerySnapshot> _searchResultsStream;

  @override
  void initState() {
    super.initState();
    _searchResultsStream =
        FirebaseFirestore.instance.collection('expense').snapshots();
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      _searchResultsStream = FirebaseFirestore.instance
          .collection('expense')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title',
              isLessThan: '${query}z') // For case-insensitive search
          .snapshots();
    } else {
      // If the search query is empty, show all expenses
      _searchResultsStream =
          FirebaseFirestore.instance.collection('expense').snapshots();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Expenses'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by title',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _performSearch(_searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _searchResultsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No expenses found.'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final expense = snapshot.data!.docs[index];
                      return ListTile(
                        title: Text(expense['title']),
                        subtitle: Text('Amount: ${expense['amount']}'),
                        onTap: () {
                          // Implement the action when a search result is tapped
                          // For example, navigate to the expense details screen
                          // Navigator.push(context, MaterialPageRoute(builder: (context) {
                          //   return ExpenseDetailsScreen(expenseId: expense.id);
                          // }));
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
