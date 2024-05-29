// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';


// class SalesGraphScreen extends StatefulWidget {
//   static const routeName = "/salesGraph";
//   const SalesGraphScreen({Key? key}) : super(key: key);

//   @override
//   State<SalesGraphScreen> createState() => _SalesGraphScreenState();
// }

// class _SalesGraphScreenState extends State<SalesGraphScreen> {
//   List<charts.Series<dynamic, num>> _seriesList = [];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Sales Graph"),
//         centerTitle: true,
//       ),
//       body: FutureBuilder(
//         future: FirebaseFirestore.instance.collection('salesEntries').get(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No sales entries found.'));
//           } else {
//             _seriesList = _generateData(snapshot.data!.docs);

//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: charts.LineChart(
//                 _seriesList,
//                 animate: true,
//                 animationDuration: const Duration(seconds: 1),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }

//   List<charts.Series<dynamic, num>> _generateData(List<QueryDocumentSnapshot> salesEntries) {
//     List<charts.Series<dynamic, num>> seriesList = [
//       charts.Series<dynamic, num>(
//         id: 'Sales',
//         colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
//         domainFn: (entry, _) => entry['index'],
//         measureFn: (entry, _) => double.parse(entry['salesPrice'].toString()),
//         data: salesEntries.asMap().entries.map((entry) {
//           final index = entry.key.toDouble();
//           final salesPrice = double.parse(entry.value['salesPrice'].toString());
//           return {'index': index, 'salesPrice': salesPrice};
//         }).toList(),
//       ),
//     ];

//     return seriesList;
//   }
// }
