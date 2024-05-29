//edit screen has to be converting values to double or int

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:wholesense/pages/admin/adminHome.dart';
import 'package:wholesense/pages/admin/screens/card_screens/sec-screens/admin_productAddScreen.dart';
import 'sec-screens/admin_vendoradd_update.dart';

class AdminPurchaseEntry extends StatefulWidget {
  const AdminPurchaseEntry({Key? key}) : super(key: key);

  @override
  State<AdminPurchaseEntry> createState() => _AdminPurchaseEntryState();
}

class _AdminPurchaseEntryState extends State<AdminPurchaseEntry> {
  // Controllers
  final productNameController = TextEditingController();
  final vendorNameController = TextEditingController();
  final purchaseQuantityController = TextEditingController();
  final purchaseDateController = TextEditingController();
  final purchasePriceController = TextEditingController();
  final _minQuantityController = TextEditingController(); // New controller

  final _formKey = GlobalKey<FormState>();

  // Dropdown's
  String? _selectedItem;
  final List<String> _items = ['Cash', 'Debit'];

  List<String> availableProductNames = [];
  List<String> filteredProductNames = [];
  List<String> availableVendorNames = [];
  List<String> filteredVendorNames = [];
  bool showProductList = false;
  bool showVendorList = false;

  bool _isAlertEnabled = false;
  int _minQuantityForAlert = 0;

  @override
  void initState() {
    super.initState();
    // Fetch product and vendor names from the database when the screen is initialized
    fetchProductNames();
    fetchVendorNames();
  }

  Future<void> fetchProductNames() async {
    try {
      // Fetch product names from the database (replace with your actual database call)
      // Example using Firestore
      QuerySnapshot productSnapshot =
          await FirebaseFirestore.instance.collection('products').get();

      setState(() {
        // Extract product names from the snapshot
        availableProductNames =
            productSnapshot.docs.map((doc) => doc['name'] as String).toList();
        filteredProductNames = List.from(availableProductNames);
      });
    } catch (e) {
      print('Error fetching product names: $e');
    }
  }

  Future<void> fetchVendorNames() async {
    try {
      // Fetch vendor names from the database (replace with your actual database call)
      // Example using Firestore
      QuerySnapshot vendorSnapshot =
          await FirebaseFirestore.instance.collection('vendors').get();

      setState(() {
        // Extract vendor names from the snapshot
        availableVendorNames = vendorSnapshot.docs
            .map((doc) => doc['vendorName'] as String)
            .toList();
        filteredVendorNames = List.from(availableVendorNames);
      });
    } catch (e) {
      print('Error fetching vendor names: $e');
    }
  }

  Future<void> submitForm() async {
    try {
      // Validate the form
      if (_formKey.currentState!.validate()) {
        // Get values from the form fields
        String productName = productNameController.text;
        String vendorName = vendorNameController.text;
        int purchaseQuantity = int.parse(purchaseQuantityController.text);
        String purchaseDate = purchaseDateController.text;
        double purchasePrice = double.parse(purchasePriceController.text);
        String purchaseType = _selectedItem ?? "";

        // Save the purchase entry to Firestore
        await FirebaseFirestore.instance.collection('purchaseEntries').add({
          'productName': productName,
          'vendorName': vendorName,
          'purchaseQuantity': purchaseQuantity,
          'purchaseDate': purchaseDate,
          'purchasePrice': purchasePrice,
          'purchaseType': purchaseType,
          'isAlertEnabled': _isAlertEnabled,
          'minQuantityForAlert': _minQuantityForAlert,
        });

        // Clear form fields after submission
        productNameController.clear();
        vendorNameController.clear();
        purchaseQuantityController.clear();
        purchaseDateController.clear();
        purchasePriceController.clear();
        _minQuantityController.clear(); // Clear the new controller
        setState(() {
          _selectedItem = null;
          showProductList = false;
          showVendorList = false;
          _isAlertEnabled = false;
          _minQuantityForAlert = 0;
        });

        // Show a success message or navigate to another screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Purchase entry submitted successfully')),
        );
      }
    } catch (e) {
      // Handle any errors during submission
      print(e);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error submitting form. Please try again.')),
      );
    }
  }

  final vendorNameFocusNode = FocusNode();

  void _onVendorNameFocusChange() {
    setState(() {
      showVendorList = vendorNameFocusNode.hasFocus;
    });
  }

  // Widget to display filtered vendor names as suggestions
  Widget _buildVendorSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredVendorNames
          .map(
            (vendorName) => ListTile(
              title: Text(vendorName),
              onTap: () {
                // Set the selected vendor name when the user taps a suggestion
                setState(() {
                  vendorNameController.text = vendorName;
                  filteredVendorNames.clear(); // Clear suggestions
                  showVendorList = false;
                });
              },
            ),
          )
          .toList(),
    );
  }

  // Widget to display filtered product names as suggestions
  Widget _buildProductSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredProductNames
          .map(
            (productName) => ListTile(
              title: Text(productName),
              onTap: () {
                // Set the selected product name when the user taps a suggestion
                setState(() {
                  productNameController.text = productName;
                  filteredProductNames.clear(); // Clear suggestions
                  showProductList = false;
                });
              },
            ),
          )
          .toList(),
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
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AdminHome();
                }));
                //
              },
              child: const Icon(Icons.arrow_circle_left_outlined),
            ),
            const Text("Purchase Entry", style: TextStyle(fontSize: 20)),
            const Icon(
              Icons.arrow_circle_left_outlined,
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
                const SizedBox(
                  height: 20,
                ),

                // Product Name
                const Text(
                  'Product Name',
                  style: TextStyle(color: Colors.green, fontSize: 15),
                ),
                const SizedBox(
                  height: 5,
                ),

                // Product name
                TextFormField(
                  controller: productNameController,
                  onChanged: (value) {
                    setState(() {
                      // Update the filtered product names based on user input
                      filteredProductNames = availableProductNames
                          .where((productName) => productName
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                      showProductList = value.isNotEmpty;
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
                    suffixIcon: GestureDetector(
                      onTap: () {
                        // Navigate to AddPopularProductScreen when the user taps the icon
                        Navigator.push(context,
                            MaterialPageRoute(builder: (builder) {
                          return const AdminAddPopularProductScreen();
                        }));
                      },
                      child: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Product Name';
                    } else if (!availableProductNames.contains(value)) {
                      return 'Invalid Product Name. Please select from the list.';
                    } else {
                      return null;
                    }
                  },
                ),

                // Show product suggestions only when the text field is focused and not empty
                if (showProductList) _buildProductSuggestions(),

                const SizedBox(
                  height: 10,
                ),

                // Vendor Name
                const Text(
                  'Vendor Name',
                  style: TextStyle(color: Colors.green, fontSize: 15),
                ),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  controller: vendorNameController,
                  onChanged: (value) {
                    setState(() {
                      // Update the filtered vendor names based on user input
                      filteredVendorNames = availableVendorNames
                          .where((vendorName) => vendorName
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                      showVendorList = value.isNotEmpty;
                    });
                  },
                  obscureText: false,
                  focusNode: vendorNameFocusNode,
                  onTap: _onVendorNameFocusChange,
                  decoration: InputDecoration(
                    hintText: 'Vendor Name',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.green,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        // Navigate to VendorAppUpdate when the user taps the icon
                        Navigator.push(context,
                            MaterialPageRoute(builder: (builder) {
                          return const AdminVendorAppUpdate();
                        }));
                      },
                      child: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Vendor Name';
                    } else if (!availableVendorNames.contains(value)) {
                      return 'Invalid Vendor Name. Please select from the list.';
                    } else {
                      return null;
                    }
                  },
                ),

                // Show vendor suggestions only when the text field is focused
                if (showVendorList) _buildVendorSuggestions(),

                const SizedBox(
                  height: 10,
                ),

                // Purchase Quantity
                const Text(
                  'Purchase Quantity',
                  style: TextStyle(color: Colors.green, fontSize: 15),
                ),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  controller: purchaseQuantityController,
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Purchase Quantity',
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
                      return 'Enter Purchase Quantity';
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(
                  height: 3,
                ),
                const Text(
                  'Note:',
                  style: TextStyle(fontSize: 13, color: Colors.green),
                ),

                const SizedBox(
                  height: 10,
                ),

                // Purchase Date
                const Text(
                  'Purchase Date',
                  style: TextStyle(color: Colors.green, fontSize: 15),
                ),
                const SizedBox(
                  height: 5,
                ),
                TextField(
                  controller: purchaseDateController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    hintText: 'Purchase Date',
                    hintStyle: TextStyle(
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.green,
                    ),
                  ),
                  onTap: () async {
                    DateTime? pickddate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2102));
                    if (pickddate != null) {
                      setState(() {
                        purchaseDateController.text =
                            DateFormat('yyyy-MM-dd').format(pickddate);
                      });
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),

                // Purchase Price
                const Text(
                  'Purchase Price',
                  style: TextStyle(color: Colors.green, fontSize: 15),
                ),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  controller: purchasePriceController,
                  keyboardType: TextInputType.number,
                  obscureText: false,
                  decoration: const InputDecoration(
                    hintText: '0.00',
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
                      return 'Enter Purchase Price';
                    } else {
                      return null;
                    }
                  },
                ),

                const SizedBox(
                  height: 10,
                ),
                // Checkbox for Alert
                CheckboxListTile(
                  value: _isAlertEnabled,
                  title: const Text('Enable Minimum Quantity Alert'),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) {
                    setState(() {
                      _isAlertEnabled = value!;
                    });
                  },
                ),

                // Minimum Quantity Textfield
                if (_isAlertEnabled)
                  TextFormField(
                    controller: _minQuantityController,
                    keyboardType: TextInputType.number,
                    obscureText: false,
                    decoration: const InputDecoration(
                      labelText: 'Minimum Quantity for Alert',
                      labelStyle: TextStyle(color: Colors.green),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _minQuantityForAlert = int.parse(value);
                      });
                    },
                    validator: (value) {
                      if (_isAlertEnabled && value!.isEmpty) {
                        return 'Enter Minimum Quantity for Alert';
                      }
                      return null;
                    },
                  ),

                const SizedBox(
                  height: 10,
                ),

                // Purchase Type
                const Text(
                  'Purchase Type',
                  style: TextStyle(color: Colors.green, fontSize: 15),
                ),
                const SizedBox(
                  height: 10,
                ),
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
