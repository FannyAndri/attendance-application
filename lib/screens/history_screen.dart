import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Attendance History'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          final present = index % 3 != 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: present ? const Color(0xFF22C55E).withValues(alpha: 0.15) : cs.error.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  present ? Icons.check_circle_outline : Icons.cancel_outlined,
                  color: present ? const Color(0xFF22C55E) : cs.error,
                ),
              ),
              title: Text(
                'Day ${30 - index} April 2026',
                style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
              ),
              subtitle: Text(
                present ? 'Check-in: 08:30 AM • Checkout: 05:00 PM' : 'Absent',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ),
          );
        },
      ),
    );
  }
}
