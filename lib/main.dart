import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/travel_service.dart';
import 'views/form_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final ITravelService? travelService;
  const MyApp({super.key, this.travelService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Rota Planlayıcı',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: FormScreen(travelService: travelService),
    );
  }
}
