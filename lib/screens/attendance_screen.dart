import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        appState.isCheckedIn
                            ? Icons.check_circle
                            : Icons.logout,
                        size: 48,
                        color: appState.isCheckedIn
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        appState.isCheckedIn
                            ? 'Checked In'
                            : 'Checked Out',
                        style:
                            Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        appState.todayDuration,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Check-in/Check-out Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          appState.isCheckedIn ? null : _handleCheckIn,
                      icon: const Icon(Icons.login),
                      label: const Text('Check In'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: appState.isCheckedIn
                            ? Theme.of(context).colorScheme.surfaceContainerHighest
                            : const Color(0xFF16A34A),
                        foregroundColor: appState.isCheckedIn
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          appState.isCheckedIn ? _handleCheckOut : null,
                      icon: const Icon(Icons.logout),
                      label: const Text('Check Out'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: appState.isCheckedIn
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        foregroundColor: appState.isCheckedIn
                            ? Theme.of(context).colorScheme.onError
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Today's Record
              Text(
                "Today's Record",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (appState.todayRecord != null)
                _buildRecordCard(context, appState.todayRecord!)
              else
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'No attendance record for today',
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecordCard(
      BuildContext context,
      dynamic record,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecordRow(
              'Status',
              record.status.toUpperCase(),
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildRecordRow(
              'Check-in',
              '${record.checkInTime.hour}:${record.checkInTime.minute.toString().padLeft(2, "0")}',
              Colors.green,
            ),
            if (record.checkOutTime != null) ...[    
              const SizedBox(height: 12),
              _buildRecordRow(
                'Check-out',
                '${record.checkOutTime.hour}:${record.checkOutTime.minute.toString().padLeft(2, "0")}',
                Colors.red,
              ),
            ],
            const SizedBox(height: 12),
            _buildRecordRow(
              'Duration',
              record.getFormattedDuration(),
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordRow(
      String label,
      String value,
      Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color),
          ),
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Future<void> _handleCheckIn() async {
    final appState = context.read<AppState>();
    
    try {
      final success = await appState.performCheckIn(null);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Checked in successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Check-in failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        // Clear Exception: prefix if present
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _handleCheckOut() async {
    final appState = context.read<AppState>();
    final success = await appState.performCheckOut();

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checked out successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-out failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

