import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminProductUpdateScreen extends StatefulWidget {
  final String productId;

  const AdminProductUpdateScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  _AdminProductUpdateScreenState createState() =>
      _AdminProductUpdateScreenState();
}

class _AdminProductUpdateScreenState extends State<AdminProductUpdateScreen> {
  final _picker = ImagePicker();
  XFile? _image;
  String _selectedCategory = 'Drinks';
  String _productName = '';
  double _productPrice = 0.0;
  int _productQuantity = 0;
  String _productDescription = '';
  bool _isAlertEnabled = false;
  int _minQuantityForAlert = 0;
  bool _isUploading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Fetch and set the existing product details when the screen is initiated
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    try {
      // Fetch the product details based on the productId
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      // Extract the product data
      Map<String, dynamic> productData =
          productSnapshot.data() as Map<String, dynamic>;

      // Set the state with the fetched data
      setState(() {
        _productName = productData['name'];
        _productPrice = productData['price'];
        _productQuantity = productData['quantity'];
        _productDescription = productData['description'];
        _selectedCategory = productData['category'];
        _isAlertEnabled = productData['isAlertEnabled'];
        _minQuantityForAlert = productData['minQuantityForAlert'];
        // You may need to handle the image loading separately based on your storage structure
      });
    } catch (error) {
      print('Error fetching product details: $error');
      // Handle error fetching product details
    }
  }

  Future<void> pickImage() async {
    _image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  Future<void> updateProduct() async {
    setState(() {
      _isUploading = true;
    });

    try {
      if (_image != null) {
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('$_selectedCategory/${DateTime.now()}.png');
        UploadTask uploadTask = storageRef.putFile(File(_image!.path));

        await uploadTask.whenComplete(() async {
          String imageURL = await storageRef.getDownloadURL();
          await FirebaseFirestore.instance
              .collection('products')
              .doc(widget.productId)
              .update({
            'name': _productName,
            'price': _productPrice,
            'quantity': _productQuantity,
            'description': _productDescription,
            'imageURL': imageURL,
            'category': _selectedCategory,
            'isAlertEnabled': _isAlertEnabled,
            'minQuantityForAlert': _minQuantityForAlert,
          });

          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                content: const Text(
                  'Product updated successfully',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.green,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.done,
                      color: Colors.green,
                    ),
                  ),
                ],
              );
            },
          );

          // Reset form and state
          _formKey.currentState?.reset();
          setState(() {
            _image = null;
            _selectedCategory = 'Drinks';
            _isAlertEnabled = false;
            _minQuantityForAlert = 0;
            _isUploading = false;
          });
        });
      } else {
        // If no new image, update other details
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .update({
          'name': _productName,
          'price': _productPrice,
          'quantity': _productQuantity,
          'description': _productDescription,
          'category': _selectedCategory,
          'isAlertEnabled': _isAlertEnabled,
          'minQuantityForAlert': _minQuantityForAlert,
        });

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              content: const Text(
                'Product updated successfully',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.green,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.done,
                    color: Colors.green,
                  ),
                ),
              ],
            );
          },
        );

        // Reset form and state
        _formKey.currentState?.reset();
        setState(() {
          _selectedCategory = 'Fertilizers Foiler';
          _isAlertEnabled = false;
          _minQuantityForAlert = 0;
          _isUploading = false;
        });
      }
    } catch (error) {
      _showFailureDialog('Update failed: $error');
    }
  }

  void _showFailureDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Failed'),
          content: Text(message),
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

  Map<String, String> categoryImages = {
    'Drinks': 'assets/g.png',
    'Harware ': 'assets/g.png',
    'Stationery': 'assets/g.png',
    'Clothing': 'assets/g.png',
    'Shoes': 'assets/g.png',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text('Update Product'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: pickImage,
                        child: _image == null
                            ? const Icon(
                                Icons.camera_alt,
                                size: 200,
                              )
                            : Image.file(
                                File(_image!.path),
                                width: 200,
                                height: 200,
                              ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Product Categories',
                        style: TextStyle(
                          color: Colors.lightGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButton<String>(
                        dropdownColor: Colors.white,
                        value: _selectedCategory,
                        borderRadius: BorderRadius.circular(5),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                        items: categoryImages.keys
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    categoryImages[value]!,
                                    height: 24,
                                    width: 24,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(value),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      // Product Name
                      TextFormField(
                        initialValue: _productName,
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          labelStyle: TextStyle(color: Colors.lightGreen),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _productName = value;
                          });
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Product Name';
                          }
                          return null;
                        },
                      ),

                      // Product Price
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Product Price',
                          labelStyle: TextStyle(color: Colors.green),
                        ),
                        onChanged: (value) {
                          setState(() {
                            try {
                              _productPrice =
                                  value.isEmpty ? 0.0 : double.parse(value);
                            } catch (e) {
                              print('Error parsing double: $e');
                              // Handle the error (e.g., show a message to the user)
                            }
                          });
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Product Price';
                          }
                          double price = double.parse(value);
                          if (price <= 0) {
                            return 'Price must be greater than zero';
                          }
                          return null;
                        },
                      ),

                      // Product Quantity
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Product Quantity',
                          labelStyle: TextStyle(color: Colors.green),
                        ),
                        onChanged: (value) {
                          setState(() {
                            try {
                              _productQuantity =
                                  value.isEmpty ? 0 : int.parse(value);
                            } catch (e) {
                              print('Error parsing int: $e');
                              // Handle the error (e.g., show a message to the user)
                            }
                          });
                        },
                        // Product Quantity Validation
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Product Quantity';
                          }
                          int quantity = int.parse(value);
                          if (quantity <= 0) {
                            return 'Quantity must be greater than zero';
                          }
                          return null;
                        },
                      ),
                      // Product Description
                      TextFormField(
                        initialValue: _productDescription,
                        decoration: const InputDecoration(
                          labelText: 'Product Description',
                          labelStyle: TextStyle(color: Colors.lightGreen),
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          setState(() {
                            _productDescription = value;
                          });
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Product Description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
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
                          initialValue: _minQuantityForAlert.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Minimum Quantity for Alert',
                            labelStyle: TextStyle(color: Colors.lightGreen),
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
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  color: Colors.lightGreen,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            updateProduct();
          }
        },
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.check,
          color: Colors.lightGreen,
        ),
      ),
    );
  }
}
