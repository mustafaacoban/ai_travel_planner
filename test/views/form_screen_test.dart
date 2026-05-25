import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_travel_planner/models/travel_route_model.dart';
import 'package:ai_travel_planner/services/travel_service.dart';
import 'package:ai_travel_planner/views/form_screen.dart';
import 'package:ai_travel_planner/views/result_screen.dart';

class FakeTravelService implements ITravelService {
  final bool shouldThrow;
  FakeTravelService({this.shouldThrow = false});

  @override
  Future<TravelRoute> generateItinerary({
    required String destination,
    required int days,
    required String budget,
  }) async {
    if (shouldThrow) throw Exception('Bağlantı hatası: sunucuya ulaşılamıyor');
    return TravelRoute(
      destination: destination,
      days: days,
      budget: budget,
      itinerary: '## Gün 1: Harika Bir Gün\n**Sabah:** Test aktivitesi',
    );
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildForm({ITravelService? service}) {
    return MaterialApp(
      home: FormScreen(travelService: service ?? FakeTravelService()),
    );
  }

  Future<void> tapSubmitButton(WidgetTester tester) async {
    final button = find.text('Rota Oluştur');
    await tester.ensureVisible(button);
    await tester.tap(button);
  }

  testWidgets('başlık ve temel elemanlar görünür', (tester) async {
    await tester.pumpWidget(buildForm());

    expect(find.text('AI Rota Planlayıcı'), findsOneWidget);
    expect(find.text('Nereye gitmek istersiniz?'), findsOneWidget);
    expect(find.text('Rota Oluştur'), findsOneWidget);
  });

  testWidgets('üç bütçe kartı görünür', (tester) async {
    await tester.pumpWidget(buildForm());

    expect(find.text('Ekonomik'), findsOneWidget);
    expect(find.text('Orta'), findsOneWidget);
    expect(find.text('Lüks'), findsOneWidget);
  });

  testWidgets('boş destinasyonla gönderimde doğrulama hatası gösterilir',
      (tester) async {
    await tester.pumpWidget(buildForm());

    await tapSubmitButton(tester);
    await tester.pump();

    expect(find.text('Lütfen bir varış noktası girin'), findsOneWidget);
  });

  testWidgets('bütçe kartına tıklamak seçimi değiştirir', (tester) async {
    await tester.pumpWidget(buildForm());

    await tester.tap(find.text('Ekonomik'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lüks'));
    await tester.pumpAndSettle();
  });

  testWidgets('başarılı gönderimde sonuç ekranına geçer', (tester) async {
    await tester.pumpWidget(buildForm());

    await tester.enterText(find.byType(TextFormField), 'Paris');

    await tapSubmitButton(tester);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(ResultScreen), findsOneWidget);
    expect(find.text('Paris'), findsOneWidget);
    expect(find.text('Yeni Plan Oluştur'), findsOneWidget);
  });

  testWidgets('API hatasında hata dialogu açılır', (tester) async {
    await tester.pumpWidget(
      buildForm(service: FakeTravelService(shouldThrow: true)),
    );

    await tester.enterText(find.byType(TextFormField), 'Paris');
    await tapSubmitButton(tester);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Hata'), findsOneWidget);
    expect(find.text('Tamam'), findsOneWidget);
  });

  testWidgets('hata dialogunda Tamam\'a basınca kapanır', (tester) async {
    await tester.pumpWidget(
      buildForm(service: FakeTravelService(shouldThrow: true)),
    );

    await tester.enterText(find.byType(TextFormField), 'Paris');
    await tapSubmitButton(tester);
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tamam'));
    await tester.pumpAndSettle();

    expect(find.text('Hata'), findsNothing);
  });
}
