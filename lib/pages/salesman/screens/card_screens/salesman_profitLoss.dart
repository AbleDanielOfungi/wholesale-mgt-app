import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wholesense/pages/salesman/screens/salesman_homeScreen.dart';

class SalesManProfitLoss extends StatefulWidget {
  static const routeName = "/profitLoss";

  const SalesManProfitLoss({Key? key}) : super(key: key);

  @override
  State<SalesManProfitLoss> createState() => _SalesManProfitLossState();
}

class _SalesManProfitLossState extends State<SalesManProfitLoss> {
  double totalSales = 0.0;
  double totalPurchases = 0.0;

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
            const Text("Profit Loss", style: TextStyle(fontSize: 20)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Center(child: _buildProfitLoss()),
    );
  }

  Widget _buildProfitLoss() {
    return FutureBuilder(
      // Fetch data from both collections
      future: _fetchData(),
      builder: (context, AsyncSnapshot<Map<String, double>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // Calculate profit or loss
          double profitLoss =
              snapshot.data!['totalSales']! - snapshot.data!['totalPurchases']!;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Total Sales: UGX ${snapshot.data!['totalSales']}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Total Purchases: UGX ${snapshot.data!['totalPurchases']}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                    color: Colors.green.shade200,
                    borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Profit/Loss: UGX ${profitLoss.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: profitLoss >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Future<Map<String, double>> _fetchData() async {
    // Fetch total sales
    QuerySnapshot salesSnapshot =
        await FirebaseFirestore.instance.collection('salesEntries').get();
    double totalSales = _calculateTotalSales(salesSnapshot);

    // Fetch total purchases
    QuerySnapshot purchasesSnapshot =
        await FirebaseFirestore.instance.collection('purchaseEntries').get();
    double totalPurchases = _calculateTotalPurchases(purchasesSnapshot);

    return {'totalSales': totalSales, 'totalPurchases': totalPurchases};
  }

  double _calculateTotalSales(QuerySnapshot salesSnapshot) {
    double totalSales = 0.0;
    for (QueryDocumentSnapshot<Object?> entry in salesSnapshot.docs) {
      totalSales += double.parse(entry['salesPrice'].toString());
    }
    return totalSales;
  }

  double _calculateTotalPurchases(QuerySnapshot purchasesSnapshot) {
    double totalPurchases = 0.0;
    for (QueryDocumentSnapshot<Object?> entry in purchasesSnapshot.docs) {
      totalPurchases += double.parse(entry['purchasePrice'].toString());
    }
    return totalPurchases;
  }
}
