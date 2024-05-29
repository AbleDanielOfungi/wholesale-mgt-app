import 'package:flutter/material.dart';

class SalesDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> saleDetails;

  const SalesDetailsScreen({Key? key, required this.saleDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Name: ${saleDetails["customerName"]}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Sales Date: ${saleDetails["salesDate"]}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Products Sold:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: saleDetails["products"].length,
                itemBuilder: (context, index) {
                  final product = saleDetails["products"][index];
                  return ListTile(
                    title: Text(product["productName"]),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quantity: ${product["quantity"]}'),
                        Text('Price: ${product["price"]}'),
                        Text('Type: ${product["type"]}'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
