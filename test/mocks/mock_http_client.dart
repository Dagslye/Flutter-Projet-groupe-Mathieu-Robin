import 'dart:convert';
import 'package:http/http.dart' as http;

/// Client HTTP de substitution pour les tests.
/// Copie exacte du mock fourni dans TD6.
/// Retourne des réponses prédéfinies sans appels réseau réels.
class MockHttpClient extends http.BaseClient {
  final int statusCode;
  final dynamic body;

  MockHttpClient({this.statusCode = 200, required this.body});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final bytes = utf8.encode(jsonEncode(body));
    return http.StreamedResponse(
      Stream.value(bytes),
      statusCode,
      headers: {'content-type': 'application/json'},
    );
  }
}

/// Client qui simule une erreur réseau (timeout, pas de connexion…)
/// Copie exacte de TD6.
class MockHttpClientError extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    throw Exception('Pas de connexion réseau');
  }
}
