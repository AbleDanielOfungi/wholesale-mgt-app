import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRefineSearch extends StatefulWidget {
  const AdminRefineSearch({Key? key}) : super(key: key);

  @override
  State<AdminRefineSearch> createState() => _AdminRefineSearchState();
}

class _AdminRefineSearchState extends State<AdminRefineSearch> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Dropdown's
  String? _selectedItem;
  final List<String> _items = ['Cash', 'Debit', 'Cash And Debit Both'];

  // Drop down 2
  String? _selectedItem2;

  final List<String> _items2 = ['Ascending(Date)', 'Descending(Date)'];

  bool _isLoading = false;

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _vendorNameController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Perform your form submission logic here
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulate a delay to represent an asynchronous operation
        await Future.delayed(const Duration(seconds: 2));

        // Upload to Firestore
        await FirebaseFirestore.instance.collection('products').add({
          'productName': _productNameController.text,
          'vendorName': _vendorNameController.text,
          'transactionType': _selectedItem,
          'sortingType': _selectedItem2,
        });

        // Clear form fields after successful upload
        _formKey.currentState?.reset();
        _productNameController.clear();
        _vendorNameController.clear();

        setState(() {
          _selectedItem = null;
          _selectedItem2 = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form submitted successfully!'),
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Refine Search',
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
                  const Text('Product Name'),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _productNameController,
                    decoration: const InputDecoration(
                      hintText: 'Product Name',
                      prefixIcon: Icon(Icons.pin_invoke_sharp),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Product Name';
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('Vendor Name'),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _vendorNameController,
                    decoration: const InputDecoration(
                      hintText: 'Vendor Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Vendor Name';
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // From date
                  const Text(
                    'From Date',
                    style: TextStyle(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
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
                        return 'Enter Sales Date';
                      } else {
                        return null;
                      }
                    },
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2102),
                      );
                      if (pickedDate != null) {
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'To Date',
                    style: TextStyle(),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    obscureText: false,
                    decoration: const InputDecoration(
                      hintText: 'To Date',
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
                        return 'Enter Sales Date';
                      } else {
                        return null;
                      }
                    },
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2102),
                      );
                      if (pickedDate != null) {
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Transaction Type',
                    style: TextStyle(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DropdownButtonFormField<String>(
                    icon: const Icon(Icons.arrow_drop_down_outlined,
                        color: Colors.green),
                    value: _selectedItem,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedItem = value;
                      });
                    },
                    items: _items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(color: Colors.green),
                        ),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Select an option',
                      labelStyle: const TextStyle(color: Colors.green),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.green,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Sorting Type',
                    style: TextStyle(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DropdownButtonFormField<String>(
                    icon: const Icon(Icons.arrow_drop_down_outlined,
                        color: Colors.green),
                    value: _selectedItem2,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedItem2 = value;
                      });
                    },
                    items: _items2.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(color: Colors.green),
                        ),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Select an option',
                      labelStyle: const TextStyle(color: Colors.green),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.green,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: _isLoading ? null : _submitForm,
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              )
            : const Icon(
                Icons.check,
                color: Colors.green,
              ),
      ),
    );
  }
}
