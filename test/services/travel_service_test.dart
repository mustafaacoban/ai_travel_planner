import 'package:flutter_test/flutter_test.dart';
import 'package:ai_travel_planner/services/travel_service.dart';

void main() {
  group('TravelService API key kontrolü', () {
    test('API key yapılandırılmamışsa exception fırlatır', () async {
      final svc = TravelService();
      expect(
        () async => svc.generateItinerary(destination: 'Paris', days: 3, budget: 'Orta'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('API anahtarı'),
        )),
      );
    });
  });
}
