import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/providers/product_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProductProvider', () {
    test('état initial : liste vide, pas de chargement', () {
      final provider = ProductProvider();
      expect(provider.products, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('notifie les listeners quand fetchProducts est appelé', () async {
      final provider = ProductProvider();
      var notified = false;
      provider.addListener(() => notified = true);
      await provider.fetchProducts();
      expect(notified, isTrue);
    });

    test('searchQuery est vide initialement', () {
      final provider = ProductProvider();
      expect(provider.searchQuery, isEmpty);
    });

    test('selectedCategoryId est null initialement', () {
      final provider = ProductProvider();
      expect(provider.selectedCategoryId, isNull);
    });
  });
}
