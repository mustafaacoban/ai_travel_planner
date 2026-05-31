import 'package:flutter_test/flutter_test.dart';
import 'package:ai_travel_planner/models/travel_route_model.dart';

void main() {
  group('TravelRoute modeli', () {
    test('tüm özellikler doğru atanır', () {
      const route = TravelRoute(
        destination: 'Paris',
        days: 5,
        budget: 'Orta',
        itinerary: 'Günlük plan içeriği',
      );
      expect(route.destination, equals('Paris'));
      expect(route.days, equals(5));
      expect(route.budget, equals('Orta'));
      expect(route.itinerary, equals('Günlük plan içeriği'));
    });

    test('Ekonomik bütçe ile oluşturulur', () {
      const route = TravelRoute(destination: 'Antalya', days: 3, budget: 'Ekonomik', itinerary: '');
      expect(route.budget, equals('Ekonomik'));
      expect(route.days, equals(3));
    });

    test('Lüks bütçe ile oluşturulur', () {
      const route = TravelRoute(destination: 'Dubai', days: 7, budget: 'Lüks', itinerary: 'Lüks plan');
      expect(route.budget, equals('Lüks'));
      expect(route.days, equals(7));
    });

    test('maksimum gün sayısıyla oluşturulur', () {
      final itinerary = List.generate(14, (i) => '## Gün ${i + 1}: Harika Gün').join('\n');
      final route = TravelRoute(destination: 'Japonya', days: 14, budget: 'Orta', itinerary: itinerary);
      expect(route.days, equals(14));
      expect(route.itinerary, contains('## Gün 14'));
    });

    test('boş itinerary kabul edilir', () {
      const route = TravelRoute(destination: 'Test', days: 1, budget: 'Orta', itinerary: '');
      expect(route.itinerary, isEmpty);
    });

    test('minimum gün sayısıyla (1 gün) oluşturulur', () {
      const route = TravelRoute(
        destination: 'İstanbul',
        days: 1,
        budget: 'Ekonomik',
        itinerary: '## Gün 1: Tek Gün\nHızlı tur',
      );
      expect(route.days, equals(1));
    });
  });

  group('TravelRoute toJson / fromJson', () {
    const route = TravelRoute(
      destination: 'Paris',
      days: 3,
      budget: 'Orta',
      itinerary: 'Test planı',
    );

    test('toJson tüm alanları içerir', () {
      final json = route.toJson();
      expect(json['destination'], 'Paris');
      expect(json['days'], 3);
      expect(json['budget'], 'Orta');
      expect(json['itinerary'], 'Test planı');
    });

    test('fromJson tüm alanları doğru okur', () {
      final json = {'destination': 'Tokyo', 'days': 5, 'budget': 'Lüks', 'itinerary': 'Tokyo planı'};
      final r = TravelRoute.fromJson(json);
      expect(r.destination, 'Tokyo');
      expect(r.days, 5);
      expect(r.budget, 'Lüks');
      expect(r.itinerary, 'Tokyo planı');
    });

    test('round-trip: toJson → fromJson orijinalle eşleşir', () {
      final roundTripped = TravelRoute.fromJson(route.toJson());
      expect(roundTripped.destination, route.destination);
      expect(roundTripped.days, route.days);
      expect(roundTripped.budget, route.budget);
      expect(roundTripped.itinerary, route.itinerary);
    });

    test('boş itinerary round-trip korunur', () {
      const empty = TravelRoute(destination: 'X', days: 1, budget: 'Orta', itinerary: '');
      final result = TravelRoute.fromJson(empty.toJson());
      expect(result.itinerary, isEmpty);
    });
  });
}
