import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/cart_database_service.dart';

/// Équivalent de WatchlistProvider dans TD6.
/// Injection de CartDatabaseService — même pattern qu'à l'étape 8 du TD6.
class CartProvider with ChangeNotifier {
  final CartDatabaseService _dbService;

  List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  double get total => _items.fold(0.0, (sum, i) => sum + i.totalPrice);

  /// [dbService] optionnel — null en production, injecté en test (base in-memory).
  CartProvider({CartDatabaseService? dbService})
      : _dbService = dbService ?? CartDatabaseService() {
    _chargerPanier();
  }

  Future<void> _chargerPanier() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _dbService.getCart();
    } catch (_) {
      _items = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> ajouterAuPanier(Product product) async {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    await _dbService.saveCart(_items);
    notifyListeners();
  }

  Future<void> retirerDuPanier(int productId) async {
    _items.removeWhere((i) => i.product.id == productId);
    await _dbService.saveCart(_items);
    notifyListeners();
  }

  Future<void> decrementerQuantite(int productId) async {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index < 0) return;
    if (_items[index].quantity <= 1) {
      await retirerDuPanier(productId);
    } else {
      _items[index].quantity--;
      await _dbService.saveCart(_items);
      notifyListeners();
    }
  }

  Future<void> validerPanier() async {
    _items.clear();
    await _dbService.clearCart();
    notifyListeners();
  }

  bool estDansLePanier(int productId) =>
      _items.any((i) => i.product.id == productId);

  CartItem? getItem(int productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    return index >= 0 ? _items[index] : null;
  }
}
