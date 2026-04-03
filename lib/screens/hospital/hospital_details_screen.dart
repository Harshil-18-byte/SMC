import 'package:flutter/material.dart';

import 'package:smc/data/services/firestore_service.dart';
import 'package:fl_chart/fl_chart.dart';

class HospitalDetailsScreen extends StatefulWidget {
  final String hospitalId;
  final String hospitalName;

  const HospitalDetailsScreen({
    super.key,
    required this.hospitalId,
    required this.hospitalName,
  });

  @override
  State<HospitalDetailsScreen> createState() => _HospitalDetailsScreenState();
}

class _HospitalDetailsScreenState extends State<HospitalDetailsScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic>? _hospitalData;
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _staff = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHospitalDetails();
  }

  Future<void> _loadHospitalDetails() async {
    try {
      // Fetch Hospital Data
      final hospitalDoc = await _firestoreService.readDocument(
          collection: 'hospital_intake_status', docId: widget.hospitalId);

      // Fetch Departments (Mocked or empty for now as not in seeder)
      final departmentsDocs = <Map<String, dynamic>>[];

      // Fetch Staff (Doctors from system_users)
      final staffDocs = await _firestoreService.queryCollection(
        collection: 'system_users',
        field: 'hospitalId',
        value: widget.hospitalId,
      );

      if (mounted) {
        setState(() {
          _hospitalData = hospitalDoc;
          _departments = departmentsDocs;
          _staff = staffDocs
              .where((u) => u['role'] == 'doctor' || u['role'] == 'Admin')
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading hospital details: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor)),
      );
    }

    if (_hospitalData == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.hospitalName)),
        body: const Center(child: Text("Hospital details not found.")),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.hospitalName,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.7),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).highlightColor.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(text: "Overview"),
                Tab(text: "Departments"),
                Tab(text: "Staff"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildDepartmentsTab(),
                  _buildStaffTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        image: DecorationImage(
          image: AssetImage(
              'assets/images/hospital_placeholder.jpg'), // Ensure asset exists or handle error
          fit: BoxFit.cover,
          onError: (_, __) {}, // Graceful fallback
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black12, Colors.black87],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _hospitalData?['name'] ?? widget.hospitalName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _hospitalData?['address'] ?? 'Unknown Address',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getLoadColor(_calculateLoad()),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Load: ${_calculateLoad()}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Type: ${_hospitalData?['type'] ?? "General"}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateLoad() {
    final available = (_hospitalData?['bedAvailable'] as num?)?.toInt() ?? 0;
    final total = (_hospitalData?['bedTotal'] as num?)?.toInt() ?? 100;
    if (total == 0) return 'UNKNOWN';

    final occupancy = 1.0 - (available / total);
    if (occupancy > 0.9) return 'HIGH';
    if (occupancy > 0.7) return 'MEDIUM';
    return 'LOW';
  }

  Widget _buildOverviewTab() {
    final available = _hospitalData?['bedAvailable'] ?? 0;
    final total = _hospitalData?['bedTotal'] ?? 100;
    final icu = _hospitalData?['icuBeds'] ?? 0;
    final ventilators = _hospitalData?['ventilators'] ?? 0;
    final occupancyRate = total > 0 ? 1.0 - (available / total) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Live Statistics",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildStatCard("Available Beds", "$available / $total",
                      Icons.hotel, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildStatCard(
                      "Occupancy",
                      "${(occupancyRate * 100).toStringAsFixed(1)}%",
                      Icons.pie_chart,
                      _getOccupancyColor(occupancyRate))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildStatCard("ICU Beds", "$icu",
                      Icons.local_hospital, Colors.redAccent)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildStatCard(
                      "Ventilators", "$ventilators", Icons.air, Colors.orange)),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Occupancy Trend",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 40),
                      const FlSpot(1, 35),
                      const FlSpot(2, 50),
                      const FlSpot(3, 48),
                      const FlSpot(4, 60),
                      const FlSpot(5, 55),
                      FlSpot(6, occupancyRate * 100),
                    ],
                    isCurved: true,
                    color: Theme.of(context).primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.1)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text("Contact Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(_hospitalData?['contact'] ?? "Not available"),
            onTap: () {}, // Implement call
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentsTab() {
    if (_departments.isEmpty) {
      return const Center(child: Text("No departments listed."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _departments.length,
      itemBuilder: (context, index) {
        final dept = _departments[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Icon(Icons.medical_services,
                  color: Theme.of(context).primaryColor),
            ),
            title: Text(dept['name'] ?? 'Unknown Department',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(dept['specialty'] ?? 'General'),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildStaffTab() {
    if (_staff.isEmpty) {
      return const Center(child: Text("No staff listed."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _staff.length,
      itemBuilder: (context, index) {
        final member = _staff[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  const AssetImage('assets/images/avatar_placeholder.png'),
              onBackgroundImageError: (_, __) {},
              child: Text(member['name']?.substring(0, 1) ?? "U",
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.grey,
            ),
            title: Text(member['name'] ?? 'Unknown Staff'),
            subtitle: Text(member['role'] ?? 'Staff'),
            trailing: IconButton(
              icon: const Icon(Icons.phone, color: Colors.green),
              onPressed: () {}, // Implement call
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  Color _getLoadColor(String? load) {
    switch (load?.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getOccupancyColor(double occupancy) {
    if (occupancy > 0.8) return Colors.red;
    if (occupancy > 0.5) return Colors.orange;
    return Colors.green;
  }
}


