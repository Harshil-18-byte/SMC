import 'package:flutter/material.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/models/audit_log_model.dart';

/// System Audit Logs Screen
/// The "Source of Truth" - filterable logs with old/new value comparison
class SystemAuditLogsScreen extends StatefulWidget {
  const SystemAuditLogsScreen({super.key});

  @override
  State<SystemAuditLogsScreen> createState() => _SystemAuditLogsScreenState();
}

class _SystemAuditLogsScreenState extends State<SystemAuditLogsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _searchController = TextEditingController();

  bool _isLoading = true;
  List<AuditLogEntry> _logs = [];
  List<AuditLogEntry> _filteredLogs = [];

  String _filterAction = 'All';
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _actionTypes = [
    'All',
    'USER_SUSPENDED',
    'ROLE_CHANGED',
    'INTAKE_LOCKED',
    'EMERGENCY_ALERT_BROADCAST',
    'REPLENISHMENT_APPROVED',
  ];

  @override
  void initState() {
    super.initState();
    _loadAuditLogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAuditLogs() async {
    setState(() => _isLoading = true);

    try {
      final logsData = await _firestoreService.getCollection(
        collection: 'audit_logs',
        orderBy: 'timestamp',
        descending: true,
        limit: 100,
      );
      _logs = logsData
          .map((data) => AuditLogEntry.fromMap(data, data['id']))
          .toList();

      _applyFilters();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading logs: $e')));
      }
    }
  }

  void _applyFilters() {
    var filtered = _logs;

    // Filter by action type
    if (_filterAction != 'All') {
      filtered = filtered.where((log) => log.action == _filterAction).toList();
    }

    // Filter by date range
    if (_startDate != null) {
      filtered =
          filtered.where((log) => log.timestamp.isAfter(_startDate!)).toList();
    }
    if (_endDate != null) {
      filtered =
          filtered.where((log) => log.timestamp.isBefore(_endDate!)).toList();
    }

    // Filter by search query
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((log) {
        return log.actorId.toLowerCase().contains(query) ||
            log.actorName.toLowerCase().contains(query) ||
            log.action.toLowerCase().contains(query);
      }).toList();
    }

    setState(() => _filteredLogs = filtered);
  }

  void _showLogDetails(AuditLogEntry log) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AuditLogDetailsSheet(log: log),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101922),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101922),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Audit Logs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'SOURCE OF TRUTH',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF137fec),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAuditLogs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(),
                _buildFilters(),
                _buildSummary(),
                Expanded(child: _buildLogsList()),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2733),
        border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search by Actor ID, Name, or Action...',
          hintStyle: TextStyle(color: Colors.grey[600]),
          filled: true,
          fillColor: const Color(0xFF101922),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2D3748)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2D3748)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF137fec)),
          ),
        ),
        onChanged: (value) => _applyFilters(),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2733),
        border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FILTERS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _filterAction,
            decoration: InputDecoration(
              labelText: 'Action Type',
              labelStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
              filled: true,
              fillColor: const Color(0xFF101922),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2D3748)),
              ),
            ),
            dropdownColor: const Color(0xFF1B2733),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            items: _actionTypes.map((action) {
              return DropdownMenuItem(value: action, child: Text(action));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _filterAction = value);
                _applyFilters();
              }
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _startDate = date);
                      _applyFilters();
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _startDate != null
                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                        : 'Start Date',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[400],
                    side: BorderSide(color: Colors.grey[700]!),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _endDate = date);
                      _applyFilters();
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _endDate != null
                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : 'End Date',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[400],
                    side: BorderSide(color: Colors.grey[700]!),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text(
            'Showing ${_filteredLogs.length} of ${_logs.length} log entries',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList() {
    if (_filteredLogs.isEmpty) {
      return Center(
        child: Text(
          'No audit logs found',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAuditLogs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredLogs.length,
        itemBuilder: (context, index) {
          return _buildLogCard(_filteredLogs[index]);
        },
      ),
    );
  }

  Widget _buildLogCard(AuditLogEntry log) {
    return GestureDetector(
      onTap: () => _showLogDetails(log),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2733),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2D3748)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: log.actionColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(log.actionIcon, color: log.actionColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.action.replaceAll('_', ' '),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By ${log.actorName}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                Text(
                  log.getFormattedTimestamp(),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
            if (log.metadata.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF101922),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: log.metadata.entries.take(2).map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text(
                            '${entry.key}: ',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value.toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Audit Log Details Bottom Sheet
class AuditLogDetailsSheet extends StatelessWidget {
  final AuditLogEntry log;

  const AuditLogDetailsSheet({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF1B2733),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: log.actionColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(log.actionIcon, color: log.actionColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.action.replaceAll('_', ' '),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        log.getFullTimestamp(),
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Actor Information', [
                    _buildDetailRow('Actor ID', log.actorId),
                    _buildDetailRow('Actor Name', log.actorName),
                  ]),
                  const SizedBox(height: 24),
                  if (log.oldValue != null || log.newValue != null) ...[
                    _buildSection('Change Comparison', [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (log.oldValue != null)
                            Expanded(
                              child: _buildValueCard(
                                'Old Value',
                                log.oldValue!,
                                const Color(0xFFFF4D4D),
                              ),
                            ),
                          if (log.oldValue != null && log.newValue != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.grey[600],
                              ),
                            ),
                          if (log.newValue != null)
                            Expanded(
                              child: _buildValueCard(
                                'New Value',
                                log.newValue!,
                                const Color(0xFF10B981),
                              ),
                            ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 24),
                  ],
                  if (log.metadata.isNotEmpty)
                    _buildSection('Additional Metadata', [
                      ...log.metadata.entries.map((entry) {
                        return _buildDetailRow(
                          entry.key,
                          entry.value.toString(),
                        );
                      }),
                    ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard(
    String label,
    Map<String, dynamic> value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          ...value.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${entry.key}: ${entry.value}',
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
            );
          }),
        ],
      ),
    );
  }
}


