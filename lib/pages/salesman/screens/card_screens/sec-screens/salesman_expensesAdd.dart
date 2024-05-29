import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SalesManUploadExpenseScreen extends StatefulWidget {
  const SalesManUploadExpenseScreen({Key? key}) : super(key: key);

  @override
  _SalesManUploadExpenseScreenState createState() =>
      _SalesManUploadExpenseScreenState();
}

class _SalesManUploadExpenseScreenState
    extends State<SalesManUploadExpenseScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _expenseTitleController = TextEditingController();
  TextEditingController _expenseDescriptionController = TextEditingController();
  TextEditingController _expenseDateController = TextEditingController();
  TextEditingController _expenseAmountController = TextEditingController();

  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload Expense Details',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text('Expense Title'),
                const SizedBox(height: 10),
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
                const SizedBox(height: 20),
                const Text('Expense Description'),
                const SizedBox(height: 10),
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
                const SizedBox(height: 20),
                const Text('Expense Date'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _expenseDateController,
                  decoration: const InputDecoration(
                    hintText: 'Expense Date',
                    prefixIcon: Icon(Icons.calendar_today),
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
                const SizedBox(height: 20),
                const Text('Expense Amount'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _expenseAmountController,
                  decoration: const InputDecoration(
                    hintText: 'Expense Amount',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Expense Amount';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                _isUploading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            uploadExpenseDetails();
                          }
                        },
                        child: const Text('Upload Expense'),
                      ),
              ],
            ),
          ),
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
