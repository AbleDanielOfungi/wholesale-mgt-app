import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SalesManCustomeAddUpdate extends StatefulWidget {
  final String? customerId;

  const SalesManCustomeAddUpdate({Key? key, this.customerId}) : super(key: key);

  @override
  State<SalesManCustomeAddUpdate> createState() =>
      _SalesManCustomeAddUpdateState();
}

class _SalesManCustomeAddUpdateState extends State<SalesManCustomeAddUpdate> {
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    // Fetch customer details if customerId is provided
    if (widget.customerId != null) {
      fetchCustomerDetails();
    }
  }

  Future<void> fetchCustomerDetails() async {
    try {
      // Fetch customer details from Firestore using customerId
      DocumentSnapshot customerSnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customerId)
          .get();

      // Populate the form fields with customer details
      Map<String, dynamic> customerData =
          customerSnapshot.data() as Map<String, dynamic>;
      customerNameController.text = customerData['customerName'];
      companyNameController.text = customerData['companyName'];
      addressController.text = customerData['address'];
      mobileNoController.text = customerData['mobileNo'];
      emailController.text = customerData['email'];
    } catch (error) {
      print('Error fetching customer details: $error');
    }
  }

  Future<void> uploadCustomerDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() {
          _isUploading = true;
        });

        // Upload or update customer details to Firestore
        if (widget.customerId != null) {
          // Update existing customer
          await FirebaseFirestore.instance
              .collection('customers')
              .doc(widget.customerId)
              .update({
            'customerName': customerNameController.text,
            'companyName': companyNameController.text,
            'address': addressController.text,
            'mobileNo': mobileNoController.text,
            'email': emailController.text,
          });
        } else {
          // Add new customer
          await FirebaseFirestore.instance.collection('customers').add({
            'customerName': customerNameController.text,
            'companyName': companyNameController.text,
            'address': addressController.text,
            'mobileNo': mobileNoController.text,
            'email': emailController.text,
          });
        }

        setState(() {
          _isUploading = false;
        });

        // Clear form fields after successful upload/update
        _formKey.currentState?.reset();
        customerNameController.clear();
        companyNameController.clear();
        addressController.clear();
        mobileNoController.clear();
        emailController.clear();

        // Show success message or navigate to another screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Customer details uploaded/updated successfully')),
        );
      } catch (error) {
        // Handle Firestore error
        setState(() {
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error uploading/updating customer details')),
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
        title: Text(
          widget.customerId != null ? 'Edit Customer' : 'Add Customer',
          style: const TextStyle(fontSize: 20),
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
                        const Text('Customer Name'),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: customerNameController,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Enter Customer Name';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Customer Name',
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text('Customer Company Name'),
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
                            hintText: 'Company Name',
                            prefixIcon: Icon(Icons.house_siding),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text('Customer Address'),
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
                            hintText: 'Customer Address',
                            prefixIcon: Icon(Icons.place),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text('Customer Mobile No'),
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
                            hintText: 'Customer Mobile No',
                            prefixIcon: Icon(Icons.phone_android_sharp),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text('Customer Email Id'),
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
                            hintText: 'Customer Email Id',
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
          uploadCustomerDetails();
        },
        child: const Icon(
          Icons.check,
          color: Colors.green,
        ),
      ),
    );
  }
}
