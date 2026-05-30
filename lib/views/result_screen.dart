import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/travel_route_model.dart';
import '../providers/settings_provider.dart';
import '../services/favorites_service.dart';

class ResultScreen extends StatefulWidget {
  final TravelRoute travelRoute;
  final bool fromCache;

  const ResultScreen({super.key, required this.travelRoute, this.fromCache = false});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _favService = FavoritesService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final result = await _favService.isFavorite(widget.travelRoute);
    if (mounted) setState(() => _isFavorite = result);
  }

  Future<void> _toggleFavorite() async {
    bool success = false;
    if (_isFavorite) {
      final list = await _favService.getAll();
      final idx = list.indexWhere((r) =>
          r.destination == widget.travelRoute.destination &&
          r.days == widget.travelRoute.days &&
          r.budget == widget.travelRoute.budget);
      if (idx != -1) {
        await _favService.removeAt(idx);
        success = true;
      }
    } else {
      await _favService.add(widget.travelRoute);
      success = true;
    }
    if (!success || !mounted) return;
    final nowFav = !_isFavorite;
    setState(() => _isFavorite = nowFav);
    if (!mounted) return;
    final isTr = context.read<SettingsProvider>().language == 'tr';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        nowFav
            ? (isTr ? 'Favorilere eklendi' : 'Added to favorites')
            : (isTr ? 'Favorilerden kaldırıldı' : 'Removed from favorites'),
        style: GoogleFonts.poppins(),
      ),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _share() {
    final route = widget.travelRoute;
    final isTr = context.read<SettingsProvider>().language == 'tr';
    final dayLabel = isTr ? 'Gün' : 'Days';
    final text =
        '🗺️ ${route.destination} — ${route.days} $dayLabel (${route.budget})\n\n${route.itinerary}';
    Share.share(text);
  }

  String _stripForPdf(String text) {
    return text
        .replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (m) => m.group(1) ?? '')
        .replaceAll(RegExp(r'[^\x00-\x7FÀ-ɏ]'), '');
  }

  Future<void> _exportPdf() async {
    final route = widget.travelRoute;
    final isTr = context.read<SettingsProvider>().language == 'tr';
    final dayLabel = isTr ? 'Gün' : 'Days';
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Text(
            '${route.destination} — ${route.days} $dayLabel (${route.budget})',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),
          ...route.itinerary.split('\n').map((line) {
            final trimmed = line.trim();
            if (trimmed.startsWith('## ') || trimmed.startsWith('# ')) {
              final text = _stripForPdf(trimmed.replaceFirst(RegExp(r'^#+\s*'), ''));
              return pw.Padding(
                padding: const pw.EdgeInsets.only(top: 12, bottom: 4),
                child: pw.Text(
                  text,
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              );
            }
            final plain = _stripForPdf(trimmed);
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 1),
              child: pw.Text(plain, style: const pw.TextStyle(fontSize: 11)),
            );
          }),
        ],
      ),
    );

    final fileSlug = isTr ? 'gun' : 'days';
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${route.destination}_${route.days}$fileSlug.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<SettingsProvider>().language == 'tr';
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.travelRoute.destination,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.bookmark : Icons.bookmark_border),
            tooltip: _isFavorite
                ? (isTr ? 'Favorilerden çıkar' : 'Remove from favorites')
                : (isTr ? 'Favorilere ekle' : 'Add to favorites'),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: isTr ? 'Paylaş' : 'Share',
            onPressed: _share,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: isTr ? 'PDF olarak dışa aktar' : 'Export as PDF',
            onPressed: _exportPdf,
          ),
        ],
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
    final isTr = context.watch<SettingsProvider>().language == 'tr';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      color: Colors.deepPurple,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _chip(Icons.calendar_today,
              '${widget.travelRoute.days} ${isTr ? 'Gün' : 'Days'}'),
          const SizedBox(width: 16),
          _chip(Icons.wallet, widget.travelRoute.budget),
          if (widget.fromCache) ...[
            const SizedBox(width: 16),
            _chip(Icons.offline_bolt, isTr ? 'Önbellekten' : 'From Cache'),
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
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItineraryWidgets() {
    final lines = widget.travelRoute.itinerary.split('\n');
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
        style: GoogleFonts.poppins(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseStyle = GoogleFonts.poppins(
        fontSize: 14,
        height: 1.6,
        color: isDark ? Colors.white70 : Colors.black87);
    final boldStyle = GoogleFonts.poppins(
      fontSize: 14,
      height: 1.6,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF7C4DFF),
    );

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(
            TextSpan(text: text.substring(lastEnd, match.start), style: baseStyle));
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
    final isTr = context.watch<SettingsProvider>().language == 'tr';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, -4)),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.add_location_alt),
          label: Text(
            isTr ? 'Yeni Plan Oluştur' : 'Create New Plan',
            style:
                GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
