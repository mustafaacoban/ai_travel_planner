import 'package:flutter_test/flutter_test.dart';
import 'package:ai_travel_planner/models/budget_type.dart';

void main() {
  group('BudgetType.label', () {
    test('ekonomik TR etiketi', () => expect(BudgetType.ekonomik.label, 'Ekonomik'));
    test('orta TR etiketi', () => expect(BudgetType.orta.label, 'Orta'));
    test('luks TR etiketi', () => expect(BudgetType.luks.label, 'Lüks'));
  });

  group('BudgetType.labelEn', () {
    test('ekonomik EN etiketi', () => expect(BudgetType.ekonomik.labelEn, 'Budget'));
    test('orta EN etiketi', () => expect(BudgetType.orta.labelEn, 'Mid-range'));
    test('luks EN etiketi', () => expect(BudgetType.luks.labelEn, 'Luxury'));
  });

  group('BudgetType.labelFor', () {
    test('tr dili TR label döner', () => expect(BudgetType.orta.labelFor('tr'), 'Orta'));
    test('en dili EN label döner', () => expect(BudgetType.orta.labelFor('en'), 'Mid-range'));
  });

  group('BudgetType.apiDescription', () {
    test('ekonomik TR hostel içerir', () {
      expect(BudgetType.ekonomik.apiDescription('tr'), contains('hostel'));
    });
    test('orta TR 3-4 yıldız içerir', () {
      expect(BudgetType.orta.apiDescription('tr'), contains('3-4 yıldızlı'));
    });
    test('luks TR 5 yıldız içerir', () {
      expect(BudgetType.luks.apiDescription('tr'), contains('5 yıldızlı'));
    });
    test('ekonomik EN street food içerir', () {
      expect(BudgetType.ekonomik.apiDescription('en'), contains('street food'));
    });
    test('luks EN 5-star içerir', () {
      expect(BudgetType.luks.apiDescription('en'), contains('5-star'));
    });
  });

  group('BudgetType.fromLabel', () {
    test('Ekonomik → ekonomik', () => expect(BudgetType.fromLabel('Ekonomik'), BudgetType.ekonomik));
    test('Lüks → luks', () => expect(BudgetType.fromLabel('Lüks'), BudgetType.luks));
    test('Budget → ekonomik', () => expect(BudgetType.fromLabel('Budget'), BudgetType.ekonomik));
    test('Luxury → luks', () => expect(BudgetType.fromLabel('Luxury'), BudgetType.luks));
    test('Orta → orta', () => expect(BudgetType.fromLabel('Orta'), BudgetType.orta));
    test('bilinmeyen string varsayılan orta döner', () {
      expect(BudgetType.fromLabel('bilinmeyen'), BudgetType.orta);
    });
    test('boş string varsayılan orta döner', () {
      expect(BudgetType.fromLabel(''), BudgetType.orta);
    });
  });
}
