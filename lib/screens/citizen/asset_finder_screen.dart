import 'package:flutter/material.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/models/command_center_models.dart';
import 'package:smc/core/visuals/industrial_visuals.dart';
import 'package:google_fonts/google_fonts.dart';

/// Asset Finder Screen
/// Discover regional infrastructure projects, real-time health scores, and service availability.
class AssetFinderScreen extends StatefulWidget {
  const AssetFinderScreen({super.key});

  @override
  State<AssetFinderScreen> createState() => _AssetFinderScreenState();
}

class _AssetFinderScreenState extends State<AssetFinderScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  List<AssetStatus> _assets = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _firestoreService.getCollection(collection: 'asset_intake_status');
      _assets = data.map((d) => AssetStatus.fromMap(d, d['id'])).toList();
    } catch (e) {
      debugPrint('Error loading asset finder: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAssets = _assets.where((a) => a.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text('ASSET FINDER', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: IndustrialVisuals.blueprintBackground(
        isDark: true,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search for Bridge, Road, Sea Link...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.blue),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : filteredAssets.isEmpty 
                  ? const Center(child: Text('No assets discovered.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredAssets.length,
                      itemBuilder: (context, index) => _buildAssetTile(filteredAssets[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetTile(AssetStatus asset) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: asset.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.engineering_rounded, color: asset.statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('HEALTH SCORE: ${asset.healthScore}/${asset.maxHealth}', style: TextStyle(color: asset.statusColor, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}
