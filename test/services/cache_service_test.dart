import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_travel_planner/services/cache_service.dart';
import 'package:ai_travel_planner/models/travel_route_model.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const paris3Orta = TravelRoute(
    destination: 'Paris',
    days: 3,
    budget: 'Orta',
    itinerary: 'Test içeriği',
  );

  group('CacheService save / get', () {
    test('kaydedilen rota geri okunur', () async {
      final cache = CacheService();
      await cache.save(paris3Orta);
      final result = await cache.get('Paris', 3, 'Orta');

      expect(result, isNotNull);
      expect(result!.destination, 'Paris');
      expect(result.days, 3);
      expect(result.budget, 'Orta');
      expect(result.itinerary, 'Test içeriği');
    });

    test('kayıtsız sorgu null döner', () async {
      final result = await CacheService().get('Tokyo', 5, 'Lüks');
      expect(result, isNull);
    });

    test('farklı gün sayısı farklı cache girişi kullanır', () async {
      final cache = CacheService();
      const paris5 = TravelRoute(destination: 'Paris', days: 5, budget: 'Orta', itinerary: '5 günlük');
      await cache.save(paris3Orta);
      await cache.save(paris5);

      expect((await cache.get('Paris', 3, 'Orta'))!.itinerary, 'Test içeriği');
      expect((await cache.get('Paris', 5, 'Orta'))!.itinerary, '5 günlük');
    });

    test('farklı bütçe farklı cache girişi kullanır', () async {
      final cache = CacheService();
      const parisLuks = TravelRoute(destination: 'Paris', days: 3, budget: 'Lüks', itinerary: 'Lüks plan');
      await cache.save(paris3Orta);
      await cache.save(parisLuks);

      expect((await cache.get('Paris', 3, 'Orta'))!.budget, 'Orta');
      expect((await cache.get('Paris', 3, 'Lüks'))!.budget, 'Lüks');
    });

    test('aynı parametrelerle tekrar kayıt günceller', () async {
      final cache = CacheService();
      await cache.save(paris3Orta);
      const updated = TravelRoute(destination: 'Paris', days: 3, budget: 'Orta', itinerary: 'Güncel içerik');
      await cache.save(updated);

      final result = await cache.get('Paris', 3, 'Orta');
      expect(result!.itinerary, 'Güncel içerik');
    });

    test('destination büyük harf aynı key üretir (toLowerCase)', () async {
      final cache = CacheService();
      await cache.save(paris3Orta);
      final result = await cache.get('PARIS', 3, 'Orta');
      expect(result, isNotNull);
    });
  });

  group('CacheService TTL', () {
    test('23 saatlik kayıt hâlâ döner', () async {
      final prefs = await SharedPreferences.getInstance();
      final freshData = {
        ...paris3Orta.toJson(),
        'cachedAt': DateTime.now()
            .subtract(const Duration(hours: 23))
            .millisecondsSinceEpoch,
      };
      await prefs.setString('route_paris_3_orta', jsonEncode(freshData));

      final result = await CacheService().get('Paris', 3, 'Orta');
      expect(result, isNotNull);
    });

    test('25 saatlik eski kayıt null döner ve silinir', () async {
      final prefs = await SharedPreferences.getInstance();
      final expiredData = {
        ...paris3Orta.toJson(),
        'cachedAt': DateTime.now()
            .subtract(const Duration(hours: 25))
            .millisecondsSinceEpoch,
      };
      await prefs.setString('route_paris_3_orta', jsonEncode(expiredData));

      final result = await CacheService().get('Paris', 3, 'Orta');
      expect(result, isNull);
      expect(prefs.getString('route_paris_3_orta'), isNull);
    });
  });
}
