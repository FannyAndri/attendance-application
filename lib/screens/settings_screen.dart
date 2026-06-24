import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'profile_screen.dart';
import 'change_password_screen.dart';
import 'notification_settings_screen.dart';
import 'appearance_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsCard(
            context,
            title: l10n.settingsSectionAccount,
            children: [
              _buildSettingItem(
                context,
                Icons.person_outline,
                l10n.settingsProfile,
                subtitle: l10n.settingsProfileSubtitle,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              ),
              Divider(height: 0, indent: 56, color: Theme.of(context).dividerTheme.color),
              _buildSettingItem(
                context,
                Icons.lock_outline,
                l10n.settingsPassword,
                subtitle: l10n.settingsPasswordSubtitle,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsCard(
            context,
            title: l10n.settingsSectionPrefs,
            children: [
              _buildSettingItem(
                context,
                Icons.notifications_outlined,
                l10n.settingsNotifications,
                subtitle: l10n.settingsNotificationsSubtitle,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())),
              ),
              Divider(height: 0, indent: 56, color: Theme.of(context).dividerTheme.color),
              _buildSettingItem(
                context,
                Icons.palette_outlined,
                l10n.settingsAppearance,
                subtitle: l10n.settingsAppearanceSubtitle,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppearanceSettingsScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required String title, required List<Widget> children}) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title, {
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: cs.primary, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: cs.onSurface)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant))
          : null,
      trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
