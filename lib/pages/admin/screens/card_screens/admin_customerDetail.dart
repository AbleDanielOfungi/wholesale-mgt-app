import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wholesense/pages/admin/adminHome.dart';
import 'package:wholesense/pages/admin/screens/card_screens/sec-screens/admin_customeradd_update.dart';

class AdminCustomerDetails extends StatefulWidget {
  static const routeName = '/customerDetail';
  const AdminCustomerDetails({Key? key}) : super(key: key);

  @override
  State<AdminCustomerDetails> createState() => _AdminCustomerDetailsState();
}

class _AdminCustomerDetailsState extends State<AdminCustomerDetails> {
  late Stream<QuerySnapshot> _customerStream;

  @override
  void initState() {
    super.initState();
    _customerStream =
        FirebaseFirestore.instance.collection('customers').snapshots();
  }

  // Function to delete a customer
  void deleteCustomer(String documentId) {
    FirebaseFirestore.instance.collection('customers').doc(documentId).delete();
  }

  // Function to show a dialog for editing a customer
  void showEditDialog(
    String documentId,
    String currentCustomerName,
    String currentCompanyName,
    String currentAddress,
    String currentMobileNo,
    String currentEmail,
  ) {
    TextEditingController customerNameController =
        TextEditingController(text: currentCustomerName);
    TextEditingController companyNameController =
        TextEditingController(text: currentCompanyName);
    TextEditingController addressController =
        TextEditingController(text: currentAddress);
    TextEditingController mobileNoController =
        TextEditingController(text: currentMobileNo);
    TextEditingController emailController =
        TextEditingController(text: currentEmail);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Customer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: customerNameController,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                ),
                TextField(
                  controller: companyNameController,
                  decoration: const InputDecoration(labelText: 'Company Name'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: mobileNoController,
                  decoration: const InputDecoration(labelText: 'Mobile No'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('customers')
                    .doc(documentId)
                    .update({
                  'customerName': customerNameController.text,
                  'companyName': companyNameController.text,
                  'address': addressController.text,
                  'mobileNo': mobileNoController.text,
                  'email': emailController.text,
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // void _launchPhoneCall(String phoneNumber) async {
  //   final url = 'tel:$phoneNumber';
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     print('Could not launch $url');
  //   }
  // }

  // void _launchEmail(String email) async {
  //   final url = 'mailto:$email';
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     print('Could not launch $url');
  //   }
  // }

  // Function to show a dialog for confirming the deletion of a customer
  void showDeleteConfirmationDialog(String documentId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: const Text('Are you sure you want to delete this customer?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteCustomer(documentId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
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
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const AdminHome();
                }));
              },
              child: const Icon(Icons.arrow_circle_left_outlined),
            ),
            const Text("Customer Details", style: TextStyle(fontSize: 20)),
            const Icon(
              Icons.arrow_circle_left_outlined,
              color: Colors.green,
            )
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: CustomerSearchDelegate());
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _customerStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No customers found.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> customerData =
                  document.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    // image: const DecorationImage(
                    //   image: AssetImage('assets/pl.jpg'),
                    //   fit: BoxFit.cover,
                    // ),
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Row(
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(width: 10),
                        Text(customerData['customerName']),
                      ],
                    ),
                    subtitle: Text(
                      'Company: ${customerData['companyName']}\nAddress: ${customerData['address']}\n'
                      'Mobile No: ${customerData['mobileNo']}\nEmail: ${customerData['email']}',
                      style: TextStyle(color: Colors.grey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            showEditDialog(
                              document.id,
                              customerData['customerName'],
                              customerData['companyName'],
                              customerData['address'],
                              customerData['mobileNo'],
                              customerData['email'],
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            showDeleteConfirmationDialog(document.id);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      // Add any additional action on customer tile tap
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const AdminCustomeAddUpdate();
          }));
        },
        child: const Icon(
          Icons.add,
          color: Colors.green,
        ),
      ),
    );
  }
}

class CustomerSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  void _launchPhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  void _launchEmail(String email) async {
    final url = 'mailto:$email';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement your search results UI here

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('customers').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No customers found.'),
          );
        } else {
          final filteredCustomers = snapshot.data!.docs.where((customer) {
            final customerName =
                customer['customerName'].toString().toLowerCase();
            final companyName =
                customer['companyName'].toString().toLowerCase();
            final address = customer['address'].toString().toLowerCase();
            final mobileNo = customer['mobileNo'].toString().toLowerCase();
            final email = customer['email'].toString().toLowerCase();
            return customerName.contains(query.toLowerCase()) ||
                companyName.contains(query.toLowerCase()) ||
                address.contains(query.toLowerCase()) ||
                mobileNo.contains(query.toLowerCase()) ||
                email.contains(query.toLowerCase());
          }).toList();

          return ListView.builder(
            itemCount: filteredCustomers.length,
            itemBuilder: (context, index) {
              DocumentSnapshot<Object?> customer = filteredCustomers[index];
              Map<String, dynamic> customerData =
                  customer.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/pl.jpg'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.person),
                        Text(customerData['customerName'],
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    subtitle: Column(
                      children: [
                        Row(
                          children: [
                            Text('Company:',
                                style: TextStyle(color: Colors.grey)),
                            const SizedBox(
                              width: 5,
                            ),
                            Text('${customerData['companyName']}',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Address:',
                                style: TextStyle(color: Colors.grey)),
                            const SizedBox(
                              width: 5,
                            ),
                            Text('${customerData['address']}',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Mobile No:',
                                style: TextStyle(color: Colors.grey)),
                            const SizedBox(
                              width: 5,
                            ),
                            GestureDetector(
                              onTap: () {
                                _launchPhoneCall(customerData['mobileNo']);
                              },
                              child: Text('${customerData['mobileNo']}',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Email:'),
                            const SizedBox(
                              width: 5,
                            ),
                            GestureDetector(
                              onTap: () {
                                _launchEmail(customerData['email']);
                              },
                              child: Text(
                                '${customerData['email']}',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      // Add any additional action on customer tile tap
                    },
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement your search suggestions UI here

    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('customers').get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No customers found.'),
          );
        } else {
          final customerNames = snapshot.data!.docs
              .map<String>((customer) => customer['customerName'].toString())
              .toList();

          final suggestionList = customerNames
              .where((customerName) =>
                  customerName.toLowerCase().contains(query.toLowerCase()))
              .toList();

          return ListView.builder(
            itemCount: suggestionList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(suggestionList[index]),
                onTap: () {
                  query = suggestionList[index];
                  showResults(context);
                },
              );
            },
          );
        }
      },
    );
  }
}
