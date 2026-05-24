import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/models/product.dart';
import '../../helpers/test_data.dart';

void main() {
  group('Product', () {
    test('fromJson depuis format Platzi Fake Store API', () {
      final product = Product.fromJson(mockProductsJson[0]);
      expect(product.id, 1);
      expect(product.title, 'Chaise ergonomique');
      expect(product.price, 149.99);
      expect(product.category, 'Furniture');
      expect(product.imageUrl, isNotNull);
    });

    test('fromJson depuis format toJson() (format interne)', () {
      final json = testProduct1.toJson();
      final reconstructed = Product.fromJson(json);
      expect(reconstructed.id, testProduct1.id);
      expect(reconstructed.title, testProduct1.title);
      expect(reconstructed.category, testProduct1.category);
    });

    test('toJson / fromJson sont symétriques', () {
      final json = testProduct2.toJson();
      final reconstructed = Product.fromJson(json);
      expect(reconstructed.id, testProduct2.id);
      expect(reconstructed.price, testProduct2.price);
      expect(reconstructed.description, testProduct2.description);
    });

    test('égalité basée sur l\'id', () {
      const p1 = Product(id: 1, title: 'A', price: 10, description: '', category: 'X');
      const p2 = Product(id: 1, title: 'B', price: 99, description: '', category: 'Y');
      expect(p1, equals(p2));
    });

    test('hashCode identique pour même id', () {
      expect(testProduct1.hashCode, equals(testProduct1.hashCode));
    });

    test('category depuis objet Map est extraite correctement', () {
      final json = {
        'id': 5,
        'title': 'Test',
        'price': 10,
        'description': 'desc',
        'category': {'id': 3, 'name': 'Shoes'},
        'images': [],
      };
      final product = Product.fromJson(json);
      expect(product.category, 'Shoes');
    });
  });
}
