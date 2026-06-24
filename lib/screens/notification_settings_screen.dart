import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../services/notification_scheduler.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  Future<void> _applyToggle(BuildContext context, Future<void> Function(bool) setter, bool v) async {
    if (v) {
      final granted = await NotificationScheduler.instance.ensureNotifyPermission();
      if (!context.mounted) return;
      if (!granted) {
        final id = AppLocalizations.of(context).locale.languageCode == 'id';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(id ? 'Izin notifikasi ditolak.' : 'Notification permission denied.'),
          ),
        );
        return;
      }
    }
    await setter(v);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(context, l10n.notifSectionAttendance, [
            _buildToggle(
              context,
              l10n.notifCheckInTitle,
              l10n.notifCheckInSubtitle,
              Icons.login,
              settings.notifCheckIn,
              (v) => _applyToggle(context, settings.setNotifCheckIn, v),
            ),
            Divider(height: 0, indent: 70, color: Theme.of(context).dividerTheme.color),
            _buildToggle(
              context,
              l10n.notifCheckOutTitle,
              l10n.notifCheckOutSubtitle,
              Icons.logout,
              settings.notifCheckOut,
              (v) => _applyToggle(context, settings.setNotifCheckOut, v),
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection(context, l10n.notifSectionRequests, [
            _buildToggle(
              context,
              l10n.notifWfhTitle,
              l10n.notifWfhSubtitle,
              Icons.home_work_outlined,
              settings.notifWfh,
              (v) => _applyToggle(context, settings.setNotifWfh, v),
            ),
            Divider(height: 0, indent: 70, color: Theme.of(context).dividerTheme.color),
            _buildToggle(
              context,
              l10n.notifOtTitle,
              l10n.notifOtSubtitle,
              Icons.schedule,
              settings.notifOvertime,
              (v) => _applyToggle(context, settings.setNotifOvertime, v),
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection(context, l10n.notifSectionSecurity, [
            _buildToggle(
              context,
              l10n.notifAnomalyTitle,
              l10n.notifAnomalySubtitle,
              Icons.warning_amber_outlined,
              settings.notifAnomaly,
              (v) => _applyToggle(context, settings.setNotifAnomaly, v),
            ),
          ]),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await NotificationScheduler.instance.ensureNotifyPermission();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.locale.languageCode == 'id' ? 'Permintaan izin dikirim ke sistem.' : 'Permission request sent to the system.')),
                  );
                },
                icon: const Icon(Icons.notifications_active_outlined),
                label: Text(l10n.notifPermissionButton),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: cs.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.notifInfoBanner, style: TextStyle(color: cs.onSurface, fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: cs.primary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildToggle(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Future<void> Function(bool) onChanged,
  ) {
    final cs = Theme.of(context).colorScheme;
    return SwitchListTile(
      secondary: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: cs.primary, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: cs.onSurface)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
      value: value,
      onChanged: (v) => onChanged(v),
    );
  }
}
