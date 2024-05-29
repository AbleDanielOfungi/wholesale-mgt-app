import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wholesense/pages/admin/adminHome.dart';

class AdminMinQuantityAlertScreen extends StatefulWidget {
  @override
  _AdminMinQuantityAlertScreenState createState() =>
      _AdminMinQuantityAlertScreenState();
}

class _AdminMinQuantityAlertScreenState
    extends State<AdminMinQuantityAlertScreen> {
  List<Map<String, dynamic>> productsBelowMinQuantity = [];

  @override
  void initState() {
    super.initState();
    fetchProductsBelowMinQuantity();
  }

  Future<void> fetchProductsBelowMinQuantity() async {
    try {
      // Fetch products from Firestore where quantity is below the minimum threshold
      QuerySnapshot purchaseEntrySnapshot = await FirebaseFirestore.instance
          .collection('purchaseEntries')
          .where('purchaseQuantity', isLessThanOrEqualTo: 10)
          .get();

      // Extract purchase entry data from the snapshot
      productsBelowMinQuantity = purchaseEntrySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {});
    } catch (e) {
      print('Error fetching purchase entries below minimum quantity: $e');
    }
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
            const Text('Minimum Quantity Alert',
                style: TextStyle(fontSize: 20)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: productsBelowMinQuantity.isEmpty
          ? Center(
              child: Text('No purchase entries below minimum quantity alert'),
            )
          : ListView.builder(
              itemCount: productsBelowMinQuantity.length,
              itemBuilder: (context, index) {
                final product = productsBelowMinQuantity[index];
                return ListTile(
                  title: Text(product['productName'] ?? 'Product Name'),
                  subtitle: Text('Quantity: ${product['purchaseQuantity']}'),
                  // You can customize the UI based on your requirements
                );
              },
            ),
    );
  }
}
