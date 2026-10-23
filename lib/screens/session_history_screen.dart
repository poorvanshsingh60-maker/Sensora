import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/sensor_controller.dart';
import '../models/session_model.dart';
import '../services/export_service.dart';

class SessionHistoryScreen extends StatelessWidget {
  const SessionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SensorController controller = Get.find<SensorController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => controller.loadSessions(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingSessions.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.sessions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off_rounded,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Recorded Sessions Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start recording from the Sensor Dashboard to capture, analyze, and export physical sensor telemetry.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadSessions(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.sessions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final session = controller.sessions[index];
              return _SessionCard(
                session: session,
                onDelete: () => _confirmDelete(context, controller, session),
                onExportCsv: () => _export(context, controller, session, 'CSV'),
                onExportJson: () => _export(context, controller, session, 'JSON'),
              );
            },
          ),
        );
      }),
    );
  }

  void _confirmDelete(
    BuildContext context,
    SensorController controller,
    SessionModel session,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Session?'),
        content: Text(
          'Are you sure you want to permanently delete "${session.title}" and its ${session.sampleCount} recorded data points?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              if (session.id != null) {
                controller.deleteSession(session.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Session deleted successfully')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _export(
    BuildContext context,
    SensorController controller,
    SessionModel session,
    String format,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting session as $format...'),
        duration: const Duration(seconds: 1),
      ),
    );

    final ExportResult result = format == 'CSV'
        ? await controller.exportCsv(session)
        : await controller.exportJson(session);

    if (!context.mounted) return;

    if (result.success) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green),
              const SizedBox(width: 8),
              Text('$format Export Successful'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${result.recordCount} samples exported to your device storage:',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  result.filePath,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Export failed: ${result.errorMessage}'),
        ),
      );
    }
  }
}

class _SessionCard extends StatelessWidget {
  final SessionModel session;
  final VoidCallback onDelete;
  final VoidCallback onExportCsv;
  final VoidCallback onExportJson;

  const _SessionCard({
    required this.session,
    required this.onDelete,
    required this.onExportCsv,
    required this.onExportJson,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm:ss');
    final formattedDate = dateFormat.format(session.startTime);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Delete
            Row(
              children: [
                Expanded(
                  child: Text(
                    session.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: 'Delete Session',
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 14),

            // Metadata Badges (Duration, Samples)
            Row(
              children: [
                _buildBadge(
                  icon: Icons.timer_outlined,
                  label: session.formattedDuration,
                  color: Colors.blue.shade50,
                  textColor: Colors.blue.shade900,
                ),
                const SizedBox(width: 10),
                _buildBadge(
                  icon: Icons.data_usage_rounded,
                  label: '${session.sampleCount} points',
                  color: Colors.purple.shade50,
                  textColor: Colors.purple.shade900,
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Export Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onExportCsv,
                  icon: const Icon(Icons.table_chart_outlined, size: 18),
                  label: const Text('Export CSV'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: onExportJson,
                  icon: const Icon(Icons.code_rounded, size: 18),
                  label: const Text('Export JSON'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
