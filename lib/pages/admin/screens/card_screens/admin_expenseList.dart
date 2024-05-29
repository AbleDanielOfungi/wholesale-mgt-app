import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wholesense/pages/admin/adminHome.dart';

class AdminExpenseList extends StatefulWidget {
  const AdminExpenseList({Key? key}) : super(key: key);

  @override
  State<AdminExpenseList> createState() => _AdminExpenseListState();
}

class _AdminExpenseListState extends State<AdminExpenseList> {
  double totalExpense = 0.0;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _calculateTotalExpense();
  }

  void _calculateTotalExpense() {
    FirebaseFirestore.instance.collection('expense').get().then((snapshot) {
      double total = 0.0;
      for (var doc in snapshot.docs) {
        total += double.parse(doc['amount']);
      }
      setState(() {
        totalExpense = total;
      });
    });
  }

  void editExpense(String documentId, String newTitle, String newDescription,
      String newDate, String newAmount) {
    FirebaseFirestore.instance.collection('expense').doc(documentId).update({
      'title': newTitle,
      'description': newDescription,
      'date': newDate,
      'amount': newAmount,
    });

    _calculateTotalExpense(); // Update totalExpense after editing
  }

  void deleteExpense(String documentId) {
    FirebaseFirestore.instance.collection('expense').doc(documentId).delete();

    _calculateTotalExpense(); // Update totalExpense after deleting
  }

  Future<void> _refresh() async {
    try {
      QuerySnapshot<Object?> querySnapshot =
          await FirebaseFirestore.instance.collection('expense').get();

      _calculateTotalExpense(); // Update totalExpense after refreshing
    } catch (error) {
      print('Error refreshing data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AdminHome();
                }));
              },
              child: const Icon(Icons.arrow_circle_left_outlined),
            ),
            const Text('Expense List'),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: ExpenseSearchDelegate());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('expense').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                totalExpense = 0.0;
                final filteredExpenses = snapshot.data!.docs.where((expense) {
                  final title = expense['title'].toString().toLowerCase();
                  final description =
                      expense['description'].toString().toLowerCase();
                  final date = expense['date'].toString().toLowerCase();
                  final amount = expense['amount'].toString().toLowerCase();
                  return title.contains(searchQuery.toLowerCase()) ||
                      description.contains(searchQuery.toLowerCase()) ||
                      date.contains(searchQuery.toLowerCase()) ||
                      amount.contains(searchQuery.toLowerCase());
                }).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Record')),
                      DataColumn(label: Text('Title')),
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: filteredExpenses.asMap().entries.map((entry) {
                      final int rowIndex = entry.key + 1;
                      final QueryDocumentSnapshot<Object?> expense =
                          entry.value;
                      totalExpense += double.parse(expense['amount']);
                      return DataRow(cells: [
                        DataCell(Text('$rowIndex')),
                        DataCell(Text(expense['title'])),
                        DataCell(Text(expense['description'])),
                        DataCell(Text(expense['date'])),
                        DataCell(Text(expense['amount'])),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showEditDialog(
                                    expense.id,
                                    expense['title'],
                                    expense['description'],
                                    expense['date'],
                                    expense['amount'],
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  deleteExpense(expense.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //admin expense
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const AdminExpenseList();
          }));
        },
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.add,
          color: Colors.green,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Total Expense:',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  Text(' UGX ${totalExpense.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showEditDialog(String documentId, String currentTitle,
      String currentDescription, String currentDate, String currentAmount) {
    TextEditingController titleController =
        TextEditingController(text: currentTitle);
    TextEditingController descriptionController =
        TextEditingController(text: currentDescription);
    TextEditingController dateController =
        TextEditingController(text: currentDate);
    TextEditingController amountController =
        TextEditingController(text: currentAmount);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Expense'),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Date'),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                editExpense(
                  documentId,
                  titleController.text,
                  descriptionController.text,
                  dateController.text,
                  amountController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class RefineSearchExpense extends StatelessWidget {
  const RefineSearchExpense({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refine Search Expense'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: RefineSearchExpense(),
    );
  }
}

class ExpenseSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('expense').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
          final filteredExpenses = snapshot.data!.docs.where((expense) {
            final title = expense['title'].toString().toLowerCase();
            final description = expense['description'].toString().toLowerCase();
            final date = expense['date'].toString().toLowerCase();
            final amount = expense['amount'].toString().toLowerCase();
            return title.contains(query.toLowerCase()) ||
                description.contains(query.toLowerCase()) ||
                date.contains(query.toLowerCase()) ||
                amount.contains(query.toLowerCase());
          }).toList();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Record')),
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Amount')),
              ],
              rows: filteredExpenses.asMap().entries.map((entry) {
                final int rowIndex = entry.key + 1;
                final QueryDocumentSnapshot<Object?> expense = entry.value;
                return DataRow(cells: [
                  DataCell(Text('$rowIndex')),
                  DataCell(Text(expense['title'])),
                  DataCell(Text(expense['description'])),
                  DataCell(Text(expense['date'])),
                  DataCell(Text(expense['amount'])),
                ]);
              }).toList(),
            ),
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('expense').get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
          final titles = snapshot.data!.docs
              .map<String>((expense) => expense['title'].toString())
              .toList();

          final suggestionList = titles
              .where(
                  (title) => title.toLowerCase().contains(query.toLowerCase()))
              .toList();

          return ListView.builder(
            itemCount: suggestionList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(suggestionList[index]),
                onTap: () {
                  query = suggestionList[index];
                  showResults(context);
                },
              );
            },
          );
        }
      },
    );
  }
}
