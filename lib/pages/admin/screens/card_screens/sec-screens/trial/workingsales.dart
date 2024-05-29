// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class SalesEntryScreen extends StatefulWidget {
//   final String sellerEmail;

//   const SalesEntryScreen({Key? key, required this.sellerEmail})
//       : super(key: key);

//   @override
//   _SalesEntryScreenState createState() => _SalesEntryScreenState();
// }

// class _SalesEntryScreenState extends State<SalesEntryScreen> {
//   final TextEditingController _customerNameController = TextEditingController();
//   final TextEditingController _salesDateController = TextEditingController();

//   List<Map<String, dynamic>> _products = [];

//   List<String> _customers = [];
//   List<String> _filteredCustomers = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadCustomers();
//   }

//   Future<void> _loadCustomers() async {
//     final customers =
//         await FirebaseFirestore.instance.collection('customers').get();
//     setState(() {
//       _customers =
//           customers.docs.map((doc) => doc['customerName'] as String).toList();
//     });
//   }

//   void _filterCustomers(String query) {
//     setState(() {
//       _filteredCustomers = _customers
//           .where((customer) =>
//               customer.toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Sales Entry'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             TextFormField(
//               controller: _customerNameController,
//               decoration: InputDecoration(
//                 hintText: 'Customer Name',
//                 hintStyle: TextStyle(fontSize: 13),
//                 prefixIcon: Icon(Icons.person, color: Colors.green),
//               ),
//               onChanged: (value) {
//                 _filterCustomers(value);
//               },
//             ),
//             SizedBox(height: 10),
//             ListView.builder(
//               shrinkWrap: true,
//               itemCount: _filteredCustomers.length,
//               itemBuilder: (context, index) {
//                 final customer = _filteredCustomers[index];
//                 return ListTile(
//                   title: Text(customer),
//                   onTap: () {
//                     setState(() {
//                       _customerNameController.text = customer;
//                       _filteredCustomers = [];
//                     });
//                   },
//                 );
//               },
//             ),
//             SizedBox(height: 10),
//             TextFormField(
//               controller: _salesDateController,
//               decoration: InputDecoration(labelText: 'Sales Date'),
//               readOnly: true,
//               onTap: () async {
//                 final DateTime? pickedDate = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(2101),
//                 );
//                 if (pickedDate != null) {
//                   setState(() {
//                     _salesDateController.text =
//                         DateFormat('yyyy-MM-dd').format(pickedDate);
//                   });
//                 }
//               },
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter sales date';
//                 }
//                 return null;
//               },
//             ),
//             ..._products.asMap().entries.map((entry) {
//               int index = entry.key;
//               Map<String, dynamic> product = entry.value;
//               return ProductForm(
//                 index: index,
//                 product: product,
//                 onProductChanged: (updatedProduct) {
//                   _products[index] = updatedProduct;
//                   setState(() {});
//                 },
//               );
//             }).toList(),
//             ElevatedButton(
//               onPressed: () {
//                 _addProductEntry();
//               },
//               child: Text('Add Product'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 _saveSalesEntry();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _addProductEntry() {
//     _products.add({});
//     setState(() {});
//   }

//   Future<void> _saveSalesEntry() async {
//     // Check if customer name is not empty
//     if (_customerNameController.text.isEmpty) {
//       _showAlert('Please enter customer name');
//       return;
//     }

//     // Check if sales date is not empty
//     if (_salesDateController.text.isEmpty) {
//       _showAlert('Please select sales date');
//       return;
//     }

//     // Check if any product form has empty fields
//     for (var product in _products) {
//       if (product['productName'] == null || product['productName'].isEmpty) {
//         _showAlert('Please enter product name');
//         return;
//       }
//       if (product['purchaseQuantity'] == null ||
//           product['purchaseQuantity'].isEmpty) {
//         _showAlert('Please enter purchase quantity');
//         return;
//       }
//       if (product['purchasePrice'] == null ||
//           product['purchasePrice'].isEmpty) {
//         _showAlert('Please enter purchase price');
//         return;
//       }
//       if (product['purchaseType'] == null || product['purchaseType'].isEmpty) {
//         _showAlert('Please select a purchase type');
//         return;
//       }
//     }

//     // If all fields are filled, proceed to save the sales entries
//     try {
//       for (var product in _products) {
//         await FirebaseFirestore.instance.collection('sales_entries').add({
//           'productName': product['productName'],
//           'customerName': _customerNameController.text,
//           'salesQuantity':
//               int.tryParse(product['purchaseQuantity'] ?? '0') ?? 0,
//           'salesPrice': double.tryParse(product['purchasePrice'] ?? '0') ?? 0,
//           'salesDate': _salesDateController.text,
//           'salesType': product['purchaseType'],
//           'sellerEmail': widget.sellerEmail,
//           // Add other fields here
//         });

//         // Reduce product quantity in the database
//         await _updateProductQuantity(product['productName'],
//             int.tryParse(product['purchaseQuantity'] ?? '0') ?? 0);
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Sales entries saved successfully')),
//       );

//       _products.clear();
//       setState(() {});
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to save sales entries: $e')),
//       );
//     }
//   }

//   Future<void> _updateProductQuantity(
//       String productName, int soldQuantity) async {
//     final querySnapshot = await FirebaseFirestore.instance
//         .collection('purchase_entries')
//         .where('productName', isEqualTo: productName)
//         .get();

//     int totalQuantity = 0;

//     for (final doc in querySnapshot.docs) {
//       final purchaseQuantity =
//           (doc['purchaseQuantity'] ?? 0) as int; // Explicitly cast to int
//       totalQuantity += purchaseQuantity;
//     }

//     if (totalQuantity < soldQuantity) {
//       throw Exception('Insufficient quantity for $productName');
//     }

//     for (final doc in querySnapshot.docs) {
//       final currentQuantity =
//           (doc['purchaseQuantity'] ?? 0) as int; // Explicitly cast to int
//       final newQuantity = currentQuantity - soldQuantity;
//       if (newQuantity >= 0) {
//         await doc.reference.update({'purchaseQuantity': newQuantity});
//         break;
//       } else {
//         soldQuantity -= currentQuantity;
//         await doc.reference.update({'purchaseQuantity': 0});
//       }
//     }
//   }

//   void _showAlert(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Alert'),
//           content: Text(message),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _customerNameController.dispose();
//     _salesDateController.dispose();
//     super.dispose();
//   }
// }

// class ProductForm extends StatefulWidget {
//   final int index;
//   final Map<String, dynamic> product;
//   final ValueChanged<Map<String, dynamic>> onProductChanged;

//   const ProductForm({
//     Key? key,
//     required this.index,
//     required this.product,
//     required this.onProductChanged,
//   }) : super(key: key);

//   @override
//   _ProductFormState createState() => _ProductFormState();
// }

// class _ProductFormState extends State<ProductForm> {
//   late TextEditingController _productNameController;
//   late TextEditingController _purchaseQuantityController;
//   late TextEditingController _purchasePriceController;
//   late TextEditingController _purchaseTypeController;

//   List<String> _products = [];
//   List<String> _filteredProducts = [];

//   @override
//   void initState() {
//     super.initState();
//     _productNameController =
//         TextEditingController(text: widget.product['productName']);
//     _purchaseQuantityController =
//         TextEditingController(text: widget.product['purchaseQuantity']);
//     _purchasePriceController =
//         TextEditingController(text: widget.product['purchasePrice']);
//     _purchaseTypeController =
//         TextEditingController(text: widget.product['purchaseType']);
//     _loadProducts();
//   }

//   Future<void> _loadProducts() async {
//     final products =
//         await FirebaseFirestore.instance.collection('products').get();
//     setState(() {
//       _products = products.docs.map((doc) => doc['name'] as String).toList();
//     });
//   }

//   void _filterProducts(String query) {
//     setState(() {
//       _filteredProducts = _products
//           .where((productName) =>
//               productName.toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Product ${widget.index + 1} Details'),

//           // Product Name TextFormField
//           TextFormField(
//             controller: _productNameController,
//             decoration: const InputDecoration(labelText: 'Product Name'),
//             onChanged: (value) {
//               _filterProducts(value);
//               widget.onProductChanged({
//                 ...widget.product,
//                 'productName': value,
//               });
//             },
//           ),

//           SizedBox(height: 10),
//           ListView.builder(
//             shrinkWrap: true,
//             itemCount: _filteredProducts.length,
//             itemBuilder: (context, index) {
//               final productName = _filteredProducts[index];
//               return ListTile(
//                 title: Text(productName),
//                 onTap: () {
//                   setState(() {
//                     _productNameController.text = productName;
//                     _filteredProducts = [];
//                   });
//                   widget.onProductChanged({
//                     ...widget.product,
//                     'productName': productName,
//                   });
//                 },
//               );
//             },
//           ),

//           // Purchase Quantity TextFormField
//           TextFormField(
//             controller: _purchaseQuantityController,
//             decoration: InputDecoration(labelText: 'Purchase Quantity'),
//             keyboardType: TextInputType.number,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter purchase quantity';
//               }
//               return null;
//             },
//             onChanged: (value) {
//               widget.onProductChanged({
//                 ...widget.product,
//                 'purchaseQuantity': value,
//               });
//             },
//           ),

//           // Purchase Price TextFormField
//           TextFormField(
//             controller: _purchasePriceController,
//             decoration: InputDecoration(labelText: 'Purchase Price'),
//             keyboardType: TextInputType.number,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter purchase price';
//               }
//               return null;
//             },
//             onChanged: (value) {
//               widget.onProductChanged({
//                 ...widget.product,
//                 'purchasePrice': value,
//               });
//             },
//           ),

//           // Purchase Type DropdownButtonFormField
//           DropdownButtonFormField<String>(
//             value: _purchaseTypeController.text.isNotEmpty
//                 ? _purchaseTypeController.text
//                 : null,
//             onChanged: (value) {
//               setState(() {
//                 _purchaseTypeController.text = value!;
//                 widget.onProductChanged({
//                   ...widget.product,
//                   'purchaseType': value,
//                 });
//               });
//             },
//             items: ['Cash', 'Debit'].map((type) {
//               return DropdownMenuItem(
//                 value: type,
//                 child: Text(type),
//               );
//             }).toList(),
//             decoration: InputDecoration(
//               labelText: 'Purchase Type',
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please select a purchase type';
//               }
//               return null;
//             },
//           ),

//           SizedBox(height: 10),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _productNameController.dispose();
//     _purchaseQuantityController.dispose();
//     _purchasePriceController.dispose();
//     _purchaseTypeController.dispose();
//     super.dispose();
//   }
// }
