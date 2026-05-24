import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

/// Service d'authentification — pattern injection identique à TD6.
///
/// Endpoints doc officielle https://fakeapi.platzi.com/en/rest/auth-jwt/ :
///   POST /auth/login          → { access_token, refresh_token }
///   GET  /auth/profile        → AppUser  (Bearer token requis)
///   POST /auth/refresh-token  → { access_token, refresh_token }
///   POST /users/              → crée un compte
///   POST /users/is-available  → vérifie si email libre
class AuthApiService {
  static const _baseUrl = 'https://api.escuelajs.co/api/v1';
  static const _timeout = Duration(seconds: 10);

  final http.Client _client;

  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Retourne { "access_token": "...", "refresh_token": "..." }
  /// access_token valide 20 jours, refresh_token valide 10 heures.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(_timeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Email ou mot de passe incorrect');
  }

  /// Profil utilisateur connecté via Bearer token.
  Future<AppUser> getProfile(String accessToken) async {
    final response = await _client
        .get(
          Uri.parse('$_baseUrl/auth/profile'),
          headers: {'Authorization': 'Bearer $accessToken'},
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return AppUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Session expirée');
  }

  /// Rafraîchit l'access_token via le refresh_token.
  /// Retourne { "access_token": "...", "refresh_token": "..." }
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/auth/refresh-token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refreshToken}),
        )
        .timeout(_timeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Impossible de renouveler la session');
  }

  /// Crée un compte utilisateur.
  /// Body requis : name, email, password, avatar (URL).
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/users/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
            'avatar': 'https://picsum.photos/200', // URL valide requise
          }),
        )
        .timeout(_timeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AppUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(body['message'] ?? 'Erreur création compte');
  }

  /// Vérifie si un email est disponible avant inscription.
  /// Retourne true si disponible, false si déjà utilisé.
  Future<bool> isEmailAvailable(String email) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/users/is-available'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        )
        .timeout(_timeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['isAvailable'] == true;
    }
    return false;
  }
}
