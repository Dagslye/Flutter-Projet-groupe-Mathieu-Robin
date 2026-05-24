import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_data.dart';
import '../../mocks/mock_preferences_service.dart';

void main() {
  group('PreferencesService (via MockPreferencesService)', () {
    test('getFavoris retourne une liste vide initialement', () async {
      final service = MockPreferencesService();
      final favoris = await service.getFavoris();
      expect(favoris, isEmpty);
    });

    test('saveFavoris puis getFavoris retourne les produits sauvegardés', () async {
      final service = MockPreferencesService();
      await service.saveFavoris([testProduct1, testProduct2]);
      final favoris = await service.getFavoris();
      expect(favoris.length, 2);
      expect(favoris[0].title, 'Chaise ergonomique');
    });

    test('saveFavoris remplace les données précédentes', () async {
      final service = MockPreferencesService();
      await service.saveFavoris([testProduct1, testProduct2]);
      await service.saveFavoris([testProduct1]);
      final favoris = await service.getFavoris();
      expect(favoris.length, 1);
    });

    test('saveToken puis getToken retourne le token', () async {
      final service = MockPreferencesService();
      await service.saveToken('mon-token-test');
      final token = await service.getToken();
      expect(token, 'mon-token-test');
    });

    test('clearAuth supprime le token', () async {
      final service = MockPreferencesService();
      await service.saveToken('mon-token-test');
      await service.clearAuth();
      final token = await service.getToken();
      expect(token, isNull);
    });
  });
}
