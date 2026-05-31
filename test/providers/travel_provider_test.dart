import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_travel_planner/providers/travel_provider.dart';
import 'package:ai_travel_planner/services/travel_service.dart';
import 'package:ai_travel_planner/services/cache_service.dart';
import 'package:ai_travel_planner/models/travel_route_model.dart';

class _FakeService implements ITravelService {
  final bool shouldThrow;
  final String errorMessage;
  int callCount = 0;

  _FakeService({this.shouldThrow = false, this.errorMessage = 'Servis hatası'});

  @override
  Future<TravelRoute> generateItinerary({
    required String destination,
    required int days,
    required String budget,
    String language = 'tr',
  }) async {
    callCount++;
    if (shouldThrow) throw Exception(errorMessage);
    return TravelRoute(destination: destination, days: days, budget: budget, itinerary: 'Test planı');
  }
}

TravelProvider _provider({
  ITravelService? service,
  CacheService? cache,
  bool isOnline = true,
}) =>
    TravelProvider(
      service: service ?? _FakeService(),
      cache: cache ?? CacheService(),
      checkOnline: () async => isOnline,
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('TravelProvider başlangıç durumu', () {
    test('idle state ile başlar', () => expect(_provider().state, TravelState.idle));
    test('route başlangıçta null', () => expect(_provider().route, isNull));
    test('errorMessage başlangıçta null', () => expect(_provider().errorMessage, isNull));
    test('isLoading başlangıçta false', () => expect(_provider().isLoading, isFalse));
    test('fromCache başlangıçta false', () => expect(_provider().fromCache, isFalse));
  });

  group('TravelProvider başarılı generate', () {
    test('state success olur', () async {
      final p = _provider();
      await p.generate(destination: 'Paris', days: 3, budget: 'Orta');
      expect(p.state, TravelState.success);
    });

    test('route doğru alanlarla dolar', () async {
      final p = _provider();
      await p.generate(destination: 'Paris', days: 3, budget: 'Orta');
      expect(p.route!.destination, 'Paris');
      expect(p.route!.days, 3);
      expect(p.route!.budget, 'Orta');
    });

    test('fromCache false olur (taze veri)', () async {
      final p = _provider();
      await p.generate(destination: 'Paris', days: 3, budget: 'Orta');
      expect(p.fromCache, isFalse);
    });

    test('errorMessage null kalır', () async {
      final p = _provider();
      await p.generate(destination: 'Paris', days: 3, budget: 'Orta');
      expect(p.errorMessage, isNull);
    });
  });

  group('TravelProvider hata durumu', () {
    test('state error olur', () async {
      final p = _provider(service: _FakeService(shouldThrow: true));
      await p.generate(destination: 'Paris', days: 3, budget: 'Orta');
      expect(p.state, TravelState.error);
    });

    test('errorMessage dolu olur', () async {
      final p = _provider(service: _FakeService(shouldThrow: true, errorMessage: 'Bağlantı yok'));
      await p.generate(destination: 'Paris', days: 3, budget: 'Orta');
      expect(p.errorMessage, contains('Bağlantı yok'));
    });

    test('route null kalır', () async {
      final p = _provider(service: _FakeService(shouldThrow: true));
      await p.generate(destination: 'Paris', days: 3, budget: 'Orta');
      expect(p.route, isNull);
    });
  });

  group('TravelProvider cache-first davranışı', () {
    test('cache hit ise servis çağrılmaz', () async {
      final cache = CacheService();
      await cache.save(const TravelRoute(destination: 'Paris', days: 3, budget: 'Orta', itinerary: 'Önbellekten'));

      final service = _FakeService();
      final p = _provider(service: service, cache: cache);
      await p.generate(destination: 'Paris', days: 3, budget: 'Orta');

      expect(service.callCount, 0);
      expect(p.route!.itinerary, 'Önbellekten');
      expect(p.fromCache, isTrue);
    });

    test('cache miss ise servis çağrılır', () async {
      final service = _FakeService();
      final p = _provider(service: service);
      await p.generate(destination: 'Paris', days: 3, budget: 'Orta');
      expect(service.callCount, 1);
    });

    test('başarılı generate cache\'e kaydeder', () async {
      final cache = CacheService();
      final p = _provider(cache: cache);
      await p.generate(destination: 'Tokyo', days: 5, budget: 'Lüks');

      final cached = await cache.get('Tokyo', 5, 'Lüks');
      expect(cached, isNotNull);
    });
  });

  group('TravelProvider offline davranışı', () {
    test('offline + cache var → success ve fromCache true', () async {
      final cache = CacheService();
      await cache.save(const TravelRoute(destination: 'Paris', days: 3, budget: 'Orta', itinerary: 'Offline cache'));

      final p = _provider(cache: cache, isOnline: false);
      await p.generate(destination: 'Paris', days: 3, budget: 'Orta');

      expect(p.state, TravelState.success);
      expect(p.fromCache, isTrue);
      expect(p.route!.itinerary, 'Offline cache');
    });

    test('offline + cache yok → error', () async {
      final p = _provider(isOnline: false);
      await p.generate(destination: 'Paris', days: 3, budget: 'Orta');
      expect(p.state, TravelState.error);
    });

    test('offline TR hata mesajı internet içerir', () async {
      final p = _provider(isOnline: false);
      await p.generate(destination: 'Paris', days: 3, budget: 'Orta', language: 'tr');
      expect(p.errorMessage, contains('İnternet bağlantısı'));
    });

    test('offline EN hata mesajı No internet içerir', () async {
      final p = _provider(isOnline: false);
      await p.generate(destination: 'Paris', days: 3, budget: 'Orta', language: 'en');
      expect(p.errorMessage, contains('No internet'));
    });
  });

  group('TravelProvider.reset', () {
    test('state idle\'a döner', () async {
      final p = _provider();
      await p.generate(destination: 'Paris', days: 3, budget: 'Orta');
      p.reset();
      expect(p.state, TravelState.idle);
    });

    test('route null olur', () async {
      final p = _provider();
      await p.generate(destination: 'Paris', days: 3, budget: 'Orta');
      p.reset();
      expect(p.route, isNull);
    });

    test('errorMessage null olur', () async {
      final p = _provider(service: _FakeService(shouldThrow: true));
      await p.generate(destination: 'Paris', days: 3, budget: 'Orta');
      p.reset();
      expect(p.errorMessage, isNull);
    });

    test('fromCache false olur', () async {
      final cache = CacheService();
      await cache.save(const TravelRoute(destination: 'Paris', days: 3, budget: 'Orta', itinerary: 'Test'));
      final p = _provider(cache: cache);
      await p.generate(destination: 'Paris', days: 3, budget: 'Orta');
      p.reset();
      expect(p.fromCache, isFalse);
    });
  });

  group('TravelProvider notifyListeners', () {
    test('başarılı generate: loading → success sırası', () async {
      final p = _provider();
      final states = <TravelState>[];
      p.addListener(() => states.add(p.state));

      await p.generate(destination: 'Paris', days: 3, budget: 'Orta');

      expect(states, containsAllInOrder([TravelState.loading, TravelState.success]));
    });

    test('hatalı generate: loading → error sırası', () async {
      final p = _provider(service: _FakeService(shouldThrow: true));
      final states = <TravelState>[];
      p.addListener(() => states.add(p.state));

      await p.generate(destination: 'Paris', days: 3, budget: 'Orta');

      expect(states, containsAllInOrder([TravelState.loading, TravelState.error]));
    });
  });
}
