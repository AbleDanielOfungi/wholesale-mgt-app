//create a screen to show all purchase entry edit records

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wholesense/pages/salesman/screens/salesman_homeScreen.dart';

class SalesManPurchaseOrder extends StatefulWidget {
  static const routeName = '/purchaseOrder';

  const SalesManPurchaseOrder({Key? key}) : super(key: key);

  @override
  State<SalesManPurchaseOrder> createState() => _SalesManPurchaseOrderState();
}

class _SalesManPurchaseOrderState extends State<SalesManPurchaseOrder> {
  double totalPurchaseSum = 0.0;

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
                  return const SalesManHomeScreen();
                }));
              },
              child: const Icon(Icons.arrow_circle_left_outlined),
            ),
            const Text("Purchase Orders", style: TextStyle(fontSize: 20)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical, child: _buildPurchaseEntries()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          showSearch(
            context: context,
            delegate: PurchaseSearchDelegate(),
          );
        },
        child: const Icon(Icons.search, color: Colors.green),
      ),
    );
  }

  Widget _buildPurchaseEntries() {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('purchaseEntries').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No purchase orders found.'));
        } else {
          double totalPurchaseSum =
              calculateTotalPurchaseSum(snapshot.data!.docs);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Purchase Sum:',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ' \Ugx${totalPurchaseSum.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Record')),
                    DataColumn(label: Text('Product Name')),
                    DataColumn(label: Text('Vendor Name')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: snapshot.data!.docs.asMap().entries.map((entry) {
                    final int rowIndex = entry.key + 1;
                    final QueryDocumentSnapshot<Object?> purchaseEntry =
                        entry.value;

                    String currentProductName =
                        purchaseEntry['productName'].toString();
                    String currentVendorName =
                        purchaseEntry['vendorName'].toString();
                    String currentQuantity =
                        purchaseEntry['purchaseQuantity'].toString();
                    String currentDate =
                        purchaseEntry['purchaseDate'].toString();
                    String currentPrice =
                        purchaseEntry['purchasePrice'].toString();
                    String currentType =
                        purchaseEntry['purchaseType'].toString();

                    return DataRow(cells: [
                      DataCell(Text('$rowIndex')),
                      DataCell(Text(currentProductName)),
                      DataCell(Text(currentVendorName)),
                      DataCell(Text(currentQuantity)),
                      DataCell(Text(currentDate)),
                      DataCell(Text(currentPrice)),
                      DataCell(Text(currentType)),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // showEditDialog(
                                //   purchaseEntry.id,
                                //   currentProductName,
                                //   currentVendorName,
                                //   currentQuantity,
                                //   currentDate,
                                //   currentPrice,
                                //   currentType,
                                // );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                // deletePurchaseEntry(purchaseEntry.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  double calculateTotalPurchaseSum(
      List<QueryDocumentSnapshot<Object?>> purchaseEntries) {
    double totalSum = 0.0;
    for (var doc in purchaseEntries) {
      totalSum += double.parse(doc['purchasePrice'].toString());
    }
    return totalSum;
  }

  Future<void> editPurchaseEntry(
    String documentId,
    String newProductName,
    String newVendorName,
    String newQuantity,
    String newDate,
    String newPrice,
    String newType,
  ) async {
    // Convert quantity and price to integers by rounding
    int quantity = newQuantity.isEmpty
        ? 0
        : newQuantity.contains('.')
            ? double.parse(newQuantity).round()
            : int.parse(newQuantity);

    int price = newPrice.isEmpty
        ? 0
        : newPrice.contains('.')
            ? double.parse(newPrice).round()
            : int.parse(newPrice);

    await FirebaseFirestore.instance
        .collection('purchaseEntries')
        .doc(documentId)
        .update({
      'productName': newProductName,
      'vendorName': newVendorName,
      'purchaseQuantity': quantity,
      'purchaseDate': newDate,
      'purchasePrice': price,
      'purchaseType': newType,
    });

    await updateTotalPurchaseSum();
  }

  Future<void> deletePurchaseEntry(String documentId) async {
    await FirebaseFirestore.instance
        .collection('purchaseEntries')
        .doc(documentId)
        .delete();

    await updateTotalPurchaseSum();
  }

  Future<void> updateTotalPurchaseSum() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('purchaseEntries').get();

    double totalSum = 0.0;
    for (var doc in snapshot.docs) {
      totalSum += double.parse(doc['purchasePrice'].toString());
    }

    setState(() {
      totalPurchaseSum = totalSum;
    });
  }

  void showEditDialog(
    String documentId,
    String currentProductName,
    String currentVendorName,
    String currentQuantity,
    String currentDate,
    String currentPrice,
    String currentType,
  ) {
    TextEditingController productNameController =
        TextEditingController(text: currentProductName);
    TextEditingController vendorNameController =
        TextEditingController(text: currentVendorName);
    TextEditingController quantityController =
        TextEditingController(text: currentQuantity);
    TextEditingController dateController =
        TextEditingController(text: currentDate);
    TextEditingController priceController =
        TextEditingController(text: currentPrice);
    TextEditingController typeController =
        TextEditingController(text: currentType);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Purchase Entry'),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: productNameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: vendorNameController,
                  decoration: const InputDecoration(labelText: 'Vendor Name'),
                ),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Date'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: 'Type'),
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
              onPressed: () async {
                await editPurchaseEntry(
                  documentId,
                  productNameController.text,
                  vendorNameController.text,
                  quantityController.text,
                  dateController.text,
                  priceController.text,
                  typeController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class PurchaseSearchDelegate extends SearchDelegate<String> {
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
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('purchaseEntries')
          .where('productName', isGreaterThanOrEqualTo: query)
          .where('productName', isLessThan: '${query}z')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No results found.'));
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Product Name')),
                DataColumn(label: Text('Vendor Name')),
                DataColumn(label: Text('Quantity')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Price')),
                DataColumn(label: Text('Type')),
              ],
              rows: snapshot.data!.docs.map((document) {
                String productName = document['productName'];
                String vendorName = document['vendorName'];
                String quantity = document['purchaseQuantity'].toString();
                String date = document['purchaseDate'];
                String price = document['purchasePrice'].toString();
                String type = document['purchaseType'];

                return DataRow(cells: [
                  DataCell(Text(productName)),
                  DataCell(Text(vendorName)),
                  DataCell(Text(quantity)),
                  DataCell(Text(date)),
                  DataCell(Text(price)),
                  DataCell(Text(type)),
                ]);
              }).toList(),
            ),
          );
        }
      },
    );
  }
}
