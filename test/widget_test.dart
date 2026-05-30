import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_travel_planner/main.dart';
import 'package:ai_travel_planner/models/travel_route_model.dart';
import 'package:ai_travel_planner/providers/travel_provider.dart';
import 'package:ai_travel_planner/services/travel_service.dart';

class FakeTravelService implements ITravelService {
  @override
  Future<TravelRoute> generateItinerary({
    required String destination,
    required int days,
    required String budget,
    String language = 'tr',
  }) async {
    return TravelRoute(
      destination: destination,
      days: days,
      budget: budget,
      itinerary: '## Gün 1: Test Günü\nTest içeriği',
    );
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('uygulama başlar ve form ekranı yüklenir', (tester) async {
    await tester.pumpWidget(
      MyApp(
        travelProvider: TravelProvider(
          service: FakeTravelService(),
          checkOnline: () async => true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('AI Rota Planlayıcı'), findsOneWidget);
  });
}
