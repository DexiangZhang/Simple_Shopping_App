import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  final String loginToken;
  final String userId;

  Products(this.loginToken,this.userId,this._items);

  List<Product> get items {
    /* return a copy of the items lists, [] means a list, ... means takes _items
    value out
     */
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((proItem) => proItem.isFavorite).toList();
  }
  
  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetUpProducts([bool filterByUser = false]) async {

    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = 'https://flutter-shop-project-6b9a9.firebaseio.com/products.json?auth=$loginToken&$filterString';

    try {
      final response = await http.get(url);

      // either dynamic or object, for map inside a map, otherwise dart will give us an error
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if(extractedData == null) {
        return;
      }

      url = "https://flutter-shop-project-6b9a9.firebaseio.com/userFavoriteItems/$userId.json?auth=$loginToken";

      final favoriteStatus = await http.get(url);
      final favoriteData = json.decode(favoriteStatus.body);
      final List<Product>loadedProducts = [];
      
      extractedData.forEach((productId, data) { 
        loadedProducts.add(Product(
          id: productId,
          title: data['title'],
          description: data['description'],
          price: data['price'],
          isFavorite: favoriteData == null ? false : favoriteData[productId] ?? false,
          imageUrl: data['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw(error);
    }
  }

  Future<void> addProduct(Product product) async {

    final url = "https://flutter-shop-project-6b9a9.firebaseio.com/products.json?auth=$loginToken";

    try {
      final response = await http.post(
        url,
        body: json.encode({
          "title": product.title,
          "description": product.description,
          "imageUrl": product.imageUrl,
          "price": product.price,
          "creatorId": userId,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct (String id, Product newProduct ) async {
    final productIndex = _items.indexWhere((prod) => prod.id == id);
    if(productIndex >=0) {

      //update database data here
      final url = "https://flutter-shop-project-6b9a9.firebaseio.com/products/$id.json?auth=$loginToken";
      await http.patch(url, body: json.encode({
        "title": newProduct.title,
        "description": newProduct.description,
        "imageUrl": newProduct.imageUrl,
        "price": newProduct.price,
      }));

      // update local memory here
      _items[productIndex] = newProduct;
      notifyListeners();
    }
  }

  // using a techinque called "optimisic updating" (optional)
  Future<void> deleteProduct (String id) async {
    final url = "https://flutter-shop-project-6b9a9.firebaseio.com/products/$id.json?auth=$loginToken";
    final existingProductIndex = _items.indexWhere((produId) => produId.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);

    if(response.statusCode >= 400) {
      // reinsert the product you deleted before
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();

      throw HttpException("Could not delete product.");
    }
      existingProduct = null;
  }
}