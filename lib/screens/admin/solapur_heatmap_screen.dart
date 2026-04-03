import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smc/data/services/firestore_service.dart';

class SolapurHeatmapScreen extends StatefulWidget {
  const SolapurHeatmapScreen({super.key});

  @override
  State<SolapurHeatmapScreen> createState() => _SolapurHeatmapScreenState();
}

class _HeatPoint {
  final LatLng location;
  final double intensity;
  _HeatPoint(this.location, this.intensity);
}

class _SolapurHeatmapScreenState extends State<SolapurHeatmapScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<_HeatPoint> _heatPoints = [];
  bool _isLoading = true;

  bool _showPredictive = false;

  @override
  void initState() {
    super.initState();
    _loadHeatmapFromFirestore();
  }

  /// Load real surveillance points from Firestore to populate the heatmap
  Future<void> _loadHeatmapFromFirestore() async {
    setState(() => _isLoading = true);
    try {
      final pointsData = await _firestoreService.getCollection(
        collection: 'surveillance_points',
      );

      List<_HeatPoint> points = pointsData.map((data) {
        return _HeatPoint(
          LatLng(data['latitude'] as double, data['longitude'] as double),
          (data['intensity'] as num).toDouble(),
        );
      }).toList();

      if (points.isEmpty) {
        points = _defaultHeatPoints.map((p) => _HeatPoint(p, 1.0)).toList();
      }

      setState(() {
        _heatPoints = points;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading heatmap: $e');
      setState(() => _isLoading = false);
    }
  }

  final List<LatLng> _defaultHeatPoints = [
    const LatLng(17.6648, 75.9202),
    const LatLng(17.6647, 75.9201),
    const LatLng(17.6649, 75.9203),
    const LatLng(17.6599, 75.9064),
    const LatLng(17.6601, 75.9066),
    const LatLng(17.6597, 75.9062),
    const LatLng(17.6352, 75.9131),
    const LatLng(17.6354, 75.9133),
    const LatLng(17.6351, 75.9129),
    const LatLng(17.6702, 75.8956),
    const LatLng(17.6704, 75.8958),
    const LatLng(17.6551, 75.8998),
    const LatLng(17.6553, 75.9000),
  ];

  final List<LatLng> _predictivePoints = [
    const LatLng(17.6500, 75.9100),
    const LatLng(17.6400, 75.8900),
    const LatLng(17.6800, 75.9300),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showPredictive
            ? "Predictive Analysis (Next 7 Days)"
            : "Solapur Real-Time Heatmap"),
        actions: [
          IconButton(
            icon: Icon(
                _showPredictive
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: _showPredictive ? Colors.orange : null),
            tooltip: 'Toggle Predictive Mode',
            onPressed: () => setState(() => _showPredictive = !_showPredictive),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHeatmapFromFirestore,
          ),
          IconButton(
            icon: const Icon(Icons.view_in_ar),
            tooltip: '3D Immersive View',
            onPressed: () {
              Navigator.pushNamed(context, '/immersive-heatmap');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(17.6599, 75.9064), // Solapur center
                initialZoom: 13.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'in.gov.smc.smcapp',
                ),
                CircleLayer(
                  circles: [
                    ..._heatPoints.map((point) {
                      return CircleMarker(
                        point: point.location,
                        color:
                            Colors.red.withValues(alpha: 0.3 * point.intensity),
                        useRadiusInMeter: true,
                        radius: 200 * point.intensity,
                      );
                    }),
                    if (_showPredictive)
                      ..._predictivePoints.map((point) {
                        return CircleMarker(
                          point: point,
                          color: Colors.orange.withValues(alpha: 0.2),
                          useRadiusInMeter: true,
                          radius: 400,
                          borderStrokeWidth: 2,
                          borderColor: Colors.orange.withValues(alpha: 0.5),
                        );
                      }),
                  ],
                ),
              ],
            ),
    );
  }
}


