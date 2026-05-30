import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_travel_planner/models/travel_route_model.dart';
import 'package:ai_travel_planner/providers/settings_provider.dart';
import 'package:ai_travel_planner/views/result_screen.dart';

Widget _wrap(Widget child) {
  return ChangeNotifierProvider(
    create: (_) => SettingsProvider(),
    child: MaterialApp(home: child),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const testRoute = TravelRoute(
    destination: 'İstanbul',
    days: 3,
    budget: 'Orta',
    itinerary:
        '## Gün 1: Tarihi Yarımada\n**Sabah:** Ayasofya\n🌅 Güzel sabah\n\n## Gün 2: Boğaz\nBoğaz turu',
  );

  testWidgets('hedef şehir AppBar başlığında görünür', (tester) async {
    await tester.pumpWidget(_wrap(const ResultScreen(travelRoute: testRoute)));
    await tester.pump();
    expect(find.text('İstanbul'), findsOneWidget);
  });

  testWidgets('gün sayısı ve bütçe info bar\'da gösterilir', (tester) async {
    await tester.pumpWidget(_wrap(const ResultScreen(travelRoute: testRoute)));
    await tester.pump();
    expect(find.text('3 Gün'), findsOneWidget);
    expect(find.text('Orta'), findsOneWidget);
  });

  testWidgets('yeni plan oluştur butonu görünür', (tester) async {
    await tester.pumpWidget(_wrap(const ResultScreen(travelRoute: testRoute)));
    await tester.pump();
    expect(find.text('Yeni Plan Oluştur'), findsOneWidget);
  });

  testWidgets('yeni plan butonu önceki ekrana döner', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SettingsProvider(),
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ResultScreen(travelRoute: testRoute),
                ),
              ),
              child: const Text('Devam'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Devam'));
    await tester.pumpAndSettle();

    expect(find.text('Yeni Plan Oluştur'), findsOneWidget);

    await tester.tap(find.text('Yeni Plan Oluştur'));
    await tester.pumpAndSettle();

    expect(find.text('Yeni Plan Oluştur'), findsNothing);
    expect(find.text('Devam'), findsOneWidget);
  });

  testWidgets('itinerary bir ListView içinde render edilir', (tester) async {
    await tester.pumpWidget(_wrap(const ResultScreen(travelRoute: testRoute)));
    await tester.pump();
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('boş itinerary ile çökmez', (tester) async {
    const emptyRoute = TravelRoute(
      destination: 'Test',
      days: 1,
      budget: 'Ekonomik',
      itinerary: '',
    );
    await tester.pumpWidget(_wrap(const ResultScreen(travelRoute: emptyRoute)));
    await tester.pump();
    expect(find.text('Test'), findsOneWidget);
  });

  testWidgets('çok günlü itinerary ile çökmez', (tester) async {
    final longItinerary =
        List.generate(14, (i) => '## Gün ${i + 1}: Gün\nAktivite').join('\n');
    final longRoute = TravelRoute(
      destination: 'Tokyo',
      days: 14,
      budget: 'Lüks',
      itinerary: longItinerary,
    );
    await tester.pumpWidget(_wrap(ResultScreen(travelRoute: longRoute)));
    await tester.pump();
    expect(find.text('Tokyo'), findsOneWidget);
    expect(find.text('14 Gün'), findsOneWidget);
  });
}
