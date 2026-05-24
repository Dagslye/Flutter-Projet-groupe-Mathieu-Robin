import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/user.dart';

/// Équivalent exact de PreferencesService dans TD6.
/// Gère favoris (comme TD6) + token d'auth persistant + refresh token.
class PreferencesService {
  static const _favorisKey = 'favoris';
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _userKey = 'auth_user';

  // ─── Favoris (même pattern que TD6) ────────────────────────────────────────

  Future<List<Product>> getFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_favorisKey);
    if (jsonStr == null) return [];
    final List<dynamic> data = jsonDecode(jsonStr);
    return data.map((j) => Product.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<void> saveFavoris(List<Product> favoris) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(favoris.map((p) => p.toJson()).toList());
    await prefs.setString(_favorisKey, jsonStr);
  }

  // ─── Access Token ────────────────────────────────────────────────────────────

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // ─── Refresh Token (doc officielle : POST /auth/refresh-token) ─────────────

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  // ─── Profil utilisateur ─────────────────────────────────────────────────────

  Future<AppUser?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_userKey);
    if (jsonStr == null) return null;
    return AppUser.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  Future<void> saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
  }
}
