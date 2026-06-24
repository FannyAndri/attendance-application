import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final dept = user?.department.trim();
    final deptDisplay = (dept != null && dept.isNotEmpty) ? dept : l10n.profileDeptUnknown;
    final roleStr = user?.role;
    final roleDisplay = (roleStr != null && roleStr.trim().isNotEmpty) ? roleStr : l10n.profileRoleEmployee;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.profileTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: cs.primary.withValues(alpha: 0.2),
              child: Text(
                (user?.name ?? 'U')[0].toUpperCase(),
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: cs.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text(user?.name ?? 'Employee', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text(user?.email ?? '', style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 32),
            _buildInfoCard(context, [
              _buildInfoRow(context, Icons.badge_outlined, l10n.locale.languageCode == 'id' ? 'Nama lengkap' : 'Full Name', user?.name ?? '-'),
              _buildInfoRow(context, Icons.email_outlined, 'Email', user?.email ?? '-'),
              _buildInfoRow(context, Icons.business_outlined, l10n.locale.languageCode == 'id' ? 'Departemen' : 'Department', deptDisplay),
              _buildInfoRow(context, Icons.work_outline, l10n.locale.languageCode == 'id' ? 'Peran' : 'Role', roleDisplay),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cs.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
