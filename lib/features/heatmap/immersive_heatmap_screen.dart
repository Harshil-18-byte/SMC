import 'package:flutter/material.dart';
import 'package:smc/core/widgets/dashboard_back_handler.dart';
import 'package:smc/features/heatmap/immersive_heatmap.dart';

class ImmersiveHeatmapScreen extends StatelessWidget {
  const ImmersiveHeatmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardBackHandler(
      dashboardName: '3D Analytics',
      child: Scaffold(
        backgroundColor: Colors.black, // Dark background for the 3D effect
        appBar: AppBar(
          title: const Text('Immersive Analytics'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: const ImmersiveHeatmap(),
      ),
    );
  }
}


