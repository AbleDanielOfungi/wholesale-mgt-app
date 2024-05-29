import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SalesManProfitLossScreen extends StatefulWidget {
  static const routeName = '/profitLoss';

  @override
  _SalesManProfitLossScreenState createState() =>
      _SalesManProfitLossScreenState();
}

class _SalesManProfitLossScreenState extends State<SalesManProfitLossScreen> {
  List<Map<String, dynamic>> salesData = [];
  List<Map<String, dynamic>> purchaseData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Fetch sales data
      QuerySnapshot salesSnapshot =
          await FirebaseFirestore.instance.collection('salesEntries').get();
      setState(() {
        salesData = salesSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });

      // Fetch purchase data
      QuerySnapshot purchaseSnapshot =
          await FirebaseFirestore.instance.collection('purchaseEntries').get();
      setState(() {
        purchaseData = purchaseSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  double calculateTotalSales() {
    return salesData
        .map((sale) => sale['salesQuantity'] * sale['salesPrice'])
        .fold(0, (a, b) => a + b);
  }

  double calculateTotalPurchaseCost() {
    return purchaseData
        .map((purchase) =>
            purchase['purchaseQuantity'] * purchase['purchasePrice'])
        .fold(0, (a, b) => a + b);
  }

  double calculateProfitLoss() {
    return calculateTotalSales() - calculateTotalPurchaseCost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profit and Loss'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Sales: ${NumberFormat.currency(symbol: 'shs').format(calculateTotalSales())}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Total Purchase Cost: ${NumberFormat.currency(symbol: 'shs').format(calculateTotalPurchaseCost())}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Profit/Loss: ${NumberFormat.currency(symbol: 'shs').format(calculateProfitLoss())}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
