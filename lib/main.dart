import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/travel_provider.dart';
import 'views/form_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final TravelProvider? travelProvider;
  const MyApp({super.key, this.travelProvider});

  @override
  Widget build(BuildContext context) {
    final provider = travelProvider;
    final app = _buildMaterialApp();
    return provider != null
        ? ChangeNotifierProvider.value(value: provider, child: app)
        : ChangeNotifierProvider(create: (_) => TravelProvider(), child: app);
  }

  Widget _buildMaterialApp() {
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
      home: const FormScreen(),
    );
  }
}
