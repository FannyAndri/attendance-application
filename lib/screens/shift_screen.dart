import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  List<Map<String, dynamic>> _overtimeRequests = [];
  bool _loadingRequests = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOvertimeRequests());
  }

  Future<void> _loadOvertimeRequests() async {
    final appState = context.read<AppState>();
    if (appState.currentUser == null) return;
    setState(() => _loadingRequests = true);
    final requests = await appState.attendanceService.getMyRequests(appState.currentUser!.id);
    if (mounted) {
      setState(() {
        _overtimeRequests = requests.where((r) => r['type'] == 'Overtime').toList();
        _loadingRequests = false;
      });
    }
  }

  Future<void> _handleOvertimeRequest() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (selectedDate == null) return;
    if (!mounted) return;

    final appState = context.read<AppState>();
    if (appState.currentUser == null) return;

    final dateStr = selectedDate.toIso8601String().split('T')[0];
    final success = await appState.attendanceService.submitRequest(
      appState.currentUser!.id,
      'Overtime',
      dateStr,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Overtime request submitted!'), backgroundColor: Colors.green),
      );
      _loadOvertimeRequests();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit overtime request'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Shift & Overtime'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildShiftCard(context),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overtime Requests',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: cs.primary),
                  onPressed: _loadOvertimeRequests,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _loadingRequests
                ? const Center(child: CircularProgressIndicator())
                : _overtimeRequests.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color ?? cs.surfaceContainerHighest,
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'No overtime requests yet. Tap the button below to request.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
                        ),
                      )
                    : Column(
                        children: _overtimeRequests.map((r) => _buildOvertimeCard(context, r)).toList(),
                      ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleOvertimeRequest,
        icon: const Icon(Icons.add),
        label: const Text('Request Overtime'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
    );
  }

  Widget _buildShiftCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: cs.primary.withValues(alpha: 0.35), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Shift Pattern',
            style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.85), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Morning Shift (M1)',
            style: TextStyle(color: cs.onPrimary, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShiftTime(cs, 'Check In', '08:00 AM'),
              _buildShiftTime(cs, 'Check Out', '05:00 PM'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShiftTime(ColorScheme cs, String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.85), fontSize: 12)),
        const SizedBox(height: 4),
        Text(time, style: TextStyle(color: cs.onPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildOvertimeCard(BuildContext context, Map<String, dynamic> req) {
    final cs = Theme.of(context).colorScheme;
    final surfaceCard = Theme.of(context).cardTheme.color ?? cs.surfaceContainerHighest;

    final status = req['status'] ?? 'Pending';
    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'Approved':
        statusColor = const Color(0xFF22C55E);
        statusIcon = Icons.check_circle_outline;
        break;
      case 'Rejected':
        statusColor = cs.error;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.hourglass_empty;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.06),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${req['date'] ?? ''}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  'Overtime Request',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
