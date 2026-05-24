import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/providers/cart_provider.dart';
import 'package:marketplace_app/services/cart_database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../helpers/test_data.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  TestWidgetsFlutterBinding.ensureInitialized();

  group('CartProvider (avec injection CartDatabaseService in-memory)', () {
    CartProvider freshProvider() => CartProvider(
          dbService: CartDatabaseService(databasePath: inMemoryDatabasePath),
        );

    test('panier vide au démarrage', () async {
      final provider = freshProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(provider.items, isEmpty);
    });

    test('ajouterAuPanier ajoute un produit', () async {
      final provider = freshProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      await provider.ajouterAuPanier(testProduct1);
      expect(provider.items.length, 1);
      expect(provider.estDansLePanier(testProduct1.id), isTrue);
    });

    test('ajouterAuPanier incrémente la quantité si déjà présent', () async {
      final provider = freshProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      await provider.ajouterAuPanier(testProduct1);
      await provider.ajouterAuPanier(testProduct1);
      expect(provider.items.length, 1);
      expect(provider.getItem(testProduct1.id)!.quantity, 2);
    });

    test('retirerDuPanier supprime le produit', () async {
      final provider = freshProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      await provider.ajouterAuPanier(testProduct1);
      await provider.retirerDuPanier(testProduct1.id);
      expect(provider.items, isEmpty);
    });

    test('decrementerQuantite retire le produit si quantité = 1', () async {
      final provider = freshProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      await provider.ajouterAuPanier(testProduct1);
      await provider.decrementerQuantite(testProduct1.id);
      expect(provider.items, isEmpty);
    });

    test('total est correct', () async {
      final provider = freshProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      await provider.ajouterAuPanier(testProduct1); // 149.99
      await provider.ajouterAuPanier(testProduct2); // 89.95
      expect(provider.total, closeTo(239.94, 0.01));
    });

    test('itemCount compte les quantités totales', () async {
      final provider = freshProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      await provider.ajouterAuPanier(testProduct1);
      await provider.ajouterAuPanier(testProduct1);
      await provider.ajouterAuPanier(testProduct2);
      expect(provider.itemCount, 3);
    });

    test('validerPanier vide le panier', () async {
      final provider = freshProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      await provider.ajouterAuPanier(testProduct1);
      await provider.validerPanier();
      expect(provider.items, isEmpty);
    });

    test('notifie les listeners après ajout', () async {
      final provider = freshProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      var notified = false;
      provider.addListener(() => notified = true);
      await provider.ajouterAuPanier(testProduct1);
      expect(notified, isTrue);
    });
  });
}
