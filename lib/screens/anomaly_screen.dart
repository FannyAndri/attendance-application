import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class AnomalyScreen extends StatefulWidget {
  const AnomalyScreen({super.key});

  @override
  State<AnomalyScreen> createState() => _AnomalyScreenState();
}

class _AnomalyScreenState extends State<AnomalyScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final anomalies = appState.anomalyReports;
        final pendingAnomalies =
            anomalies.where((a) => a.isPending()).toList();
        final reviewedAnomalies =
            anomalies.where((a) => a.isReviewed()).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Anomaly Detection',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Total Anomalies',
                      anomalies.length.toString(),
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Pending',
                      pendingAnomalies.length.toString(),
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Reviewed',
                      reviewedAnomalies.length.toString(),
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Pending Anomalies
              if (pendingAnomalies.isNotEmpty) ...[                
                Text(
                  'Pending Review',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pendingAnomalies.length,
                  itemBuilder: (context, index) {
                    final anomaly = pendingAnomalies[index];
                    return _buildAnomalyCard(context, anomaly);
                  },
                ),
                const SizedBox(height: 24),
              ],
              // Reviewed Anomalies
              if (reviewedAnomalies.isNotEmpty) ...[                
                Text(
                  'Reviewed',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviewedAnomalies.length,
                  itemBuilder: (context, index) {
                    final anomaly = reviewedAnomalies[index];
                    return _buildAnomalyCard(context, anomaly);
                  },
                ),
              ],
              if (anomalies.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'No anomalies detected',
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnomalyCard(
    BuildContext context,
    dynamic anomaly,
  ) {
    final severityColor = _getSeverityColor(anomaly.severity);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  anomaly.type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: severityColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    anomaly.getSeverityLabel(),
                    style: TextStyle(
                      fontSize: 12,
                      color: severityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              anomaly.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Detected: ${anomaly.detectedAt.hour}:${anomaly.detectedAt.minute.toString().padLeft(2, "0")}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(double severity) {
    if (severity >= 0.8) return Colors.red;
    if (severity >= 0.6) return Colors.orange;
    if (severity >= 0.4) return Colors.amber;
    return Colors.yellow;
  }
}

