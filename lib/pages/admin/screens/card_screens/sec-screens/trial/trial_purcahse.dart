import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PurchaseEntryScreen extends StatefulWidget {
  const PurchaseEntryScreen({Key? key}) : super(key: key);

  @override
  _PurchaseEntryScreenState createState() => _PurchaseEntryScreenState();
}

class _PurchaseEntryScreenState extends State<PurchaseEntryScreen> {
  final TextEditingController _vendorNameController = TextEditingController();
  final TextEditingController _purchaseDateController = TextEditingController();

  List<Map<String, dynamic>> _products = [];

  List<String> _vendors = [];
  List<String> _filteredVendors = [];

  List<String> _productNames = [];
  List<String> _filteredProductNames = [];

  @override
  void initState() {
    super.initState();
    _loadVendors();
    _loadProductNames();
  }

  Future<void> _loadVendors() async {
    final vendors =
        await FirebaseFirestore.instance.collection('vendors').get();
    setState(() {
      _vendors =
          vendors.docs.map((doc) => doc['vendorName'] as String).toList();
    });
  }

  Future<void> _loadProductNames() async {
    final products =
        await FirebaseFirestore.instance.collection('products').get();
    setState(() {
      _productNames =
          products.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  void _filterVendors(String query) {
    setState(() {
      _filteredVendors = _vendors
          .where((vendor) => vendor.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _filterProductNames(String query) {
    setState(() {
      _filteredProductNames = _productNames
          .where((productName) =>
              productName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _vendorNameController,
              decoration: InputDecoration(
                hintText: 'Vendor Name',
                hintStyle: TextStyle(fontSize: 13),
                prefixIcon: Icon(Icons.person, color: Colors.green),
              ),
              onChanged: _filterVendors,
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredVendors.length,
              itemBuilder: (context, index) {
                final vendor = _filteredVendors[index];
                return ListTile(
                  title: Text(vendor),
                  onTap: () {
                    setState(() {
                      _vendorNameController.text = vendor;
                      _filteredVendors = [];
                    });
                  },
                );
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _purchaseDateController,
              decoration: InputDecoration(labelText: 'Purchase Date'),
              readOnly: true,
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _purchaseDateController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter purchase date';
                }
                return null;
              },
            ),
            ..._products.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> product = entry.value;
              return ProductForm(
                index: index,
                product: product,
                onProductChanged: (updatedProduct) {
                  _products[index] = updatedProduct;
                  setState(() {});
                },
                filterProductNames: _filterProductNames,
                filteredProductNames: _filteredProductNames,
              );
            }).toList(),
            ElevatedButton(
              onPressed: () {
                _addProductEntry();
              },
              child: Text('Add Product'),
            ),
            ElevatedButton(
              onPressed: () {
                _savePurchaseEntry();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _addProductEntry() {
    _products.add({});
    setState(() {});
  }

  void _savePurchaseEntry() async {
    // Check if vendor name is not empty
    if (_vendorNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter vendor name')),
      );
      return;
    }

    // Check if purchase date is not empty
    if (_purchaseDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select purchase date')),
      );
      return;
    }

    // Check if any product form has empty fields
    for (var product in _products) {
      if (product['productName'] == null ||
          product['productName'].isEmpty ||
          product['purchaseQuantity'] == null ||
          product['purchaseQuantity'].isEmpty ||
          product['purchasePrice'] == null ||
          product['purchasePrice'].isEmpty ||
          product['minQuantityAlert'] == null ||
          product['minQuantityAlert'].isEmpty ||
          product['purchaseType'] == null ||
          product['purchaseType'].isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all product details')),
        );
        return;
      }
    }

    try {
      for (var product in _products) {
        await FirebaseFirestore.instance.collection('purchase_entries').add({
          'productName': product['productName'],
          'vendorName': _vendorNameController.text,
          'purchaseQuantity':
              int.tryParse(product['purchaseQuantity'] ?? '0') ?? 0,
          'purchasePrice':
              double.tryParse(product['purchasePrice'] ?? '0') ?? 0,
          'purchaseDate': _purchaseDateController.text,
          'purchaseType': product['purchaseType'],
          'minQuantityAlert':
              int.tryParse(product['minQuantityAlert'] ?? '0') ?? 0,
          // Add other fields here
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase entries saved successfully')),
      );

      _products.clear();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save purchase entries: $e')),
      );
    }
  }

  @override
  void dispose() {
    _vendorNameController.dispose();
    _purchaseDateController.dispose();
    super.dispose();
  }
}

class ProductForm extends StatefulWidget {
  final int index;
  final Map<String, dynamic> product;
  final ValueChanged<Map<String, dynamic>> onProductChanged;
  final Function(String) filterProductNames;
  final List<String> filteredProductNames;

  const ProductForm({
    Key? key,
    required this.index,
    required this.product,
    required this.onProductChanged,
    required this.filterProductNames,
    required this.filteredProductNames,
  }) : super(key: key);

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  late TextEditingController _purchaseQuantityController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _minQuantityAlertController;
  late TextEditingController _purchaseTypeController;

  @override
  void initState() {
    super.initState();
    _purchaseQuantityController =
        TextEditingController(text: widget.product['purchaseQuantity']);
    _purchasePriceController =
        TextEditingController(text: widget.product['purchasePrice']);
    _minQuantityAlertController =
        TextEditingController(text: widget.product['minQuantityAlert']);
    _purchaseTypeController =
        TextEditingController(text: widget.product['purchaseType']);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Product ${widget.index + 1} Details'),
          _buildFilteringTextField(
            hintText: 'Product Name',
            prefixIcon: Icons.shopping_bag,
            controller:
                TextEditingController(text: widget.product['productName']),
          ),
          TextFormField(
            controller: _purchaseQuantityController,
            decoration: InputDecoration(labelText: 'Purchase Quantity'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter purchase quantity';
              }
              return null;
            },
            onChanged: (value) {
              widget.onProductChanged({
                ...widget.product,
                'purchaseQuantity': value,
              });
            },
          ),
          TextFormField(
            controller: _purchasePriceController,
            decoration: InputDecoration(labelText: 'Purchase Price'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter purchase price';
              }
              return null;
            },
            onChanged: (value) {
              widget.onProductChanged({
                ...widget.product,
                'purchasePrice': value,
              });
            },
          ),
          TextFormField(
            controller: _minQuantityAlertController,
            decoration:
                InputDecoration(labelText: 'Minimum Quantity for Alert'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter minimum quantity for alert';
              }
              return null;
            },
            onChanged: (value) {
              widget.onProductChanged({
                ...widget.product,
                'minQuantityAlert': value,
              });
            },
          ),
          DropdownButtonFormField<String>(
            value: _purchaseTypeController.text.isNotEmpty
                ? _purchaseTypeController.text
                : null,
            onChanged: (value) {
              setState(() {
                _purchaseTypeController.text = value!;
                widget.onProductChanged({
                  ...widget.product,
                  'purchaseType': value,
                });
              });
            },
            items: ['Cash', 'Debit'].map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Purchase Type',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a purchase type';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildFilteringTextField({
    required String hintText,
    required IconData prefixIcon,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 13),
            prefixIcon: Icon(prefixIcon, color: Colors.blue),
          ),
          onChanged: widget.filterProductNames,
          onTap: () {
            setState(() {
              widget.filteredProductNames.clear();
            });
          },
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.filteredProductNames.length,
          itemBuilder: (context, index) {
            final item = widget.filteredProductNames[index];
            return ListTile(
              title: Text(item),
              onTap: () {
                setState(() {
                  controller.text = item;
                  widget.filteredProductNames.clear();
                });
                widget.filterProductNames(
                    item); // Notify parent widget about the selected item
              },
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _purchaseQuantityController.dispose();
    _purchasePriceController.dispose();
    _minQuantityAlertController.dispose();
    _purchaseTypeController.dispose();
    super.dispose();
  }
}
