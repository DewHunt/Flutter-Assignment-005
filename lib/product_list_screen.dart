import 'dart:convert';

import 'package:assignment_005/add_product_screen.dart';
import 'package:assignment_005/update_product_screen.dart';
import 'package:assignment_005/product_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool _isProductListsInPrgress = false;
  List<ProductModel> productList = [];

  @override
  void initState() {
    super.initState();
    print("initState Called");
    _getAllProductList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
      ),
      body: RefreshIndicator(
        onRefresh: _getAllProductList,
        child: Visibility(
          visible: _isProductListsInPrgress == false,
          replacement: const Center(
            child: CircularProgressIndicator(),
          ),
          child: ListView.separated(
            itemCount: productList.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              return _buildProductItem(productList[index]);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductItem(ProductModel product) {
    return ListTile(
      leading: Image.network(
        'https://fabrilife.com/products/6465ff10c753e-square.jpg',
        // product.img.toString(),
        height: 60,
        fit: BoxFit.fill,
      ),
      title: Text(product.productName.toString()),
      subtitle: Wrap(
        spacing: 16,
        children: [
          Text('Unit Price: ${product.unitPrice}'),
          Text('Quantity: ${product.qty}'),
          Text('Total Price: ${product.totalPrice}'),
        ],
      ),
      trailing: Wrap(
        children: [
          IconButton(
            onPressed: () async {
              final isUpdated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateProductScreen(
                    product: product,
                  ),
                ),
              );
              if (isUpdated == true) {
                _getAllProductList();
              }
            },
            icon: const Icon(
              Icons.edit,
              color: Colors.green,
            ),
          ),
          IconButton(
            onPressed: () {
              _showDeleteConfirmationDialog(product.sId.toString());
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          )
        ],
      ),
    );
  }

  Future<void> _getAllProductList() async {
    _isProductListsInPrgress = true;
    setState(() {});
    productList.clear();
    const String photoListUrl =
        "https://crud.teamrabbil.com/api/v1/ReadProduct";
    Response response = await get(Uri.parse(photoListUrl));
    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      final allProducts = decodedData['data'];
      for (Map<String, dynamic> product in allProducts) {
        productList.add(ProductModel.fromJson(product));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Get product list failed, try again."),
      ));
    }
    _isProductListsInPrgress = false;
    setState(() {});
  }

  void _showDeleteConfirmationDialog(String productId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("DELETE"),
          content:
              const Text("Are you sure that you want to delete this product?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(productId);
                Navigator.pop(context);
              },
              child: const Text("Yes, Delete it."),
            )
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct(String productId) async {
    _isProductListsInPrgress = true;
    setState(() {});
    productList.clear();
    String deletePhotoUrl =
        "https://crud.teamrabbil.com/api/v1/DeleteProduct/$productId";
    Response response = await get(Uri.parse(deletePhotoUrl));
    if (response.statusCode == 200) {
      _getAllProductList();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Product deleted successfully."),
      ));
    } else {
      _isProductListsInPrgress = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Delete product failed, try again."),
      ));
    }
  }
}
