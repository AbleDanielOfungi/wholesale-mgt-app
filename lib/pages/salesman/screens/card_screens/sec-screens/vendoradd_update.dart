import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VendorAppUpdate extends StatefulWidget {
  const VendorAppUpdate({Key? key}) : super(key: key);

  @override
  State<VendorAppUpdate> createState() => _VendorAppUpdateState();
}

class _VendorAppUpdateState extends State<VendorAppUpdate> {
  final TextEditingController vendorNameController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isUploading = false;

  Future<void> uploadVendorDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() {
          _isUploading = true;
        });

        // Upload vendor details to Firestore
        await FirebaseFirestore.instance.collection('vendors').add({
          'vendorName': vendorNameController.text,
          'companyName': companyNameController.text,
          'address': addressController.text,
          'mobileNo': mobileNoController.text,
          'email': emailController.text,
        });

        setState(() {
          _isUploading = false;
        });

        // Clear form fields after successful upload
        _formKey.currentState?.reset();
        vendorNameController.clear();
        companyNameController.clear();
        addressController.clear();
        mobileNoController.clear();
        emailController.clear();

        // Show success message or navigate to another screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vendor details uploaded successfully')),
        );
      } catch (error) {
        // Handle Firestore error
        setState(() {
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error uploading vendor details')),
        );
        print(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Vendor Add/Update',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: _isUploading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SizedBox(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        const Text('Vendor Name'),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: vendorNameController,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Enter Vendor Name';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Vendor Name',
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text('Vendor Company Name'),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: companyNameController,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Enter Company Name';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Vendor Company Name',
                            prefixIcon: Icon(Icons.house_siding),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text('Vendor Address'),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: addressController,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Enter Address';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Vendor Address',
                            prefixIcon: Icon(Icons.place),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text('Vendor Mobile No'),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: mobileNoController,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Enter Mobile No';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Vendor Mobile No',
                            prefixIcon: Icon(Icons.phone_android_sharp),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text('Vendor Email Id'),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: emailController,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Enter Email ID';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Vendor Email Id',
                            prefixIcon: Icon(Icons.email),
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
        onPressed: () {
          uploadVendorDetails();
        },
        child: const Icon(
          Icons.check,
          color: Colors.green,
        ),
      ),
    );
  }
}
