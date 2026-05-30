# AI Travel Planner — AI Rota Planlayıcı

Yapay zeka destekli seyahat rota planlayıcısı. Gideceğin şehri, gün sayısını ve bütçeni gir — Google Gemini AI senin için kişiselleştirilmiş bir gezi planı oluştursun.

## Özellikler

| Özellik | Açıklama |
|---|---|
| AI Plan Üretimi | Google Gemini 1.5 Flash ile sabah/öğle/akşam aktiviteleri ve günlük ipuçları |
| Bütçe Seçimi | Ekonomik / Orta / Lüks — her biri farklı konaklama ve yemek önerileriyle |
| Gün Seçimi | 1 ile 14 gün arası slider ile ayarlanabilir |
| Favori Planlar | Beğenilen planları kaydet, listele ve sil |
| Paylaşım | Planı metin olarak arkadaşlarınla paylaş |
| PDF Export | Planı A4 formatında PDF olarak dışa aktar |
| TR / EN Dil Desteği | AppBar'daki toggle ile Türkçe veya İngilizce plan üretimi |
| Dark Mode | Kalıcı koyu / açık tema desteği |
| Offline Önbellek | Üretilen planlar 24 saat önbellekte saklanır; internetsiz erişilebilir |

## Kurulum

### Gereksinimler

- Flutter SDK >= 3.12.0
- Dart SDK
- Google Gemini API anahtarı ([Google AI Studio](https://aistudio.google.com/app/apikey) üzerinden ücretsiz alabilirsin)

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

> API anahtarı `--dart-define` ile derleme zamanında enjekte edilir; kaynak koda gömülmez.

## Proje Yapısı

```
lib/
├── main.dart                          # Uygulama giriş noktası, MultiProvider kurulumu
├── config/
│   └── app_config.dart               # Gemini model ve API endpoint yapılandırması
├── models/
│   ├── travel_route_model.dart       # Seyahat rotası veri modeli (JSON serileştirme)
│   └── budget_type.dart              # Bütçe enum (TR/EN etiket ve açıklamalar)
├── providers/
│   ├── travel_provider.dart          # Plan üretim state yönetimi (idle/loading/success/error)
│   └── settings_provider.dart        # Dark mode ve dil tercihi (SharedPreferences'a kalıcı)
├── services/
│   ├── travel_service.dart           # Gemini API istemcisi (3 retry, timeout, TR/EN prompt)
│   ├── cache_service.dart            # 24 saatlik SharedPreferences önbelleği
│   └── favorites_service.dart        # Favori planlar CRUD (duplicate korumalı)
└── views/
    ├── form_screen.dart              # Destinasyon, gün sayısı, bütçe seçim ekranı
    ├── result_screen.dart            # Plan sonuç ekranı (favori, paylaş, PDF)
    └── favorites_screen.dart         # Kayıtlı favori planlar listesi

test/
├── widget_test.dart                  # Uygulama başlatma testi
├── models/
│   └── travel_route_model_test.dart  # Model serileştirme testleri
└── views/
    ├── form_screen_test.dart         # Form doğrulama ve navigasyon testleri
    └── result_screen_test.dart       # Sonuç ekranı render testleri
```

## Uygulama Akışı

```
FormScreen
  └── Destinasyon + Gün + Bütçe seçimi
        ├── Önbellekte var mı? → ResultScreen (önbellekten)
        ├── İnternet yok + önbellekte var → ResultScreen (önbellekten)
        ├── İnternet yok + önbellekte yok → Hata mesajı
        └── Gemini API → TravelService → ResultScreen
                                            ├── Favori ekle/kaldır
                                            ├── Paylaş (share_plus)
                                            └── PDF export (pdf + printing)

FavoritesScreen (AppBar bookmark ikonu)
  └── Kayıtlı planları listele → ResultScreen
```

## Kullanılan Teknolojiler

| Paket | Versiyon | Amaç |
|---|---|---|
| [Flutter](https://flutter.dev/) | — | Cross-platform UI framework |
| [Dio](https://pub.dev/packages/dio) | ^5.9.2 | HTTP istemcisi (retry, timeout) |
| [Provider](https://pub.dev/packages/provider) | ^6.1.0 | State yönetimi |
| [Google Fonts](https://pub.dev/packages/google_fonts) | ^8.1.0 | Poppins yazı tipi |
| [Shared Preferences](https://pub.dev/packages/shared_preferences) | ^2.3.0 | Önbellek, favoriler, ayarlar |
| [Connectivity Plus](https://pub.dev/packages/connectivity_plus) | ^6.0.0 | İnternet bağlantısı kontrolü |
| [Share Plus](https://pub.dev/packages/share_plus) | ^10.0.2 | Plan paylaşımı |
| [PDF](https://pub.dev/packages/pdf) | ^3.11.1 | PDF oluşturma |
| [Printing](https://pub.dev/packages/printing) | ^5.13.1 | PDF paylaşımı/yazdırma |
| [Google Gemini 1.5 Flash](https://deepmind.google/technologies/gemini/) | — | AI içerik üretimi |

## Testler

```bash
flutter test
```

21 widget ve model testi — `FakeTravelService` ile API'ye gerçek istek atmadan çalışır. `SettingsProvider` ve `SharedPreferences` mock ile izole edilmiştir.

## Platform Desteği

Android · iOS · Linux · macOS · Windows · Web
