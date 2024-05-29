import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProductEditScreen extends StatefulWidget {
  final String productId;

  const AdminProductEditScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  _AdminProductEditScreenState createState() => _AdminProductEditScreenState();
}

class _AdminProductEditScreenState extends State<AdminProductEditScreen> {
  late TextEditingController _productNameController;
  late TextEditingController _productPriceController;
  late TextEditingController _productQuantityController;
  late TextEditingController _productDescriptionController;

  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController();
    _productPriceController = TextEditingController();
    _productQuantityController = TextEditingController();
    _productDescriptionController = TextEditingController();
    fetchProductData();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productPriceController.dispose();
    _productQuantityController.dispose();
    _productDescriptionController.dispose();
    super.dispose();
  }

  Future<void> fetchProductData() async {
    try {
      final DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      final productData = productSnapshot.data() as Map<String, dynamic>;

      setState(() {
        _productNameController.text = productData['name'] ?? '';
        _productPriceController.text = productData['price']?.toString() ?? '';
        _productQuantityController.text =
            productData['quantity']?.toString() ?? '';
        _productDescriptionController.text = productData['description'] ?? '';
      });
    } catch (error) {
      // Handle error
      print('Error fetching product data: $error');
    }
  }

  Future<void> updateProductData() async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
        'name': _productNameController.text,
        'price': double.parse(_productPriceController.text),
        'quantity': int.parse(_productQuantityController.text),
        'description': _productDescriptionController.text,
      });

      // Show success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Product updated successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pop(); // Pop twice to go back to the previous screen
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
      // Handle error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to update product: $error'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _productNameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextFormField(
              controller: _productPriceController,
              decoration: InputDecoration(labelText: 'Product Price'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _productQuantityController,
              decoration: InputDecoration(labelText: 'Product Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _productDescriptionController,
              decoration: InputDecoration(labelText: 'Product Description'),
              maxLines: 3,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                updateProductData();
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
