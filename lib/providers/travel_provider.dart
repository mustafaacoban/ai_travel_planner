import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/travel_route_model.dart';
import '../services/travel_service.dart';
import '../services/cache_service.dart';

typedef ConnectivityChecker = Future<bool> Function();

enum TravelState { idle, loading, success, error }

class TravelProvider extends ChangeNotifier {
  final ITravelService _service;
  final CacheService _cache;
  final ConnectivityChecker _checkOnline;

  TravelState _state = TravelState.idle;
  TravelRoute? _route;
  String? _errorMessage;
  bool _fromCache = false;

  TravelProvider({
    ITravelService? service,
    CacheService? cache,
    ConnectivityChecker? checkOnline,
  })  : _service = service ?? TravelService(),
        _cache = cache ?? CacheService(),
        _checkOnline = checkOnline ?? _defaultConnectivityCheck;

  static Future<bool> _defaultConnectivityCheck() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);
  }

  TravelState get state => _state;
  TravelRoute? get route => _route;
  String? get errorMessage => _errorMessage;
  bool get fromCache => _fromCache;
  bool get isLoading => _state == TravelState.loading;

  Future<void> generate({
    required String destination,
    required int days,
    required String budget,
    String language = 'tr',
  }) async {
    _state = TravelState.loading;
    _errorMessage = null;
    _fromCache = false;
    notifyListeners();

    final isOnline = await _checkOnline();

    if (!isOnline) {
      final cached = await _cache.get(destination, days, budget);
      if (cached != null) {
        _route = cached;
        _fromCache = true;
        _state = TravelState.success;
      } else {
        _errorMessage = language == 'tr'
            ? 'İnternet bağlantısı yok ve önbellekte kayıtlı plan bulunamadı.'
            : 'No internet connection and no cached plan found.';
        _state = TravelState.error;
      }
      notifyListeners();
      return;
    }

    final cached = await _cache.get(destination, days, budget);
    if (cached != null) {
      _route = cached;
      _fromCache = true;
      _state = TravelState.success;
      notifyListeners();
      return;
    }

    try {
      _route = await _service.generateItinerary(
        destination: destination,
        days: days,
        budget: budget,
        language: language,
      );
      await _cache.save(_route!);
      _state = TravelState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = TravelState.error;
    }

    notifyListeners();
  }

  void reset() {
    _state = TravelState.idle;
    _route = null;
    _errorMessage = null;
    _fromCache = false;
    notifyListeners();
  }
}
