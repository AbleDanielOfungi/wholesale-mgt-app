import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminAddPopularProductScreen extends StatefulWidget {
  const AdminAddPopularProductScreen({Key? key}) : super(key: key);

  @override
  _AdminAddPopularProductScreenState createState() =>
      _AdminAddPopularProductScreenState();
}

class _AdminAddPopularProductScreenState
    extends State<AdminAddPopularProductScreen> {
  final _picker = ImagePicker();

  // Product model
  XFile? _image;
  String _selectedCategory = 'Drinks';
  String _productName = '';
  double _productPrice = 0.0; // Updated variable name
  int _productQuantity = 0;
  String _productDescription = '';

  bool _isAlertEnabled = false;
  int _minQuantityForAlert = 0;

  bool _isUploading = false; // Added for tracking upload progress
  final _formkey = GlobalKey<FormState>();

  Future<void> pickImage() async {
    _image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  Future<void> uploadImage() async {
    setState(() {
      _isUploading = true; // Show circular progress indicator
    });

    if (_image != null) {
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('$_selectedCategory/${DateTime.now()}.png');
      UploadTask uploadTask = storageRef.putFile(File(_image!.path));

      await uploadTask.whenComplete(() async {
        try {
          // Getting the download URL for the uploaded image
          String imageURL = await storageRef.getDownloadURL();

          // Creating a new document in Firestore
          await FirebaseFirestore.instance.collection('products').add({
            'name': _productName,
            'price': _productPrice,
            'quantity': _productQuantity,
            'description': _productDescription,
            'imageURL': imageURL,
            'category': _selectedCategory,
            'isAlertEnabled': _isAlertEnabled,
            'minQuantityForAlert': _minQuantityForAlert,
          });

          print('Image uploaded with details');

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                content: const Text(
                  'Product uploaded SuccessFully',
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

          // Clear form fields after successful upload
          _formkey.currentState?.reset();
          setState(() {
            _image = null;
            _selectedCategory = 'Drinks';
            _isAlertEnabled = false;
            _minQuantityForAlert = 0;
            _isUploading = false; // Hide circular progress indicator
          });
        } catch (error) {
          // Handle Firebase Firestore error
          _showFailureDialog('Firestore error: $error');
        }
      }).catchError((error) {
        // Handle Firebase Storage error
        _showFailureDialog('Storage error: $error');
      });
    } else {
      _showFailureDialog('Please select an image.');
      setState(() {
        _isUploading = false; // Hide circular progress indicator on error
      });
    }
  }

  void _showFailureDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Upload Failed'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
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
        backgroundColor: Colors.green,
        title: const Text('Upload Product'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: pickImage,
                        child: _image == null
                            ? Icon(
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
                            color: Colors.green, fontWeight: FontWeight.bold),
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
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          labelStyle: TextStyle(color: Colors.green),
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
                            _productPrice = double.parse(value);
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
                            _productQuantity = int.parse(value);
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
                        decoration: const InputDecoration(
                          labelText: 'Product Description',
                          labelStyle: TextStyle(color: Colors.green),
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
                        controlAffinity: ListTileControlAffinity
                            .leading, // Checkbox on the left
                        onChanged: (value) {
                          setState(() {
                            _isAlertEnabled = value!;
                          });
                        },
                      ),

                      // Minimum Quantity Textfield
                      if (_isAlertEnabled)
                        TextFormField(
                          keyboardType: TextInputType.number,
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
                  color: Colors.green,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formkey.currentState?.validate() ?? false) {
            uploadImage();
          }
        },
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.check,
          color: Colors.green,
        ),
      ),
    );
  }
}
