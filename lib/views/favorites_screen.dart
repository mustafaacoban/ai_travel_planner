import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/travel_route_model.dart';
import '../providers/settings_provider.dart';
import '../services/favorites_service.dart';
import 'result_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _service = FavoritesService();
  List<TravelRoute> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _service.getAll();
    if (mounted) setState(() { _favorites = list; _loading = false; });
  }

  Future<void> _delete(int index) async {
    await _service.removeAt(index);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<SettingsProvider>().language == 'tr';
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTr ? 'Favori Planlar' : 'Favorite Plans',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : _favorites.isEmpty
              ? _buildEmpty(theme, isTr)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) =>
                      _buildCard(_favorites[index], index, isTr),
                ),
    );
  }

  Widget _buildEmpty(ThemeData theme, bool isTr) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bookmark_border, size: 72,
              color: theme.colorScheme.onSurfaceVariant.withAlpha(120)),
          const SizedBox(height: 16),
          Text(
            isTr ? 'Henüz favori plan yok' : 'No favorite plans yet',
            style: GoogleFonts.poppins(
                fontSize: 16, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            isTr
                ? 'Bir plan oluşturduktan sonra kaydet butonuna bas'
                : 'Create a plan and tap the save button',
            style: GoogleFonts.poppins(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant.withAlpha(160)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(TravelRoute route, int index, bool isTr) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(travelRoute: route, fromCache: false),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.flight, color: Colors.deepPurple),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.destination,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _tag(Icons.calendar_today,
                            '${route.days} ${isTr ? 'Gün' : 'Days'}'),
                        const SizedBox(width: 8),
                        _tag(Icons.wallet, route.budget),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmDelete(index, route.destination, isTr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.deepPurple),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _confirmDelete(int index, String destination, bool isTr) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isTr ? 'Sil' : 'Delete',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
            isTr
                ? '$destination planı favorilerden kaldırılsın mı?'
                : 'Remove $destination from favorites?',
            style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isTr ? 'İptal' : 'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _delete(index);
            },
            child: Text(isTr ? 'Sil' : 'Delete',
                style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
