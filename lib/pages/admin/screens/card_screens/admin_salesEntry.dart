import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSalesEntry extends StatefulWidget {
  static const routeName = "/salesEntry";

  const AdminSalesEntry({Key? key}) : super(key: key);

  @override
  State<AdminSalesEntry> createState() => _AdminSalesEntryState();
}

class _AdminSalesEntryState extends State<AdminSalesEntry> {
  final productNameController = TextEditingController();
  final customerNameController = TextEditingController();
  final salesQuantityController = TextEditingController();
  final salesDateController = TextEditingController();
  final salesPriceController = TextEditingController();

  String? _selectedItem;
  final List<String> _items = ['Cash', 'Debit'];

  List<String> availableProducts = [];
  List<String> filteredProducts = [];
  List<String> availableCustomers = [];
  List<String> filteredCustomers = [];
  bool showProductList = false;
  bool showCustomerList = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Fetch product names from the 'purchaseEntries' collection in Firestore
    fetchProducts();
    fetchCustomers();
  }

  Future<void> fetchProducts() async {
    try {
      // Fetch product names from the 'purchaseEntries' collection in Firestore
      QuerySnapshot productSnapshot =
          await FirebaseFirestore.instance.collection('purchaseEntries').get();

      setState(() {
        availableProducts = productSnapshot.docs
            .map((doc) => doc['productName'] as String)
            .toList();
        filteredProducts = List.from(availableProducts);
      });
    } catch (e) {
      print('Error fetching product names: $e');
    }
  }

  Future<void> fetchCustomers() async {
    try {
      // Fetch customer names from the 'customers' collection in Firestore
      QuerySnapshot customerSnapshot =
          await FirebaseFirestore.instance.collection('customers').get();

      setState(() {
        availableCustomers = customerSnapshot.docs
            .map((doc) => doc['customerName'] as String)
            .toList();
        filteredCustomers = List.from(availableCustomers);
      });
    } catch (e) {
      print('Error fetching customer names: $e');
    }
  }

  // Widget to display filtered product names as suggestions
  Widget _buildProductSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredProducts
          .map(
            (productName) => ListTile(
              title: Text(productName),
              onTap: () {
                // Set the selected product name when the user taps a suggestion
                setState(() {
                  productNameController.text = productName;
                  filteredProducts.clear(); // Clear suggestions
                  showProductList = false;
                });
              },
            ),
          )
          .toList(),
    );
  }

  // Widget to display filtered customer names as suggestions
  Widget _buildCustomerSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredCustomers
          .map(
            (customerName) => ListTile(
              title: Text(customerName),
              onTap: () {
                // Set the selected customer name when the user taps a suggestion
                setState(() {
                  customerNameController.text = customerName;
                  filteredCustomers.clear(); // Clear suggestions
                  showCustomerList = false;
                });
              },
            ),
          )
          .toList(),
    );
  }

  Future<void> submitForm() async {
    try {
      // Validate the form
      if (_formKey.currentState!.validate()) {
        // Get values from the form fields
        String productName = productNameController.text;
        String customerName = customerNameController.text;
        int salesQuantity = int.parse(salesQuantityController.text);
        String salesDate = salesDateController.text;
        double salesPrice = double.parse(salesPriceController.text);
        String salesType = _selectedItem ?? "";

        // Fetch product details from Firestore
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('purchaseEntries')
            .where('productName', isEqualTo: productName)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot productSnapshot = querySnapshot.docs.first;
          int availableQuantity = productSnapshot['purchaseQuantity'];
          int minQuantityForAlert = productSnapshot['minQuantityForAlert'];

          // Check if the sales quantity exceeds available quantity
          if (salesQuantity > availableQuantity) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Error: Sales quantity exceeds available quantity'),
              ),
            );
            return; // Exit the method without submitting the form
          }

          // Check if the available quantity after sales is below the minimum threshold
          if (availableQuantity - salesQuantity <= minQuantityForAlert) {
            // Show the minimum quantity alert
            _showMinimumQuantityAlert();
          }

          // Update available quantity in Firestore after sales entry
          await FirebaseFirestore.instance
              .collection('purchaseEntries')
              .doc(productSnapshot.id)
              .update({
            'purchaseQuantity': availableQuantity - salesQuantity,
          });

          // Save the sales entry to Firestore
          await FirebaseFirestore.instance.collection('salesEntries').add({
            'productName': productName,
            'customerName': customerName,
            'salesQuantity': salesQuantity,
            'salesDate': salesDate,
            'salesPrice': salesPrice,
            'salesType': salesType,
          });

          // Clear form fields after submission
          productNameController.clear();
          customerNameController.clear();
          salesQuantityController.clear();
          salesDateController.clear();
          salesPriceController.clear();
          setState(() {
            _selectedItem = null;
            showProductList = false;
            showCustomerList = false;
          });

          // Show a success message or navigate to another screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sales entry submitted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Product not found')),
          );
        }
      }
    } catch (e, stackTrace) {
      // Handle any errors during submission
      print('Error during form submission: $e');
      print('Stack trace: $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error submitting form. Please try again.'),
        ),
      );
    }
  }

  void _showMinimumQuantityAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Minimum Quantity Alert'),
          content: const Text('The product has reached the minimum quantity.'),
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
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back),
            ),
            const Text("Sales Entry", style: TextStyle(fontSize: 20)),
            const Icon(
              Icons.arrow_forward,
              color: Colors.green,
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Product Name
                const Text(
                  'Product Name',
                  style: TextStyle(color: Colors.green, fontSize: 15),
                ),
                const SizedBox(height: 5),

                // Product name
                TextFormField(
                  controller: productNameController,
                  onChanged: (value) {
                    setState(() {
                      // Update the filtered product names based on user input
                      filteredProducts = availableProducts
                          .where((productName) => productName
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                      showProductList = filteredProducts.isNotEmpty;
                    });
                  },
                  obscureText: false,
                  decoration: InputDecoration(
                    hintText: 'Product Name',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.pin_invoke_sharp,
                      color: Colors.green,
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Product Name';
                    } else if (!availableProducts.contains(value)) {
                      return 'Invalid Product Name. Please select from the list.';
                    } else {
                      return null;
                    }
                  },
                ),

                // Show product suggestions only when the text field is focused and not empty
                if (showProductList) _buildProductSuggestions(),

                const SizedBox(height: 10),

                // Customer Name
                const Text(
                  'Customer Name',
                  style: TextStyle(color: Colors.green, fontSize: 15),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: customerNameController,
                  onChanged: (value) {
                    setState(() {
                      // Update the filtered customer names based on user input
                      filteredCustomers = availableCustomers
                          .where((customerName) => customerName
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                      showCustomerList = filteredCustomers.isNotEmpty;
                    });
                  },
                  obscureText: false,
                  decoration: InputDecoration(
                    hintText: 'Customer Name',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.green,
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Customer Name';
                    } else if (!availableCustomers.contains(value)) {
                      return 'Invalid Customer Name. Please select from the list.';
                    } else {
                      return null;
                    }
                  },
                ),

                // Show customer suggestions only when the text field is focused
                if (showCustomerList) _buildCustomerSuggestions(),

                const SizedBox(height: 10),

                // Sales Quantity
                const Text(
                  'Sales Quantity',
                  style: TextStyle(color: Colors.green, fontSize: 15),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: salesQuantityController,
                  keyboardType: TextInputType.number,
                  obscureText: false,
                  decoration: const InputDecoration(
                    hintText: 'Sales Quantity',
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
                      return 'Enter Sales Quantity';
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 3),
                const Text(
                  'Note:',
                  style: TextStyle(fontSize: 13, color: Colors.green),
                ),

                const SizedBox(height: 10),

                // Sales Date
                const Text(
                  'Sales Date',
                  style: TextStyle(color: Colors.green, fontSize: 15),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: salesDateController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    hintText: 'Sales Date',
                    hintStyle: TextStyle(
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.green,
                    ),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2102));
                    if (pickedDate != null) {
                      setState(() {
                        salesDateController.text =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),

                // Sales Price
                const Text(
                  'Sales Price',
                  style: TextStyle(color: Colors.green, fontSize: 15),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: salesPriceController,
                  keyboardType: TextInputType.number,
                  obscureText: false,
                  decoration: const InputDecoration(
                    hintText: 'shs 0.00',
                    hintStyle: TextStyle(
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.monetization_on_outlined,
                      color: Colors.green,
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Sales Price';
                    } else {
                      return null;
                    }
                  },
                ),

                const SizedBox(height: 10),

                // Sales Type
                const Text(
                  'Sales Type',
                  style: TextStyle(color: Colors.green, fontSize: 15),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  icon: const Icon(
                    Icons.arrow_drop_down_outlined,
                    color: Colors.green,
                  ),
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
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          submitForm();
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.check),
      ),
    );
  }
}
