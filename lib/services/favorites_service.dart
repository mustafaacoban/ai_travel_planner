import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/travel_route_model.dart';

class FavoritesService {
  static const _key = 'favorites';

  Future<List<TravelRoute>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((e) => TravelRoute.fromJson(jsonDecode(e))).toList();
  }

  Future<void> add(TravelRoute route) async {
    if (await isFavorite(route)) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(jsonEncode(route.toJson()));
    await prefs.setStringList(_key, list);
  }

  Future<void> removeAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      await prefs.setStringList(_key, list);
    }
  }

  Future<bool> isFavorite(TravelRoute route) async {
    final list = await getAll();
    return list.any((r) =>
        r.destination == route.destination &&
        r.days == route.days &&
        r.budget == route.budget);
  }
}
