import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/travel_route_model.dart';

class ResultScreen extends StatelessWidget {
  final TravelRoute travelRoute;
  final bool fromCache;

  const ResultScreen({super.key, required this.travelRoute, this.fromCache = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          travelRoute.destination,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildInfoBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _buildItineraryWidgets(),
            ),
          ),
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildInfoBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      color: Colors.deepPurple,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _chip(Icons.calendar_today, '${travelRoute.days} Gün'),
          const SizedBox(width: 16),
          _chip(Icons.wallet, travelRoute.budget),
          if (fromCache) ...[
            const SizedBox(width: 16),
            _chip(Icons.offline_bolt, 'Önbellekten'),
          ],
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItineraryWidgets() {
    final lines = travelRoute.itinerary.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 6));
      } else if (trimmed.startsWith('## ')) {
        widgets.add(_buildDayHeader(trimmed.substring(3)));
      } else if (trimmed.startsWith('# ')) {
        widgets.add(_buildDayHeader(trimmed.substring(2)));
      } else {
        widgets.add(_buildTextLine(trimmed));
      }
    }

    return widgets;
  }

  Widget _buildDayHeader(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5E35B1), Color(0xFF7B1FA2)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E35B1).withAlpha(77),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildTextLine(String line) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(children: _parseBoldText(line)),
      ),
    );
  }

  List<TextSpan> _parseBoldText(String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;

    final baseStyle = GoogleFonts.poppins(fontSize: 14, height: 1.6, color: Colors.black87);
    final boldStyle = GoogleFonts.poppins(
      fontSize: 14,
      height: 1.6,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF4527A0),
    );

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start), style: baseStyle));
      }
      spans.add(TextSpan(text: match.group(1), style: boldStyle));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: baseStyle));
    }

    return spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans;
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, -4)),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.add_location_alt),
          label: Text(
            'Yeni Plan Oluştur',
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
