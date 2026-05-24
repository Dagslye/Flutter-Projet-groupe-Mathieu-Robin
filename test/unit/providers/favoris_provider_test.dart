import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/providers/favoris_provider.dart';
import '../../helpers/test_data.dart';
import '../../mocks/mock_preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FavorisProvider (avec injection MockPreferencesService)', () {
    test('liste de favoris vide au démarrage', () async {
      final provider = FavorisProvider(prefsService: MockPreferencesService());
      await Future.delayed(const Duration(milliseconds: 50));
      expect(provider.favoris, isEmpty);
    });

    test('toggleFavori ajoute un produit aux favoris', () async {
      final provider = FavorisProvider(prefsService: MockPreferencesService());
      await Future.delayed(const Duration(milliseconds: 50));

      await provider.toggleFavori(testProduct1);
      expect(provider.favoris.length, 1);
      expect(provider.estFavori(testProduct1.id), isTrue);
    });

    test('toggleFavori retire un produit déjà en favori', () async {
      final provider = FavorisProvider(prefsService: MockPreferencesService());
      await Future.delayed(const Duration(milliseconds: 50));

      await provider.toggleFavori(testProduct1);
      await provider.toggleFavori(testProduct1);
      expect(provider.favoris, isEmpty);
      expect(provider.estFavori(testProduct1.id), isFalse);
    });

    test('estFavori retourne false pour un produit non ajouté', () async {
      final provider = FavorisProvider(prefsService: MockPreferencesService());
      await Future.delayed(const Duration(milliseconds: 50));
      expect(provider.estFavori(999), isFalse);
    });

    test('notifie les listeners après toggle', () async {
      final provider = FavorisProvider(prefsService: MockPreferencesService());
      await Future.delayed(const Duration(milliseconds: 50));

      var notified = false;
      provider.addListener(() => notified = true);
      await provider.toggleFavori(testProduct1);
      expect(notified, isTrue);
    });

    test('persistance : provider2 lit ce qu\'a sauvegardé provider1', () async {
      final sharedService = MockPreferencesService();
      final provider1 = FavorisProvider(prefsService: sharedService);
      await Future.delayed(const Duration(milliseconds: 50));
      await provider1.toggleFavori(testProduct1);

      final provider2 = FavorisProvider(prefsService: sharedService);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(provider2.estFavori(testProduct1.id), isTrue);
    });
  });
}
