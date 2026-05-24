import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/services/product_api_service.dart';
import '../../helpers/test_data.dart';
import '../../mocks/mock_http_client.dart';

void main() {
  group('ProductApiService', () {
    test('fetchProducts retourne une liste de Products en cas de succès', () async {
      final service = ProductApiService(
        client: MockHttpClient(body: mockProductsJson),
      );
      final products = await service.fetchProducts();
      expect(products.length, 2);
      expect(products[0].title, 'Chaise ergonomique');
      expect(products[1].title, 'Clavier mécanique');
    });

    test('fetchProducts lève une exception si le statut HTTP est 500', () async {
      final service = ProductApiService(
        client: MockHttpClient(statusCode: 500, body: ''),
      );
      expect(() => service.fetchProducts(), throwsException);
    });

    test('fetchProducts lève une exception si le réseau est indisponible', () async {
      final service = ProductApiService(client: MockHttpClientError());
      expect(() => service.fetchProducts(), throwsException);
    });

    test('fetchProductById retourne le bon produit', () async {
      final service = ProductApiService(
        client: MockHttpClient(body: mockProductsJson[0]),
      );
      final product = await service.fetchProductById(1);
      expect(product.id, 1);
      expect(product.title, 'Chaise ergonomique');
    });

    test('getMockProducts retourne une liste non vide', () {
      final service = ProductApiService();
      expect(service.getMockProducts(), isNotEmpty);
    });
  });
}
