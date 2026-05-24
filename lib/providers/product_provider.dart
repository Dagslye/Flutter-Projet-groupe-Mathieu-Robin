import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_api_service.dart';

/// Équivalent de SerieProvider dans TD6.
/// Même pattern : service injectable, fallback mock si réseau indisponible.
class ProductProvider with ChangeNotifier {
  final ProductApiService _apiService;

  List<Product> _products = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  int? _selectedCategoryId;

  List<Product> get products => _products;
  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  int? get selectedCategoryId => _selectedCategoryId;

  /// [apiService] est optionnel — null en production, injecté en test.
  ProductProvider({ProductApiService? apiService})
      : _apiService = apiService ?? ProductApiService();

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _products = await _apiService.fetchProducts(
        title: _searchQuery.isNotEmpty ? _searchQuery : null,
        categoryId: _selectedCategoryId,
        limit: 50,
      );
    } catch (_) {
      _error = 'Impossible de charger les articles.';
      _products = _apiService.getMockProducts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    try {
      _categories = await _apiService.fetchCategories();
      notifyListeners();
    } catch (_) {}
  }

  Future<Product> fetchProductById(int id) async {
    return _apiService.fetchProductById(id);
  }

  Future<Product> createProduct({
    required String title,
    required double price,
    required String description,
    required int categoryId,
  }) async {
    return _apiService.createProduct(
      title: title,
      price: price,
      description: description,
      categoryId: categoryId,
    );
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchProducts();
  }

  void setCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    fetchProducts();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    fetchProducts();
  }
}
