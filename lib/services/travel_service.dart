import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/budget_type.dart';
import '../models/travel_route_model.dart';

abstract class ITravelService {
  Future<TravelRoute> generateItinerary({
    required String destination,
    required int days,
    required String budget,
    String language = 'tr',
  });
}

class TravelService implements ITravelService {
  final Dio _dio;
  static const _maxRetries = 3;

  TravelService([Dio? dio])
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 60),
            ));

  @override
  Future<TravelRoute> generateItinerary({
    required String destination,
    required int days,
    required String budget,
    String language = 'tr',
  }) async {
    Exception? lastError;

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        return await _request(
            destination: destination, days: days, budget: budget, language: language);
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        final isRetryable = e.response == null ||
            statusCode == 429 ||
            (statusCode != null && statusCode >= 500);
        if (!isRetryable) {
          if (statusCode == 401 || statusCode == 403) {
            throw Exception('API anahtarı geçersiz veya yetkisiz (HTTP $statusCode).');
          } else if (statusCode == 400) {
            throw Exception('Geçersiz istek (HTTP 400).');
          } else {
            throw Exception('API Hatası: HTTP $statusCode');
          }
        }
        lastError = Exception('Bağlantı hatası: ${e.message}');
        if (attempt < _maxRetries) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }

    throw lastError!;
  }

  Future<TravelRoute> _request({
    required String destination,
    required int days,
    required String budget,
    required String language,
  }) async {
    if (!AppConfig.isApiKeyConfigured) {
      throw Exception(
          'API anahtarı yapılandırılmamış. --dart-define=GEMINI_API_KEY=<API_KEY> ile çalıştırın.');
    }
    final budgetText = BudgetType.fromLabel(budget).apiDescription(language);
    final isTr = language == 'tr';

    final prompt = isTr
        ? '''
$destination şehrine $days günlük, $budgetText bir seyahat planı oluştur.

Her gün için şu formatı kullan:
## Gün X: [Temanın Başlığı]
🌅 **Sabah:** [aktiviteler]
🌞 **Öğle:** [aktiviteler ve yemek önerisi]
🌆 **Akşam:** [aktiviteler ve akşam yemeği önerisi]
💡 **Günün İpucu:** [pratik bir tavsiye]

Sonunda "## Genel İpuçları" bölümü ekle (ulaşım, para birimi, en iyi ziyaret zamanı).
Yanıtı Türkçe ver, samimi ve heyecanlı bir dille yaz.'''
        : '''
Create a $days-day travel itinerary for $destination with a $budgetText budget.

Use this format for each day:
## Day X: [Theme Title]
🌅 **Morning:** [activities]
🌞 **Afternoon:** [activities and lunch suggestion]
🌆 **Evening:** [activities and dinner suggestion]
💡 **Tip of the Day:** [practical advice]

At the end add a "## General Tips" section (transport, currency, best time to visit).
Write in English with an enthusiastic and friendly tone.''';

    final response = await _dio.post(
      '${AppConfig.geminiBaseUrl}/${AppConfig.geminiModel}:generateContent?key=${AppConfig.geminiApiKey}',
      data: {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'maxOutputTokens': 3000,
        },
      },
    );

    final candidates = response.data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception(isTr
          ? 'İçerik güvenlik filtresi tarafından engellendi veya yanıt alınamadı.'
          : 'Content was blocked by safety filter or no response received.');
    }

    final candidate = candidates[0] as Map<String, dynamic>?;
    final content = candidate?['content']?['parts']?[0]?['text'] as String?;
    if (content == null || content.isEmpty) {
      throw Exception(isTr
          ? 'API geçerli içerik döndürmedi.'
          : 'API returned no valid content.');
    }

    return TravelRoute(
      destination: destination,
      days: days,
      budget: budget,
      itinerary: content,
    );

  }
}
