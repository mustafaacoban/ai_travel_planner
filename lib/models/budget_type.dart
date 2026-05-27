import 'package:flutter/material.dart';

enum BudgetType {
  ekonomik,
  orta,
  luks;

  String get label => switch (this) {
        BudgetType.ekonomik => 'Ekonomik',
        BudgetType.orta => 'Orta',
        BudgetType.luks => 'Lüks',
      };

  String get apiDescription => switch (this) {
        BudgetType.ekonomik =>
          'düşük bütçeli (hostel veya uygun oteller, sokak yemeği, toplu taşıma)',
        BudgetType.orta => 'orta bütçeli (3-4 yıldızlı oteller, restoranlar, taksi)',
        BudgetType.luks =>
          'yüksek bütçeli (5 yıldızlı oteller, fine dining, özel transfer)',
      };

  String get cardDescription => switch (this) {
        BudgetType.ekonomik => 'Hostel, sokak yemeği, toplu taşıma',
        BudgetType.orta => '3-4 yıldız otel, restoran, taksi',
        BudgetType.luks => '5 yıldız, fine dining, özel transfer',
      };

  IconData get icon => switch (this) {
        BudgetType.ekonomik => Icons.savings,
        BudgetType.orta => Icons.account_balance_wallet,
        BudgetType.luks => Icons.diamond,
      };

  static BudgetType fromLabel(String label) => switch (label) {
        'Ekonomik' => BudgetType.ekonomik,
        'Lüks' => BudgetType.luks,
        _ => BudgetType.orta,
      };
}
