import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRefineSearchExpense extends StatefulWidget {
  const AdminRefineSearchExpense({Key? key}) : super(key: key);

  @override
  _AdminRefineSearchExpenseState createState() =>
      _AdminRefineSearchExpenseState();
}

class _AdminRefineSearchExpenseState extends State<AdminRefineSearchExpense> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedItem2;
  final List<String> _items2 = ['Ascending(Date)', 'Descending(Date)'];

  TextEditingController _expenseTitleController = TextEditingController();
  TextEditingController _expenseDescriptionController = TextEditingController();
  TextEditingController _expenseDateController = TextEditingController();
  TextEditingController _expenseAmountController = TextEditingController();

  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Expense Add Edit',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('Expense Title'),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _expenseTitleController,
                    decoration: const InputDecoration(
                      hintText: 'Expense Title',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Expense Title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('Expense Description'),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _expenseDescriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Expense Description',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Expense Description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //from date
                  const Text(
                    'Expense Date',
                    style: TextStyle(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _expenseDateController,
                    obscureText: false,
                    decoration: const InputDecoration(
                      hintText: 'From Date',
                      hintStyle: TextStyle(
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.green,
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Expense Date';
                      }
                      return null;
                    },
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2102),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _expenseDateController.text =
                              pickedDate.toLocal().toString().split(' ')[0];
                        });
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('Expense Amount'),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _expenseAmountController,
                    decoration: const InputDecoration(
                      hintText: 'Expense Amount',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Expense Amount';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _isUploading
          ? FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {},
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
          : FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  uploadExpenseDetails();
                }
              },
              child: const Icon(
                Icons.check,
                color: Colors.green,
              ),
            ),
    );
  }

  void uploadExpenseDetails() async {
    try {
      setState(() {
        _isUploading = true;
      });

      // Add your logic to upload data to Firestore
      await FirebaseFirestore.instance.collection('expense').add({
        'title': _expenseTitleController.text,
        'description': _expenseDescriptionController.text,
        'date': _expenseDateController.text,
        'amount': _expenseAmountController.text,
      });

      // Clear form fields after successful upload
      _formKey.currentState?.reset();
      _expenseTitleController.clear();
      _expenseDescriptionController.clear();
      _expenseDateController.clear();
      _expenseAmountController.clear();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Expense Uploaded'),
            content: const Text('Expense details uploaded successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to upload expense details: $error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}
