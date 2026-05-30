import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/budget_type.dart';
import '../providers/travel_provider.dart';
import '../providers/settings_provider.dart';
import 'result_screen.dart';
import 'favorites_screen.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();

  int _days = 3;
  BudgetType _budget = BudgetType.orta;

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isTr = settings.language == 'tr';

    return Consumer<TravelProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: Text(
              isTr ? 'AI Rota Planlayıcı' : 'AI Travel Planner',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.deepPurple,
            elevation: 0,
            actions: [
              GestureDetector(
                onTap: () => settings.setLanguage(isTr ? 'en' : 'tr'),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isTr ? 'EN' : 'TR',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  settings.darkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
                onPressed: settings.toggleDarkMode,
                tooltip: settings.darkMode ? 'Açık tema' : 'Koyu tema',
              ),
              IconButton(
                icon: const Icon(Icons.bookmark, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FavoritesScreen()),
                ),
                tooltip: isTr ? 'Favoriler' : 'Favorites',
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildLabel(
                        isTr
                            ? 'Nereye gitmek istersiniz?'
                            : 'Where do you want to go?',
                        Icons.flight_takeoff,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _destinationController,
                        decoration: _inputDecoration(
                          isTr
                              ? 'Örn: Paris, Tokyo, Antalya...'
                              : 'e.g. Paris, Tokyo, New York...',
                          Icons.location_on,
                        ),
                        validator: (value) =>
                            (value == null || value.isEmpty)
                                ? (isTr
                                    ? 'Lütfen bir varış noktası girin'
                                    : 'Please enter a destination')
                                : null,
                      ),
                      const SizedBox(height: 28),
                      _buildLabel(
                        isTr
                            ? 'Kaç gün?  →  $_days Gün'
                            : 'How many days?  →  $_days Days',
                        Icons.calendar_today,
                      ),
                      Slider(
                        value: _days.toDouble(),
                        min: 1,
                        max: 14,
                        divisions: 13,
                        label: '$_days ${isTr ? 'Gün' : 'Days'}',
                        activeColor: Colors.deepPurple,
                        onChanged: (v) =>
                            setState(() => _days = v.toInt()),
                      ),
                      const SizedBox(height: 28),
                      _buildLabel(
                        isTr ? 'Bütçe Tercihi' : 'Budget Preference',
                        Icons.wallet,
                      ),
                      const SizedBox(height: 12),
                      ...BudgetType.values
                          .map((b) => _buildBudgetCard(b, isTr)),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16),
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                          onPressed:
                              provider.isLoading ? null : _submitForm,
                          icon: const Icon(Icons.auto_awesome),
                          label: Text(
                            isTr ? 'Rota Oluştur' : 'Create Itinerary',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              if (provider.isLoading) _buildLoadingOverlay(isTr),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 20),
        const SizedBox(width: 8),
        Text(text,
            style: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.deepPurple),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Colors.deepPurple, width: 2),
      ),
    );
  }

  Widget _buildBudgetCard(BudgetType level, bool isTr) {
    final isSelected = _budget == level;

    return GestureDetector(
      onTap: () => setState(() => _budget = level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.deepPurple
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.deepPurple.withAlpha(77),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(level.icon,
                color:
                    isSelected ? Colors.white : Colors.deepPurple),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTr ? level.label : level.labelEn,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    level.cardDescription(isTr ? 'tr' : 'en'),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white70
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(bool isTr) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                    color: Colors.deepPurple),
                const SizedBox(height: 20),
                Text(
                  isTr
                      ? 'Rotanız hazırlanıyor...'
                      : 'Preparing your itinerary...',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  isTr
                      ? 'AI seyahat planınızı oluşturuyor'
                      : 'AI is creating your travel plan',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final settings = context.read<SettingsProvider>();
    final provider = context.read<TravelProvider>();

    await provider.generate(
      destination: _destinationController.text.trim(),
      days: _days,
      budget: _budget.labelFor(settings.language),
      language: settings.language,
    );

    if (!mounted) return;

    if (provider.state == TravelState.success && provider.route != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            travelRoute: provider.route!,
            fromCache: provider.fromCache,
          ),
        ),
      );
      if (!mounted) return;
      provider.reset();
    } else if (provider.state == TravelState.error) {
      final isTr = context.read<SettingsProvider>().language == 'tr';
      _showError(provider.errorMessage ??
          (isTr ? 'Bilinmeyen hata' : 'Unknown error'));
      provider.reset();
    }
  }

  void _showError(String message) {
    final isTr = context.read<SettingsProvider>().language == 'tr';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(isTr ? 'Hata' : 'Error',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold)),
          ],
        ),
        content:
            Text(message, style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isTr ? 'Tamam' : 'OK',
                style: GoogleFonts.poppins(
                    color: Colors.deepPurple)),
          ),
        ],
      ),
    );
  }
}
