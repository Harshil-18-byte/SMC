import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smc/data/services/realtime_sync_service.dart';

/// Sync status indicator widget
/// Shows real-time sync progress, bandwidth usage, and connection status
class SyncStatusIndicator extends StatelessWidget {
  final bool showDetails;
  final bool compact;
  final int? pendingCount; // Added optional count

  const SyncStatusIndicator({
    super.key,
    this.showDetails = false,
    this.compact = false,
    this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RealtimeSyncService>(
      builder: (context, syncService, child) {
        if (compact) {
          return _buildCompactIndicator(context, syncService);
        }

        return _buildFullIndicator(context, syncService);
      },
    );
  }

  /// Compact indicator for AppBar
  Widget _buildCompactIndicator(
    BuildContext context,
    RealtimeSyncService syncService,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showSyncDetails(context, syncService),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getStatusColor(syncService.syncStatus, isDark)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStatusColor(syncService.syncStatus, isDark)
                .withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(syncService),
            if ((pendingCount ?? syncService.pendingUploads) > 0) ...[
              const SizedBox(width: 6),
              Text(
                '${pendingCount ?? syncService.pendingUploads}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(syncService.syncStatus, isDark),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Full indicator for dashboard
  Widget _buildFullIndicator(
    BuildContext context,
    RealtimeSyncService syncService,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C242D) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatusIcon(syncService),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusTitle(syncService.syncStatus),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (syncService.syncMessage.isNotEmpty)
                      Text(
                        syncService.syncMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ),
              if (!syncService.isOnline)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'OFFLINE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
          if (syncService.syncStatus == SyncStatus.uploading) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: syncService.syncProgress,
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                color: theme.colorScheme.primary,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(syncService.syncProgress * 100).toStringAsFixed(0)}% complete',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
          if (showDetails) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              'Pending Uploads',
              '${syncService.pendingUploads}',
              Icons.upload_rounded,
            ),
            _buildDetailRow(
              context,
              'Failed Uploads',
              '${syncService.failedUploads}',
              Icons.error_outline_rounded,
            ),
            _buildDetailRow(
              context,
              'Bandwidth Used',
              syncService.bandwidthUsage,
              Icons.data_usage_rounded,
            ),
            if (syncService.lastSyncTime != null)
              _buildDetailRow(
                context,
                'Last Sync',
                _formatTime(syncService.lastSyncTime!),
                Icons.access_time_rounded,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(RealtimeSyncService syncService) {
    IconData icon;
    Color color;

    switch (syncService.syncStatus) {
      case SyncStatus.uploading:
      case SyncStatus.downloading:
        icon = Icons.sync_rounded;
        color = Colors.blue;
        break;
      case SyncStatus.success:
        icon = Icons.check_circle_rounded;
        color = Colors.green;
        break;
      case SyncStatus.error:
        icon = Icons.error_rounded;
        color = Colors.red;
        break;
      case SyncStatus.conflict:
        icon = Icons.warning_rounded;
        color = Colors.orange;
        break;
      default:
        icon = Icons.cloud_done_rounded;
        color = Colors.grey;
    }

    if (syncService.syncStatus == SyncStatus.uploading ||
        syncService.syncStatus == SyncStatus.downloading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    return Icon(icon, size: 20, color: color);
  }

  Color _getStatusColor(SyncStatus status, bool isDark) {
    switch (status) {
      case SyncStatus.uploading:
      case SyncStatus.downloading:
        return Colors.blue;
      case SyncStatus.success:
        return Colors.green;
      case SyncStatus.error:
        return Colors.red;
      case SyncStatus.conflict:
        return Colors.orange;
      default:
        return isDark ? Colors.grey[400]! : Colors.grey[600]!;
    }
  }

  String _getStatusTitle(SyncStatus status) {
    switch (status) {
      case SyncStatus.uploading:
        return 'Uploading...';
      case SyncStatus.downloading:
        return 'Downloading...';
      case SyncStatus.success:
        return 'Synced';
      case SyncStatus.error:
        return 'Sync Failed';
      case SyncStatus.conflict:
        return 'Conflict Detected';
      default:
        return 'Ready';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showSyncDetails(BuildContext context, RealtimeSyncService syncService) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SyncStatusIndicator(
                showDetails: true, pendingCount: pendingCount), // Updated
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


