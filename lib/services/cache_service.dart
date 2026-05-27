import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/travel_route_model.dart';

class CacheService {
  static const _prefix = 'route_';
  static const _ttl = Duration(hours: 24);

  String _key(String destination, int days, String budget) =>
      '$_prefix${destination.toLowerCase().trim()}_${days}_${budget.toLowerCase()}';

  Future<void> save(TravelRoute route) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      ...route.toJson(),
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(
      _key(route.destination, route.days, route.budget),
      jsonEncode(data),
    );
  }

  Future<TravelRoute?> get(String destination, int days, String budget) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(destination, days, budget));
    if (raw == null) return null;

    final data = jsonDecode(raw) as Map<String, dynamic>;
    final age = DateTime.now().millisecondsSinceEpoch - (data['cachedAt'] as int);

    if (age > _ttl.inMilliseconds) {
      await prefs.remove(_key(destination, days, budget));
      return null;
    }

    return TravelRoute.fromJson(data);
  }
}
