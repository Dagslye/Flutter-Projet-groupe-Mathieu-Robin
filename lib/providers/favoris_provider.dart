import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/preferences_service.dart';

/// Équivalent exact de FavorisProvider dans TD6.
/// Injection de PreferencesService pour la testabilité.
class FavorisProvider with ChangeNotifier {
  final PreferencesService _prefsService;

  List<Product> _favoris = [];
  List<Product> get favoris => _favoris;

  /// [prefsService] optionnel — null en production, injecté en test.
  FavorisProvider({PreferencesService? prefsService})
      : _prefsService = prefsService ?? PreferencesService() {
    _chargerFavoris();
  }

  Future<void> _chargerFavoris() async {
    _favoris = await _prefsService.getFavoris();
    notifyListeners();
  }

  Future<void> toggleFavori(Product product) async {
    if (_favoris.any((p) => p.id == product.id)) {
      _favoris.removeWhere((p) => p.id == product.id);
    } else {
      _favoris.add(product);
    }
    await _prefsService.saveFavoris(_favoris);
    notifyListeners();
  }

  bool estFavori(int productId) => _favoris.any((p) => p.id == productId);
}
