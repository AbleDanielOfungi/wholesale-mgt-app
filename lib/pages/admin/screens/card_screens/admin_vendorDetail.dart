import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wholesense/pages/admin/adminHome.dart';

class AdminVendorDetail extends StatefulWidget {
  static const routeName = "/vendorDetail";
  const AdminVendorDetail({Key? key}) : super(key: key);

  @override
  State<AdminVendorDetail> createState() => _AdminVendorDetailState();
}

class _AdminVendorDetailState extends State<AdminVendorDetail> {
  late List<Map<String, dynamic>> vendorDetails = [];
  late List<Map<String, dynamic>> filteredVendors = [];

  @override
  void initState() {
    super.initState();
    // Call the function to fetch vendor details from Firebase
    fetchVendorDetails();
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

  Future<void> fetchVendorDetails() async {
    try {
      // Access the 'vendors' collection in Firestore
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('vendors').get();

      // Extract vendor details from the query snapshot
      List<Map<String, dynamic>> vendors = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'vendorName': doc['vendorName'],
          'companyName': doc['companyName'],
          'address': doc['address'],
          'mobileNo': doc['mobileNo'],
          'email': doc['email'],
        };
      }).toList();

      // Update the state with the fetched vendor details
      setState(() {
        vendorDetails = vendors;
        filteredVendors =
            vendors; // Initialize filteredVendors with all vendors initially
      });
    } catch (error) {
      print('Error fetching vendor details: $error');
      // Handle error as needed
    }
  }

  Future<void> deleteVendor(String vendorId) async {
    try {
      // Delete the vendor document from Firestore
      await FirebaseFirestore.instance
          .collection('vendors')
          .doc(vendorId)
          .delete();

      // Refresh the vendor details after deletion
      fetchVendorDetails();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vendor deleted successfully')),
      );
    } catch (error) {
      print('Error deleting vendor: $error');
      // Handle error as needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting vendor')),
      );
    }
  }

  void filterVendors(String query) {
    // Filter vendors based on the search query
    List<Map<String, dynamic>> filteredList = vendorDetails.where((vendor) {
      String vendorName = vendor['vendorName'].toString().toLowerCase();
      String companyName = vendor['companyName'].toString().toLowerCase();
      String address = vendor['address'].toString().toLowerCase();
      String mobileNo = vendor['mobileNo'].toString().toLowerCase();
      String email = vendor['email'].toString().toLowerCase();

      return vendorName.contains(query) ||
          companyName.contains(query) ||
          address.contains(query) ||
          mobileNo.contains(query) ||
          email.contains(query);
    }).toList();

    // Update the state with the filtered vendors
    setState(() {
      filteredVendors = filteredList;
    });
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
            const Text(
              "Vendor Detail",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              // Show the search bar and wait for the search query
              String? query = await showSearch(
                context: context,
                delegate: VendorSearchDelegate(vendorDetails),
              );

              // If a search query is provided, filter vendors accordingly
              if (query != null && query.isNotEmpty) {
                filterVendors(query.toLowerCase());
              }
            },
          ),
        ],
      ),
      body: filteredVendors.isNotEmpty
          ? ListView.builder(
              itemCount: filteredVendors.length,
              itemBuilder: (context, index) {
                final vendor = filteredVendors[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  // child: Container(
                  //   decoration: BoxDecoration(
                  //     image: DecorationImage(
                  //       image: AssetImage(
                  //           'assets/pl.jpg'), // Replace with your asset image path
                  //       fit: BoxFit.cover,
                  //     ),
                  //   ),
                  child: Container(
                    decoration: BoxDecoration(
                        // image: const DecorationImage(
                        //   image: AssetImage('assets/g.png'),
                        //   fit: BoxFit.cover,
                        // ),
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Text(
                              "Name: ",
                              style: TextStyle(
                                color: Colors.amber,
                              ),
                            ),
                            Text(
                              "${vendor['vendorName']}",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                const Text(
                                  "company: ",
                                  style: TextStyle(
                                    color: Colors.amber,
                                  ),
                                ),
                                Text(
                                  "${vendor['companyName']}",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                const Text(
                                  "Address: ",
                                  style: TextStyle(
                                    color: Colors.amber,
                                  ),
                                ),
                                Text(
                                  "${vendor['address']}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    "Mobile No: ",
                                    style: TextStyle(
                                      color: Colors.amber,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      _launchPhoneCall(vendor['mobileNo']),
                                  child: Text(
                                    "${vendor['mobileNo']}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                const Text(
                                  "Email: ",
                                  style: TextStyle(
                                    color: Colors.amber,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _launchEmail(vendor['email']),
                                  child: Text(
                                    "${vendor['email']}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              // Navigate to the edit screen with the vendor ID
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VendorEditScreen(vendorId: vendor['id']),
                                ),
                              ).then((value) {
                                // Handle any necessary updates after returning from the edit screen
                                fetchVendorDetails();
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              // Show a confirmation dialog before deleting
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Delete Vendor"),
                                    content: const Text(
                                        "Are you sure you want to delete this vendor?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Delete the vendor and close the dialog
                                          deleteVendor(vendor['id']);
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class VendorEditScreen extends StatefulWidget {
  final String vendorId;

  const VendorEditScreen({Key? key, required this.vendorId}) : super(key: key);

  @override
  _VendorEditScreenState createState() => _VendorEditScreenState();
}

class _VendorEditScreenState extends State<VendorEditScreen> {
  final TextEditingController vendorNameController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Fetch vendor details using the provided vendorId
    fetchVendorDetails();
  }

  Future<void> fetchVendorDetails() async {
    try {
      // Access the 'vendors' collection in Firestore
      DocumentSnapshot<Map<String, dynamic>> vendorSnapshot =
          await FirebaseFirestore.instance
              .collection('vendors')
              .doc(widget.vendorId)
              .get();

      // Extract vendor details from the document snapshot
      Map<String, dynamic> vendorData = vendorSnapshot.data() ?? {};

      // Populate form fields with fetched vendor details
      vendorNameController.text = vendorData['vendorName'] ?? '';
      companyNameController.text = vendorData['companyName'] ?? '';
      addressController.text = vendorData['address'] ?? '';
      mobileNoController.text = vendorData['mobileNo'] ?? '';
      emailController.text = vendorData['email'] ?? '';
    } catch (error) {
      print('Error fetching vendor details: $error');
      // Handle error as needed
    }
  }

  Future<void> updateVendorDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() {
          _isUploading = true;
        });

        // Update vendor details in Firestore
        await FirebaseFirestore.instance
            .collection('vendors')
            .doc(widget.vendorId)
            .update({
          'vendorName': vendorNameController.text,
          'companyName': companyNameController.text,
          'address': addressController.text,
          'mobileNo': mobileNoController.text,
          'email': emailController.text,
        });

        setState(() {
          _isUploading = false;
        });

        // Show success message or navigate to another screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vendor details updated successfully')),
        );
      } catch (error) {
        // Handle Firestore error
        setState(() {
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating vendor details')),
        );
        print(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Vendor",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: _isUploading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Vendor Name'),
                      TextFormField(
                        controller: vendorNameController,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Enter Vendor Name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text('Vendor Company Name'),
                      TextFormField(
                        controller: companyNameController,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Enter Company Name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text('Vendor Address'),
                      TextFormField(
                        controller: addressController,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Enter Address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text('Vendor Mobile No'),
                      TextFormField(
                        controller: mobileNoController,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Enter Mobile No';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text('Vendor Email Id'),
                      TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Enter Email ID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          updateVendorDetails();
                        },
                        child: const Text('Update Vendor Details'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class VendorSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> vendors;

  VendorSearchDelegate(this.vendors);

  @override
  List<Widget> buildActions(BuildContext context) {
    // Actions for the search bar (e.g., clear query button)
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Leading icon on the left of the search bar (e.g., back button)
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Build the results based on the search query
    return buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Suggestions that appear below the search bar while typing
    return buildSearchResults();
  }

  Widget buildSearchResults() {
    // Build the search results based on the query
    List<Map<String, dynamic>> searchResults = vendors.where((vendor) {
      String vendorName = vendor['vendorName'].toString().toLowerCase();
      String companyName = vendor['companyName'].toString().toLowerCase();
      String address = vendor['address'].toString().toLowerCase();
      String mobileNo = vendor['mobileNo'].toString().toLowerCase();
      String email = vendor['email'].toString().toLowerCase();

      return vendorName.contains(query.toLowerCase()) ||
          companyName.contains(query.toLowerCase()) ||
          address.contains(query.toLowerCase()) ||
          mobileNo.contains(query.toLowerCase()) ||
          email.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final vendor = searchResults[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/cards1.jpg'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  Text(
                    " ${vendor['vendorName']}",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.house,
                        color: Colors.white,
                      ),
                      Text(
                        "Company Name: ${vendor['companyName']}",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_city,
                        color: Colors.white,
                      ),
                      Text(
                        "Address: ${vendor['address']}",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.contact_emergency,
                        color: Colors.white,
                      ),
                      Text(
                        "Mobile No: ${vendor['mobileNo']}",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.mail,
                        color: Colors.white,
                      ),
                      Text(
                        "Email: ${vendor['email']}",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () {
                // Navigate to the detail screen with the selected vendor
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VendorEditScreen(vendorId: vendor['id']),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
