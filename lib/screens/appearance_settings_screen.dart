import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final languages = ['English', 'Bahasa Indonesia'];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.appearanceTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(context, l10n.appearanceSectionTheme, [
            SwitchListTile(
              secondary: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.dark_mode_outlined, color: cs.primary, size: 20),
              ),
              title: Text(l10n.darkMode, style: TextStyle(fontWeight: FontWeight.w500, color: cs.onSurface)),
              subtitle: Text(
                settings.darkMode ? l10n.darkModeOn : l10n.darkModeOff,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              value: settings.darkMode,
              onChanged: (v) => settings.setDarkMode(v),
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection(context, l10n.appearanceSectionLang, [
            ...languages.map((lang) {
              return RadioListTile<String>(
                secondary: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text(lang == 'English' ? '🇺🇸' : '🇮🇩', style: const TextStyle(fontSize: 18))),
                ),
                title: Text(lang, style: TextStyle(fontWeight: FontWeight.w500, color: cs.onSurface)),
                value: lang,
                groupValue: settings.language,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return cs.primary;
                  return cs.onSurfaceVariant;
                }),
                onChanged: (v) {
                  if (v != null) {
                    settings.setLanguage(v);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.languageChanged(v))),
                    );
                  }
                },
              );
            }),
          ]),
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
}
