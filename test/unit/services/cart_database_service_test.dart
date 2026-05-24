import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/models/cart_item.dart';
import 'package:marketplace_app/services/cart_database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../helpers/test_data.dart';

void main() {
  // Initialisation SQLite FFI pour les tests desktop — copie exacte TD6
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('CartDatabaseService', () {
    late CartDatabaseService service;

    setUp(() async {
      // inMemoryDatabasePath : base en RAM, isolée entre chaque test
      service = CartDatabaseService(databasePath: inMemoryDatabasePath);
    });

    tearDown(() async => service.close());

    test('getCart retourne une liste vide au départ', () async {
      final items = await service.getCart();
      expect(items, isEmpty);
    });

    test('saveCart puis getCart retourne les items', () async {
      final items = [
        CartItem(product: testProduct1, quantity: 2),
        CartItem(product: testProduct2),
      ];
      await service.saveCart(items);
      final loaded = await service.getCart();
      expect(loaded.length, 2);
      expect(loaded[0].product.title, 'Chaise ergonomique');
      expect(loaded[0].quantity, 2);
      expect(loaded[1].product.title, 'Clavier mécanique');
    });

    test('saveCart remplace les données existantes', () async {
      await service.saveCart([CartItem(product: testProduct1)]);
      await service.saveCart([CartItem(product: testProduct2)]);
      final loaded = await service.getCart();
      expect(loaded.length, 1);
      expect(loaded[0].product.title, 'Clavier mécanique');
    });

    test('clearCart vide la base', () async {
      await service.saveCart([CartItem(product: testProduct1)]);
      await service.clearCart();
      final loaded = await service.getCart();
      expect(loaded, isEmpty);
    });
  });
}
