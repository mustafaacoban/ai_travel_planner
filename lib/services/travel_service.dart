import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/budget_type.dart';
import '../models/travel_route_model.dart';

abstract class ITravelService {
  Future<TravelRoute> generateItinerary({
    required String destination,
    required int days,
    required String budget,
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
  }) async {
    Exception? lastError;

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        return await _request(destination: destination, days: days, budget: budget);
      } on DioException catch (e) {
        if (e.response != null) {
          throw Exception('API Hatası ${e.response?.statusCode}: ${e.response?.data}');
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
  }) async {
    final budgetText = BudgetType.fromLabel(budget).apiDescription;

    final prompt = '''
$destination şehrine $days günlük, $budgetText bir seyahat planı oluştur.

Her gün için şu formatı kullan:
## Gün X: [Temanın Başlığı]
🌅 **Sabah:** [aktiviteler]
🌞 **Öğle:** [aktiviteler ve yemek önerisi]
🌆 **Akşam:** [aktiviteler ve akşam yemeği önerisi]
💡 **Günün İpucu:** [pratik bir tavsiye]

Sonunda "## Genel İpuçları" bölümü ekle (ulaşım, para birimi, en iyi ziyaret zamanı).
Yanıtı Türkçe ver, samimi ve heyecanlı bir dille yaz.''';

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
      throw Exception('İçerik güvenlik filtresi tarafından engellendi veya yanıt alınamadı.');
    }

    final content = candidates[0]['content']['parts'][0]['text'] as String;

    return TravelRoute(
      destination: destination,
      days: days,
      budget: budget,
      itinerary: content,
    );
  }
}
