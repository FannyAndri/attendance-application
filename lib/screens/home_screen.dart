import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import 'attendance_screen.dart';
import 'wfh_screen.dart';
import 'anomaly_screen.dart';
import 'tracking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().initializeUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    final pages = [
      const AttendanceScreen(),
      const WFHScreen(),
      const TrackingScreen(),
      const AnomalyScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.employeePortal),
        actions: [
          Consumer<AppState>(
            builder: (context, appState, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 16, color: cs.primary),
                        const SizedBox(width: 4),
                        Text(
                          appState.currentUser?.name ?? 'User',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        indicatorColor: cs.primary.withValues(alpha: 0.2),
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.fingerprint_outlined), selectedIcon: const Icon(Icons.fingerprint), label: l10n.navAttendance),
          NavigationDestination(icon: const Icon(Icons.home_work_outlined), selectedIcon: const Icon(Icons.home_work), label: l10n.navWfh),
          NavigationDestination(icon: const Icon(Icons.location_on_outlined), selectedIcon: const Icon(Icons.location_on), label: l10n.navTracking),
          NavigationDestination(icon: const Icon(Icons.analytics_outlined), selectedIcon: const Icon(Icons.analytics), label: l10n.navAnomalies),
        ],
      ),
      drawer: _buildDrawer(context, l10n, cs),
    );
  }

  Widget _buildDrawer(BuildContext context, AppLocalizations l10n, ColorScheme cs) {
    return Drawer(
      backgroundColor: Theme.of(context).drawerTheme.backgroundColor ?? Theme.of(context).cardTheme.color,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: cs.primary,
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?q=80&w=600'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
              ),
            ),
            child: Consumer<AppState>(
              builder: (context, appState, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Text(
                        (appState.currentUser?.name ?? 'U')[0].toUpperCase(),
                        style: TextStyle(fontSize: 28, color: cs.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      appState.currentUser?.name ?? 'Employee',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      appState.currentUser?.email ?? '',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                );
              },
            ),
          ),
          _buildDrawerItem(context, icon: Icons.schedule_outlined, title: l10n.drawerShift, onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/shift');
          }),
          _buildDrawerItem(context, icon: Icons.history_outlined, title: l10n.drawerHistory, onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/history');
          }),
          _buildDrawerItem(context, icon: Icons.settings_outlined, title: l10n.drawerSettings, onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/settings');
          }),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.logout_outlined,
            title: l10n.drawerLogout,
            isDestructive: true,
            onTap: () async {
              Navigator.pop(context);
              await context.read<AppState>().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final fg = isDestructive ? cs.error : cs.onSurface;
    return ListTile(
      leading: Icon(icon, color: fg),
      title: Text(title, style: TextStyle(color: fg, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
