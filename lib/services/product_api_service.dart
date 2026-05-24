import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

/// Équivalent de SerieApiService dans TD6.
/// Encapsule les appels HTTP vers Platzi Fake Store API.
/// Le client HTTP est injectable pour les tests (même pattern TD6).
class ProductApiService {
  static const _baseUrl = 'https://api.escuelajs.co/api/v1';
  static const _timeout = Duration(seconds: 10);

  final http.Client _client;

  /// [client] est injecté — par défaut http.Client() en production.
  /// En test, on injecte un MockHttpClient (comme TD6).
  ProductApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Product>> fetchProducts({
    int offset = 0,
    int limit = 20,
    String? title,
    int? categoryId,
    double? priceMin,
    double? priceMax,
  }) async {
    final params = <String, String>{
      'offset': offset.toString(),
      'limit': limit.toString(),
    };
    if (title != null && title.isNotEmpty) params['title'] = title;
    if (categoryId != null) params['categoryId'] = categoryId.toString();
    if (priceMin != null) params['price_min'] = priceMin.toString();
    if (priceMax != null) params['price_max'] = priceMax.toString();

    final uri = Uri.parse('$_baseUrl/products').replace(queryParameters: params);
    final response = await _client.get(uri).timeout(_timeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => Product.fromJson(j as Map<String, dynamic>)).toList();
    }
    throw Exception('Erreur HTTP ${response.statusCode}');
  }

  Future<Product> fetchProductById(int id) async {
    final uri = Uri.parse('$_baseUrl/products/$id');
    final response = await _client.get(uri).timeout(_timeout);
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Produit $id introuvable');
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final uri = Uri.parse('$_baseUrl/categories');
    final response = await _client.get(uri).timeout(_timeout);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Erreur HTTP ${response.statusCode}');
  }

  Future<Product> createProduct({
    required String title,
    required double price,
    required String description,
    required int categoryId,
  }) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/products/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'title': title,
            'price': price,           // number, pas int (doc officielle)
            'description': description,
            'categoryId': categoryId,
            'images': ['https://placehold.co/600x400'], // URL valide selon la doc
          }),
        )
        .timeout(_timeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Erreur création produit ${response.statusCode}');
  }

  /// Données de secours si le réseau est indisponible — comme TD6.
  List<Product> getMockProducts() => [
        const Product(
          id: 0,
          title: 'Mode hors-ligne',
          price: 0,
          description: 'Pas de connexion réseau.',
          category: '-',
        ),
      ];
}
