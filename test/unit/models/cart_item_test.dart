import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/models/cart_item.dart';
import '../../helpers/test_data.dart';

void main() {
  group('CartItem', () {
    test('quantité par défaut est 1', () {
      final item = CartItem(product: testProduct1);
      expect(item.quantity, 1);
    });

    test('totalPrice = price × quantity', () {
      final item = CartItem(product: testProduct1, quantity: 3);
      expect(item.totalPrice, closeTo(testProduct1.price * 3, 0.001));
    });

    test('toJson / fromJson sont symétriques', () {
      final original = CartItem(product: testProduct1, quantity: 2);
      final reconstructed = CartItem.fromJson(original.toJson());
      expect(reconstructed.product.id, original.product.id);
      expect(reconstructed.quantity, 2);
    });

    test('totalPrice avec quantité 1', () {
      final item = CartItem(product: testProduct2);
      expect(item.totalPrice, testProduct2.price);
    });
  });
}
