import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/core/utils/india_location_utils.dart';
import 'package:smc/config/routes.dart';

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

/// Industrial SMC Map
/// Handles geospatial infrastructure asset visualization, heatmaps, and navigation.
class SMCMap extends StatefulWidget {
  final bool showHeatmap;
  final bool showMarkers;
  final List<LatLng>? heatPoints;
  final Function(LatLng)? onTap;
  final LatLng? initialCenter;
  final double? initialZoom;

  const SMCMap({
    super.key,
    this.showHeatmap = false,
    this.showMarkers = true,
    this.heatPoints,
    this.onTap,
    this.initialCenter,
    this.initialZoom,
  });

  @override
  State<SMCMap> createState() => _SMCMapState();
}

class _SMCMapState extends State<SMCMap> {
  final MapController _mapController = MapController();
  bool _isLoading = true;
  String? _error;

  static const LatLng _indiaCenter = IndiaLocationUtils.indiaCenter;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
      } catch (e) {
        debugPrint('Location permission error: $e');
      }

      if (widget.showMarkers) {
        await _loadMarkers();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMarkers() async {
    try {
      final firestoreService = FirestoreService();
      final sitesData = await firestoreService.getCollection(collection: 'asset_intake_status');

      final markers = sitesData.map((site) {
        final id = site['id'] as String;
        final name = site['name'] as String? ?? 'Asset';
        final lat = (site['latitude'] as num?)?.toDouble() ?? 19.0760;
        final lng = (site['longitude'] as num?)?.toDouble() ?? 72.8777;
        final health = (site['healthScore'] as num?)?.toInt() ?? (site['bedAvailable'] as num?)?.toInt() ?? 100;

        return Marker(
          point: LatLng(lat, lng),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              _showAssetSummary(id, name, health);
            },
            child: Icon(
              Icons.location_on,
              color: health > 50 ? Colors.blue : Colors.red,
              size: 40,
            ),
          ),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _markers = markers;
        });
      }
    } catch (e) {
      debugPrint('Error loading markers: $e');
    }
  }

  void _showAssetSummary(String id, String name, int health) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ASSET TELEMETRY', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2)),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('HEALTH SCORE: $health%', style: TextStyle(color: health > 50 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                const Icon(Icons.security, color: Colors.blue, size: 20),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.assetDetail, arguments: {'assetId': id});
                },
                child: const Text('VIEW INSPECTION LOGS'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: context.colors.surface,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Center(child: Text('Map Initialization Error', style: TextStyle(color: Colors.red)));
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.initialCenter ?? _indiaCenter,
        initialZoom: widget.initialZoom ?? (widget.initialCenter == null ? IndiaLocationUtils.nationalZoom : 12.0),
        minZoom: 3.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'in.gov.bharat.infra',
        ),
        MarkerLayer(
          markers: _markers,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
