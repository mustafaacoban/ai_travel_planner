# AI Travel Planner

Yapay zeka destekli seyahat rota planlayıcısı. Gideceğin şehri, gün sayısını ve bütçeni gir — Google Gemini AI senin için kişiselleştirilmiş bir gezi planı oluştursun.

## Özellikler

- Şehir, gün sayısı (1-14) ve bütçe (Ekonomik / Orta / Lüks) seçimi
- Google Gemini 1.5 Flash ile AI destekli itinerary üretimi
- Sabah / öğle / akşam aktiviteleri ve günlük ipuçları
- Genel seyahat tavsiyeleri (ulaşım, para birimi, en iyi zaman)
- Türkçe çıktı, sade ve modern arayüz

## Ekran Görüntüleri

| Form Ekranı | Sonuç Ekranı |
|---|---|
| Destinasyon, gün sayısı ve bütçe seçimi | AI tarafından oluşturulan günlük plan |

## Kurulum

### Gereksinimler

- Flutter SDK >= 3.12.0
- Dart SDK
- Google Gemini API anahtarı

### Adımlar

```bash
# Repoyu klonla
git clone https://github.com/Mustafaacoban/ai_travel_planner.git
cd ai_travel_planner

# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır (API anahtarını ekleyerek)
flutter run --dart-define=GEMINI_API_KEY=senin_api_anahtarin
```

### API Anahtarı

[Google AI Studio](https://aistudio.google.com/app/apikey) üzerinden ücretsiz Gemini API anahtarı alabilirsin.

## Proje Yapısı

```
lib/
├── main.dart                      # Uygulama giriş noktası
├── config/
│   └── app_config.dart           # API yapılandırması
├── models/
│   └── travel_route_model.dart   # Seyahat rotası modeli
├── services/
│   └── travel_service.dart       # Gemini API servisi
└── views/
    ├── form_screen.dart          # Ana form ekranı
    └── result_screen.dart        # Plan sonuç ekranı

test/
├── widget_test.dart
├── models/
│   └── travel_route_model_test.dart
└── views/
    ├── form_screen_test.dart
    └── result_screen_test.dart
```

## Testler

```bash
flutter test
```

21 test — model, form ekranı ve sonuç ekranı widget testleri dahil. Testler `FakeTravelService` ile API'ye gerçek istek atmadan çalışır.

## Kullanılan Teknolojiler

- [Flutter](https://flutter.dev/) — cross-platform UI
- [Dio](https://pub.dev/packages/dio) — HTTP istemcisi
- [Google Fonts](https://pub.dev/packages/google_fonts) — Poppins yazı tipi
- [Google Gemini 1.5 Flash](https://deepmind.google/technologies/gemini/) — AI içerik üretimi
