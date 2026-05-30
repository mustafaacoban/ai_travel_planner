import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/travel_provider.dart';
import 'providers/settings_provider.dart';
import 'views/form_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final TravelProvider? travelProvider;
  const MyApp({super.key, this.travelProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        travelProvider != null
            ? ChangeNotifierProvider.value(value: travelProvider!)
            : ChangeNotifierProvider(create: (_) => TravelProvider()),
      ],
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp(
      title: 'AI Rota Planlayıcı',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const FormScreen(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: brightness,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        brightness == Brightness.dark
            ? ThemeData.dark().textTheme
            : ThemeData.light().textTheme,
      ),
      useMaterial3: true,
    );
  }
}
