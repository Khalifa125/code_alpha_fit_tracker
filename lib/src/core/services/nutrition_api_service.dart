import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodModel {
  final String name;
  final String? brand;
  final double calories;
  final double carbs;
  final double protein;
  final double fat;
  final double? servingSize;
  final String? imageUrl;
  final String? barcode;

  FoodModel({
    required this.name,
    this.brand,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    this.servingSize,
    this.imageUrl,
    this.barcode,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    if (product == null) {
      throw Exception('No product data found');
    }

    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};
    
    return FoodModel(
      name: product['product_name'] ?? 'Unknown',
      brand: product['brands'],
      calories: (nutriments['energy-kcal_100g'] ?? nutriments['energy-kcal'] ?? 0).toDouble(),
      carbs: (nutriments['carbohydrates_100g'] ?? nutriments['carbohydrates'] ?? 0).toDouble(),
      protein: (nutriments['proteins_100g'] ?? nutriments['proteins'] ?? 0).toDouble(),
      fat: (nutriments['fat_100g'] ?? nutriments['fat'] ?? 0).toDouble(),
      servingSize: product['serving_size'] != null 
        ? double.tryParse(product['serving_size'].toString()) 
        : null,
      imageUrl: product['image_url'],
      barcode: product['code'],
    );
  }
}

class OpenFoodFactsApi {
  static const _base = 'https://world.openfoodfacts.org';

  Future<List<FoodModel>> searchFood(String query) async {
    if (query.isEmpty) return [];

    final uri = Uri.parse(
      '$_base/cgi/search.pl?search_terms=${Uri.encodeComponent(query)}&search_simple=1&action=process&json=1&page_size=20',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        return [];
      }

      final data = json.decode(response.body);
      final products = data['products'] as List<dynamic>? ?? [];

      return products
          .where((p) => p['product_name'] != null)
          .map((p) => FoodModel.fromJson({'product': p}))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<FoodModel?> getByBarcode(String barcode) async {
    final uri = Uri.parse('$_base/api/v0/product/$barcode.json');

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body);
      if (data['status'] != 1) {
        return null;
      }

      return FoodModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}

final openFoodFactsApi = OpenFoodFactsApi();
