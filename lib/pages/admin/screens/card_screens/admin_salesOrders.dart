import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wholesense/pages/admin/adminHome.dart';
import 'package:wholesense/pages/admin/screens/card_screens/admin_salesEntry.dart';

class AdminSaleOrder extends StatefulWidget {
  static const routeName = "/saleorder";
  const AdminSaleOrder({Key? key}) : super(key: key);

  @override
  State<AdminSaleOrder> createState() => _AdminSaleOrderState();
}

class _AdminSaleOrderState extends State<AdminSaleOrder> {
  final TextEditingController _productNameController = TextEditingController();

  bool _searching = false;

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
            const Text("Sales Orders", style: TextStyle(fontSize: 20)),
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
              setState(() {
                _searching = !_searching;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: _searching ? _buildSearchResults() : _buildSalesEntries(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const AdminSalesEntry();
          }));
        },
        child: const Icon(
          Icons.add,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildSalesEntries() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('salesEntries').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No sales entries found.'));
        } else {
          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Record')),
                    DataColumn(label: Text('Product Name')),
                    DataColumn(label: Text('Customer Name')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: snapshot.data!.docs.asMap().entries.map((entry) {
                    final int rowIndex = entry.key + 1;
                    final QueryDocumentSnapshot<Object?> salesEntry =
                        entry.value;

                    String currentProductName =
                        salesEntry['productName'].toString();
                    String currentCustomerName =
                        salesEntry['customerName'].toString();
                    String currentQuantity =
                        salesEntry['salesQuantity'].toString();
                    String currentDate = salesEntry['salesDate'].toString();
                    String currentPrice = salesEntry['salesPrice'].toString();
                    String currentType = salesEntry['salesType'].toString();

                    return DataRow(cells: [
                      DataCell(Text('$rowIndex')),
                      DataCell(Text(currentProductName)),
                      DataCell(Text(currentCustomerName)),
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
                                //     _showEditDialog(
                                //       salesEntry.id,
                                //       currentProductName,
                                //       currentCustomerName,
                                //       currentQuantity,
                                //       currentDate,
                                //       currentPrice,
                                //       currentType,
                                //);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                //_deleteSalesEntry(salesEntry.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Display Total Sales Order
              Text(
                'Total Sales Order: UGX ${_calculateTotalSalesOrder(snapshot.data!.docs)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildSearchResults() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _productNameController,
            decoration: InputDecoration(
              labelText: 'Search by Product Name',
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _productNameController.clear();
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('salesEntries')
                .where('productName',
                    isGreaterThanOrEqualTo: _productNameController.text)
                .where('productName',
                    isLessThan: '${_productNameController.text}z')
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                List<QueryDocumentSnapshot> searchResults = snapshot.data!.docs;

                return _buildSearchResultsTable(searchResults);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsTable(List<QueryDocumentSnapshot> searchResults) {
    if (searchResults.isEmpty) {
      return const Center(
        child: Text(
          'No matching sales entries found.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Record')),
          DataColumn(label: Text('Product Name')),
          DataColumn(label: Text('Customer Name')),
          DataColumn(label: Text('Quantity')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Price')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Actions')),
        ],
        rows: searchResults.asMap().entries.map((entry) {
          final int rowIndex = entry.key + 1;
          final QueryDocumentSnapshot<Object?> salesEntry = entry.value;

          String currentProductName = salesEntry['productName'].toString();
          String currentCustomerName = salesEntry['customerName'].toString();
          String currentQuantity = salesEntry['salesQuantity'].toString();
          String currentDate = salesEntry['salesDate'].toString();
          String currentPrice = salesEntry['salesPrice'].toString();
          String currentType = salesEntry['salesType'].toString();

          return DataRow(cells: [
            DataCell(Text('$rowIndex')),
            DataCell(Text(currentProductName)),
            DataCell(Text(currentCustomerName)),
            DataCell(Text(currentQuantity)),
            DataCell(Text(currentDate)),
            DataCell(Text(currentPrice)),
            DataCell(Text(currentType)),
            DataCell(
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      // _showEditDialog(
                      //   salesEntry.id,
                      //   currentProductName,
                      //   currentCustomerName,
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
                      // _deleteSalesEntry(salesEntry.id);
                    },
                  ),
                ],
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  double _calculateTotalSalesOrder(
      List<QueryDocumentSnapshot<Object?>> salesEntries) {
    double totalSalesOrder = 0.0;
    for (var entry in salesEntries) {
      totalSalesOrder += double.parse(entry['salesPrice'].toString());
    }
    return totalSalesOrder;
  }

  void _showEditDialog(
    String documentId,
    String productName,
    String customerName,
    String salesQuantity,
    String salesDate,
    String salesPrice,
    String salesType,
  ) {
    TextEditingController _customerNameController =
        TextEditingController(text: customerName);
    TextEditingController _salesQuantityController =
        TextEditingController(text: salesQuantity);
    TextEditingController _salesDateController =
        TextEditingController(text: salesDate);
    TextEditingController _salesPriceController =
        TextEditingController(text: salesPrice);
    TextEditingController _salesTypeController =
        TextEditingController(text: salesType);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Sales Entry'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                ),
                TextField(
                  controller: _salesQuantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
                TextField(
                  controller: _salesDateController,
                  decoration: const InputDecoration(labelText: 'Date'),
                ),
                TextField(
                  controller: _salesPriceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: _salesTypeController,
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
              onPressed: () {
                _updateSalesEntry(
                  documentId,
                  productName,
                  _customerNameController.text,
                  _salesQuantityController.text,
                  _salesDateController.text,
                  _salesPriceController.text,
                  _salesTypeController.text,
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

  void _updateSalesEntry(
    String documentId,
    String productName,
    String customerName,
    String salesQuantity,
    String salesDate,
    String salesPrice,
    String salesType,
  ) {
    FirebaseFirestore.instance
        .collection('salesEntries')
        .doc(documentId)
        .update({
      'productName': productName,
      'customerName': customerName,
      'salesQuantity': salesQuantity,
      'salesDate': salesDate,
      'salesPrice': salesPrice,
      'salesType': salesType,
    });
  }

  void _deleteSalesEntry(String documentId) {
    FirebaseFirestore.instance
        .collection('salesEntries')
        .doc(documentId)
        .delete();
  }
}
