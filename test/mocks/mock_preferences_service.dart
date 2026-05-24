import 'package:marketplace_app/models/product.dart';
import 'package:marketplace_app/models/user.dart';
import 'package:marketplace_app/services/preferences_service.dart';

/// Substitut de PreferencesService qui stocke en mémoire.
/// Équivalent exact de MockPreferencesService dans TD6.
class MockPreferencesService extends PreferencesService {
  List<Product> _favoris = [];
  String? _token;
  AppUser? _user;

  @override
  Future<List<Product>> getFavoris() async => List.from(_favoris);

  @override
  Future<void> saveFavoris(List<Product> favoris) async {
    _favoris = List.from(favoris);
  }

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<AppUser?> getSavedUser() async => _user;

  @override
  Future<void> saveUser(AppUser user) async => _user = user;

  @override
  Future<void> clearAuth() async {
    _token = null;
    _user = null;
  }
}
