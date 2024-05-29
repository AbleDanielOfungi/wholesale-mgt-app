import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../salesman_homeScreen.dart';

class SalesManProductList extends StatefulWidget {
  static const routeName = '/productList';

  const SalesManProductList({super.key});

  @override
  State<SalesManProductList> createState() => _SalesManProductListState();
}

class _SalesManProductListState extends State<SalesManProductList> {
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
            const Text("Product List", style: TextStyle(fontSize: 20)),
            const Icon(
              Icons.arrow_circle_left_outlined,
              color: Colors.green,
            )
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: const ProductListView(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          //add popular products
          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return const AddPopularProductScreen();
          // }));
        },
        child: const Icon(
          Icons.add,
          color: Colors.green,
        ),
      ),
    );
  }
}

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  _ProductListViewState createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> deleteProduct(String productId) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .delete();
  }

  List<Map<String, dynamic>> _filteredProducts(
      List<DocumentSnapshot> products) {
    final searchQuery = _searchController.text.toLowerCase();
    return products
        .where((product) =>
            product['name']!.toLowerCase().contains(searchQuery) ||
            product['description']!.toLowerCase().contains(searchQuery))
        .map((product) => product.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Search products',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Extracting the product data from the snapshot
              final products = snapshot.data?.docs ?? [];

              // Filtering products based on the search query
              final filteredProducts = _filteredProducts(products);

              return ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  // Extracting product details from the document
                  final product = filteredProducts[index];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(product['imageURL'] ?? ''),
                        ),
                        title: Text(product['name'] ?? 'Product Name'),
                        subtitle: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            decoration: BoxDecoration(
                                color: const Color.fromRGBO(76, 175, 80, 1),
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Quantity Icon
                                  Text(
                                    'Available: ${product['quantity'] ?? 'N/A'}',
                                  ),
                                  const SizedBox(width: 20),

                                  // Delete Icon
                                  // GestureDetector(
                                  //   onTap: () async {
                                  //     await deleteProduct(product['id']);
                                  //   },
                                  //   child: Icon(
                                  //     Icons.delete,
                                  //     color: Colors.red,
                                  //   ),
                                  // ),
                                  // const SizedBox(width: 20),

                                  // Edit Icon
                                  // GestureDetector(
                                  //   onTap: () {
                                  //     Navigator.push(context,
                                  //         MaterialPageRoute(builder: (context) {
                                  //       return ProductUpdateScreen(
                                  //         productId: product['id'],
                                  //       );
                                  //     }));
                                  //   },
                                  //   child: Icon(
                                  //     Icons.edit,
                                  //     color: Colors.white,
                                  //   ),
                                  // ),
                                  const SizedBox(width: 20),

                                  // Info Icon - Display Product Quantity and Description
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Product Details'),
                                            content: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'name: ${product['name'] ?? 'N/A'}',
                                                ),
                                                Text(
                                                  'Price: Shs ${product['price'] ?? 'N/A'}',
                                                ),
                                                Text(
                                                  'Available Quantity: ${product['quantity'] ?? 'N/A'}',
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  'Description: ${product['description'] ?? 'N/A'}',
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Icon(
                                      Icons.info,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          // You can add navigation or other actions here
                          // For example, navigate to a detailed product screen
                          // Navigator.pushNamed(context, '/productDetails', arguments: product);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
