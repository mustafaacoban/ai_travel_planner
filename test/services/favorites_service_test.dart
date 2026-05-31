import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_travel_planner/services/favorites_service.dart';
import 'package:ai_travel_planner/models/travel_route_model.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const paris = TravelRoute(destination: 'Paris', days: 3, budget: 'Orta', itinerary: 'Paris planı');
  const tokyo = TravelRoute(destination: 'Tokyo', days: 5, budget: 'Lüks', itinerary: 'Tokyo planı');

  group('FavoritesService.getAll', () {
    test('başlangıçta boş liste döner', () async {
      final list = await FavoritesService().getAll();
      expect(list, isEmpty);
    });

    test('eklenen rotaları sırayla listeler', () async {
      final svc = FavoritesService();
      await svc.add(paris);
      await svc.add(tokyo);

      final list = await svc.getAll();
      expect(list.length, 2);
      expect(list[0].destination, 'Paris');
      expect(list[1].destination, 'Tokyo');
    });
  });

  group('FavoritesService.add', () {
    test('aynı rota iki kez eklenemez', () async {
      final svc = FavoritesService();
      await svc.add(paris);
      await svc.add(paris);

      expect((await svc.getAll()).length, 1);
    });

    test('farklı rotalar ayrı eklenir', () async {
      final svc = FavoritesService();
      await svc.add(paris);
      await svc.add(tokyo);

      expect((await svc.getAll()).length, 2);
    });

    test('eklenen rotanın tüm alanları korunur', () async {
      final svc = FavoritesService();
      await svc.add(paris);

      final list = await svc.getAll();
      expect(list.first.destination, 'Paris');
      expect(list.first.days, 3);
      expect(list.first.budget, 'Orta');
      expect(list.first.itinerary, 'Paris planı');
    });
  });

  group('FavoritesService.removeAt', () {
    test('belirtilen index silinir', () async {
      final svc = FavoritesService();
      await svc.add(paris);
      await svc.add(tokyo);
      await svc.removeAt(0);

      final list = await svc.getAll();
      expect(list.length, 1);
      expect(list[0].destination, 'Tokyo');
    });

    test('son elemanı silince liste boş olur', () async {
      final svc = FavoritesService();
      await svc.add(paris);
      await svc.removeAt(0);

      expect(await svc.getAll(), isEmpty);
    });

    test('geçersiz büyük index ile çağrı hata fırlatmaz', () async {
      final svc = FavoritesService();
      await svc.add(paris);

      expect(() async => svc.removeAt(99), returnsNormally);
    });

    test('negatif index ile çağrı hata fırlatmaz', () async {
      final svc = FavoritesService();
      await svc.add(paris);

      expect(() async => svc.removeAt(-1), returnsNormally);
    });
  });

  group('FavoritesService.isFavorite', () {
    test('eklenmemiş rota false döner', () async {
      expect(await FavoritesService().isFavorite(paris), isFalse);
    });

    test('eklenmiş rota true döner', () async {
      final svc = FavoritesService();
      await svc.add(paris);
      expect(await svc.isFavorite(paris), isTrue);
    });

    test('farklı destination false döner', () async {
      final svc = FavoritesService();
      await svc.add(paris);
      expect(await svc.isFavorite(tokyo), isFalse);
    });

    test('farklı gün sayısı false döner', () async {
      final svc = FavoritesService();
      await svc.add(paris);
      const paris5 = TravelRoute(destination: 'Paris', days: 5, budget: 'Orta', itinerary: '');
      expect(await svc.isFavorite(paris5), isFalse);
    });

    test('silinmiş rota false döner', () async {
      final svc = FavoritesService();
      await svc.add(paris);
      await svc.removeAt(0);
      expect(await svc.isFavorite(paris), isFalse);
    });
  });
}
