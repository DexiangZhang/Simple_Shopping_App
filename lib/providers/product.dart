import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoritesStatus(String token, String userId) async {
    final oldStatus = isFavorite;

    // revert the value of boolean value, e.g like change to not like when click
    isFavorite = !isFavorite;

    //similar as setState() in statefulwidget to let provider to rebuild
    notifyListeners();

    final url = "https://flutter-shop-project-6b9a9.firebaseio.com/userFavoriteItems/$userId/$id.json?auth=$token";

    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}