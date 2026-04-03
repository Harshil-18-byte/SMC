import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/screens/hospital/hospital_details_screen.dart';

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

class SMCMap extends StatefulWidget {
  final bool showHeatmap;
  final bool showMarkers;
  final List<LatLng>? heatPoints;
  final Function(LatLng)? onTap;

  const SMCMap({
    super.key,
    this.showHeatmap = false,
    this.showMarkers = true,
    this.heatPoints,
    this.onTap,
  });

  @override
  State<SMCMap> createState() => _SMCMapState();
}

class _SMCMapState extends State<SMCMap> {
  final MapController _mapController = MapController();
  bool _isLoading = true;
  String? _error;

  // Solapur default location
  static const LatLng _solapurCenter = LatLng(17.6599, 75.9064);

  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Check location permission
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
      } catch (e) {
        // Ignore location permission errors on non-mobile platforms if any
        debugPrint('Location permission error: $e');
      }

      // Load markers if needed
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
      final hospitalsData = await firestoreService.getCollection(
          collection: 'hospital_intake_status');

      final markers = hospitalsData.map((hospital) {
        final id = hospital['id'] as String;
        final name = hospital['name'] as String? ?? 'Unknown Hospital';
        final lat = (hospital['latitude'] as num?)?.toDouble() ?? 0.0;
        final lng = (hospital['longitude'] as num?)?.toDouble() ?? 0.0;
        final availableBeds = (hospital['bedAvailable'] as num?)?.toInt() ?? 0;

        return Marker(
          point: LatLng(lat, lng),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HospitalDetailsScreen(
                    hospitalId: id,
                    hospitalName: name,
                  ),
                ),
              );
            },
            child: Icon(
              Icons.location_on,
              color: availableBeds > 10 ? Colors.green : Colors.red,
              size: 40,
            ),
          ),
        );
      }).toList();

      setState(() {
        _markers = markers;
      });
    } catch (e) {
      debugPrint('Error loading markers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: context.colors.surface,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading map...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        color: context.colors.surface,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Map Error'),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _initializeMap();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _solapurCenter,
        initialZoom: 13.0,
        minZoom: 10.0,
        maxZoom: 18.0,
        onTap: widget.onTap != null
            ? (tapPosition, point) => widget.onTap!(point)
            : null,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'in.gov.smc.smcapp',
        ),
        MarkerLayer(
          markers: _markers,
        ),
        if (widget.showHeatmap)
          CircleLayer(
            circles: widget.heatPoints != null
                ? widget.heatPoints!
                    .map((p) => CircleMarker(
                          point: p,
                          color: Colors.red.withValues(alpha: 0.3),
                          useRadiusInMeter: true,
                          radius: 800,
                        ))
                    .toList()
                : [
                    // Simulated Heatmap Points for Solapur
                    CircleMarker(
                      point: const LatLng(17.6599, 75.9064), // Civil Lines
                      color: Colors.red.withValues(alpha: 0.3),
                      useRadiusInMeter: true,
                      radius: 1500, // 1.5km radius
                    ),
                    CircleMarker(
                      point: const LatLng(17.67, 75.92), // Hotgi Road Area
                      color: Colors.orange.withValues(alpha: 0.3),
                      useRadiusInMeter: true,
                      radius: 1200,
                    ),
                    CircleMarker(
                      point: const LatLng(17.63, 75.89), // Navi Peth
                      color: Colors.yellow.withValues(alpha: 0.3),
                      useRadiusInMeter: true,
                      radius: 1000,
                    ),
                    CircleMarker(
                      point: const LatLng(17.65, 75.94), // MIDC Area
                      color: Colors.green.withValues(alpha: 0.3),
                      useRadiusInMeter: true,
                      radius: 2000,
                    ),
                  ],
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


