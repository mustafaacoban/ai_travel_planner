class TravelRoute {
  final String destination;
  final int days;
  final String budget;
  final String itinerary;

  const TravelRoute({
    required this.destination,
    required this.days,
    required this.budget,
    required this.itinerary,
  });

  Map<String, dynamic> toJson() => {
        'destination': destination,
        'days': days,
        'budget': budget,
        'itinerary': itinerary,
      };

  factory TravelRoute.fromJson(Map<String, dynamic> json) => TravelRoute(
        destination: json['destination'] as String,
        days: json['days'] as int,
        budget: json['budget'] as String,
        itinerary: json['itinerary'] as String,
      );
}
