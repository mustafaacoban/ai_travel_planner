import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/travel_service.dart';
import 'result_screen.dart';

class FormScreen extends StatefulWidget {
  final ITravelService? travelService;
  const FormScreen({super.key, this.travelService});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  late final ITravelService _travelService;

  int _days = 3;
  String _budget = 'Orta';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _travelService = widget.travelService ?? TravelService();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'AI Rota Planlayıcı',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
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
                  _buildLabel('Nereye gitmek istersiniz?', Icons.flight_takeoff),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _destinationController,
                    decoration: _inputDecoration('Örn: Paris, Tokyo, Antalya...', Icons.location_on),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Lütfen bir varış noktası girin' : null,
                  ),
                  const SizedBox(height: 28),
                  _buildLabel('Kaç gün?  →  $_days Gün', Icons.calendar_today),
                  Slider(
                    value: _days.toDouble(),
                    min: 1,
                    max: 14,
                    divisions: 13,
                    label: '$_days Gün',
                    activeColor: Colors.deepPurple,
                    onChanged: (v) => setState(() => _days = v.toInt()),
                  ),
                  const SizedBox(height: 28),
                  _buildLabel('Bütçe Tercihi', Icons.wallet),
                  const SizedBox(height: 12),
                  ...['Ekonomik', 'Orta', 'Lüks'].map(_buildBudgetCard),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      onPressed: _isLoading ? null : _submitForm,
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(
                        'Rota Oluştur',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 20),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.deepPurple),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
    );
  }

  Widget _buildBudgetCard(String level) {
    final isSelected = _budget == level;
    const icons = {
      'Ekonomik': Icons.savings,
      'Orta': Icons.account_balance_wallet,
      'Lüks': Icons.diamond,
    };
    const descriptions = {
      'Ekonomik': 'Hostel, sokak yemeği, toplu taşıma',
      'Orta': '3-4 yıldız otel, restoran, taksi',
      'Lüks': '5 yıldız, fine dining, özel transfer',
    };

    return GestureDetector(
      onTap: () => setState(() => _budget = level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.deepPurple.withAlpha(77), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            Icon(icons[level], color: isSelected ? Colors.white : Colors.deepPurple),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    descriptions[level]!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isSelected ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.deepPurple),
                const SizedBox(height: 20),
                Text(
                  'Rotanız hazırlanıyor...',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI seyahat planınızı oluşturuyor',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
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

    setState(() => _isLoading = true);

    try {
      final route = await _travelService.generateItinerary(
        destination: _destinationController.text.trim(),
        days: _days,
        budget: _budget,
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(travelRoute: route)),
      );
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text('Hata', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tamam', style: GoogleFonts.poppins(color: Colors.deepPurple)),
          ),
        ],
      ),
    );
  }
}
