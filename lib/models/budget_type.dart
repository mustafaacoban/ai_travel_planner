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

  String get labelEn => switch (this) {
        BudgetType.ekonomik => 'Budget',
        BudgetType.orta => 'Mid-range',
        BudgetType.luks => 'Luxury',
      };

  String labelFor(String language) => language == 'tr' ? label : labelEn;

  String apiDescription(String language) {
    if (language == 'tr') {
      return switch (this) {
        BudgetType.ekonomik =>
          'düşük bütçeli (hostel veya uygun oteller, sokak yemeği, toplu taşıma)',
        BudgetType.orta => 'orta bütçeli (3-4 yıldızlı oteller, restoranlar, taksi)',
        BudgetType.luks =>
          'yüksek bütçeli (5 yıldızlı oteller, fine dining, özel transfer)',
      };
    } else {
      return switch (this) {
        BudgetType.ekonomik =>
          'budget (hostels or affordable hotels, street food, public transport)',
        BudgetType.orta => 'mid-range (3-4 star hotels, restaurants, taxi)',
        BudgetType.luks =>
          'luxury (5-star hotels, fine dining, private transfers)',
      };
    }
  }

  String cardDescription(String language) => language == 'tr'
      ? switch (this) {
          BudgetType.ekonomik => 'Hostel, sokak yemeği, toplu taşıma',
          BudgetType.orta => '3-4 yıldız otel, restoran, taksi',
          BudgetType.luks => '5 yıldız, fine dining, özel transfer',
        }
      : switch (this) {
          BudgetType.ekonomik => 'Hostel, street food, public transport',
          BudgetType.orta => '3-4 star hotel, restaurant, taxi',
          BudgetType.luks => '5-star, fine dining, private transfer',
        };

  IconData get icon => switch (this) {
        BudgetType.ekonomik => Icons.savings,
        BudgetType.orta => Icons.account_balance_wallet,
        BudgetType.luks => Icons.diamond,
      };

  static BudgetType fromLabel(String label) => switch (label) {
        'Ekonomik' || 'Budget' => BudgetType.ekonomik,
        'Lüks' || 'Luxury' => BudgetType.luks,
        _ => BudgetType.orta,
      };
}
