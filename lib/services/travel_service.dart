import 'package:dio/dio.dart';
import '../config/app_config.dart';
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
    const budgetDesc = {
      'Ekonomik': 'düşük bütçeli (hostel veya uygun oteller, sokak yemeği, toplu taşıma)',
      'Orta': 'orta bütçeli (3-4 yıldızlı oteller, restoranlar, taksi)',
      'Lüks': 'yüksek bütçeli (5 yıldızlı oteller, fine dining, özel transfer)',
    };

    final budgetText = budgetDesc[budget] ?? 'orta bütçeli';

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

    try {
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

      final content =
          response.data['candidates'][0]['content']['parts'][0]['text'] as String;

      return TravelRoute(
        destination: destination,
        days: days,
        budget: budget,
        itinerary: content,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('API Hatası ${e.response?.statusCode}: ${e.response?.data}');
      }
      throw Exception('Bağlantı hatası: ${e.message}');
    }
  }
}
