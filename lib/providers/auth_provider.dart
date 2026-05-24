import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_api_service.dart';
import '../services/preferences_service.dart';

/// Provider d'authentification — même pattern d'injection que TD6.
class AuthProvider with ChangeNotifier {
  final AuthApiService _authService;
  final PreferencesService _prefsService;

  AppUser? _user;
  String? _token;
  String? _refreshToken;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _user != null;
  String? get error => _error;

  AuthProvider({
    AuthApiService? authService,
    PreferencesService? prefsService,
  })  : _authService = authService ?? AuthApiService(),
        _prefsService = prefsService ?? PreferencesService() {
    tryAutoLogin();
  }

  /// Restaure la session depuis SharedPreferences au démarrage.
  Future<void> tryAutoLogin() async {
    final token = await _prefsService.getToken();
    final user = await _prefsService.getSavedUser();
    final refreshTk = await _prefsService.getRefreshToken();
    if (token != null && user != null) {
      _token = token;
      _refreshToken = refreshTk;
      _user = user;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // POST /auth/login → { access_token, refresh_token }
      final data = await _authService.login(email, password);
      _token = data['access_token'] as String?;
      _refreshToken = data['refresh_token'] as String?;
      if (_token == null) throw Exception('Token manquant');

      // GET /auth/profile avec Bearer token
      _user = await _authService.getProfile(_token!);

      // Persistance locale
      await _prefsService.saveToken(_token!);
      if (_refreshToken != null) {
        await _prefsService.saveRefreshToken(_refreshToken!);
      }
      await _prefsService.saveUser(_user!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Inscription avec vérification d'email disponible (POST /users/is-available).
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // Vérification email disponible avant création
      final available = await _authService.isEmailAvailable(email);
      if (!available) {
        _error = 'Cet email est déjà utilisé.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      // POST /users/ → création compte
      await _authService.register(name: name, email: email, password: password);
      // Auto-login après inscription
      return await login(email, password);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Rafraîchit l'access_token via POST /auth/refresh-token.
  Future<bool> refreshSession() async {
    if (_refreshToken == null) return false;
    try {
      final data = await _authService.refreshToken(_refreshToken!);
      _token = data['access_token'] as String?;
      _refreshToken = data['refresh_token'] as String?;
      if (_token != null) {
        await _prefsService.saveToken(_token!);
        if (_refreshToken != null) {
          await _prefsService.saveRefreshToken(_refreshToken!);
        }
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await _prefsService.clearAuth();
    _token = null;
    _refreshToken = null;
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
