import 'package:flutter/material.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/models/system_inspection_model.dart';
import 'package:smc/core/localization/app_localizations.dart';

/// System Inspection & Performance Screen
/// Real-time metrics + Maintenance Scheduler
class SystemInspectionScreen extends StatefulWidget {
  const SystemInspectionScreen({super.key});

  @override
  State<SystemInspectionScreen> createState() => _SystemInspectionScreenState();
}

class _SystemInspectionScreenState extends State<SystemInspectionScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;

  bool _isLoading = true;
  List<SystemInspectionMetric> _metrics = [];
  List<MaintenanceTask> _tasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load inspection metrics
      final metricsData = await _firestoreService.getCollection(
        collection: 'system_inspection_metrics',
      );
      _metrics = metricsData
          .map((data) => SystemInspectionMetric.fromMap(data, data['id']))
          .toList();

      // Load maintenance tasks
      final tasksData = await _firestoreService.getCollection(
        collection: 'maintenance_tasks',
        orderBy: 'scheduledDate',
      );
      _tasks = tasksData
          .map((data) => MaintenanceTask.fromMap(data, data['id']))
          .toList();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Future<void> _updateTaskStatus(MaintenanceTask task, String newStatus) async {
    try {
      await _firestoreService.updateDocument(
        collection: 'maintenance_tasks',
        docId: task.id,
        data: {'status': newStatus},
      );

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Task status updated'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101922),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101922),
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).systemInspection,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF137fec),
          labelColor: const Color(0xFF137fec),
          unselectedLabelColor: Colors.grey[500],
          tabs: [
            Tab(text: AppLocalizations.of(context).translate('inspection_metrics')),
            Tab(text: AppLocalizations.of(context).translate('maintenance')),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildInspectionMetricsTab(), _buildMaintenanceTab()],
            ),
    );
  }

  Widget _buildInspectionMetricsTab() {
    final criticalMetrics = _metrics.where((m) => m.status == 'critical').length;
    final warningMetrics = _metrics.where((m) => m.status == 'warning').length;
    final normalMetrics = _metrics.where((m) => m.status == 'inspectiony').length;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInspectionSummary(
              criticalMetrics,
              warningMetrics,
              normalMetrics,
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context).translate('system_metrics'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            if (_metrics.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No metrics available',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              )
            else
              ..._metrics.map((metric) => _buildMetricCard(metric)),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionSummary(int critical, int warning, int normal) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            AppLocalizations.of(context).translate('critical'),
            critical.toString(),
            Icons.error,
            const Color(0xFFFF4D4D),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Warning',
            warning.toString(),
            Icons.warning,
            const Color(0xFFFFAB00),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            AppLocalizations.of(context).translate('success'),
            normal.toString(),
            Icons.check_circle,
            const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2733),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2D3748)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildMetricCard(SystemInspectionMetric metric) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2733),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: metric.status != 'inspectiony'
              ? metric.statusColor
              : const Color(0xFF2D3748),
          width: metric.status != 'inspectiony' ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(metric.statusIcon, color: metric.statusColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Updated ${_getTimeAgo(metric.lastUpdated)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: metric.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  metric.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: metric.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                metric.value.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: metric.statusColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                metric.unit,
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
              const Spacer(),
              Text(
                'Threshold: ${metric.threshold} ${metric.unit}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: metric.value / (metric.threshold * 1.2),
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(metric.statusColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  /// Maintenance Tab
  Widget _buildMaintenanceTab() {
    final pendingTasks = _tasks.where((t) => t.status == 'pending').length;
    final inProgressTasks =
        _tasks.where((t) => t.status == 'in_progress').length;
    final overdueTasks = _tasks.where((t) => t.isOverdue).length;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    AppLocalizations.of(context).translate('pending'),
                    pendingTasks.toString(),
                    Icons.pending,
                    const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    AppLocalizations.of(context).translate('in_progress'),
                    inProgressTasks.toString(),
                    Icons.autorenew,
                    const Color(0xFF137fec),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    AppLocalizations.of(context).translate('overdue'),
                    overdueTasks.toString(),
                    Icons.error_outline,
                    const Color(0xFFFF4D4D),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? Center(
                    child: Text(
                      'No maintenance tasks',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      return _buildTaskCard(_tasks[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(MaintenanceTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2733),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isOverdue
              ? const Color(0xFFFF4D4D)
              : const Color(0xFF2D3748),
          width: task.isOverdue ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: task.priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.priority.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: task.priorityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.description,
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                '${task.scheduledDate.day}/${task.scheduledDate.month}/${task.scheduledDate.year}',
                style: TextStyle(
                  fontSize: 12,
                  color: task.isOverdue
                      ? const Color(0xFFFF4D4D)
                      : Colors.grey[400],
                  fontWeight:
                      task.isOverdue ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (task.isOverdue) ...[
                const SizedBox(width: 8),
                const Text(
                  'OVERDUE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF4D4D),
                  ),
                ),
              ],
              const Spacer(),
              Icon(Icons.person, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                task.assignedTo,
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: task.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      task.status.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: task.statusColor,
                      ),
                    ),
                  ),
                ),
              ),
              if (task.status != 'completed') ...[
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                  color: const Color(0xFF1B2733),
                  onSelected: (value) => _updateTaskStatus(task, value),
                  itemBuilder: (context) => [
                    if (task.status != 'in_progress')
                      const PopupMenuItem(
                        value: 'in_progress',
                        child: Text(
                          'Mark In Progress',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'completed',
                      child: Text(
                        'Mark Completed',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}


