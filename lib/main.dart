import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/history_screen.dart';
import 'screens/shift_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/attendance_service.dart';
import 'services/anomaly_detection_service.dart';
import 'services/notification_scheduler.dart';
import 'providers/app_state.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationScheduler.instance.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<LocationService>(create: (_) => LocationService()),
        Provider<AttendanceService>(
          create: (context) => AttendanceService(context.read<LocationService>()),
        ),
        Provider<AnomalyDetectionService>(create: (_) => AnomalyDetectionService()),
        ChangeNotifierProvider<AppState>(
          create: (context) => AppState(
            authService: context.read<AuthService>(),
            attendanceService: context.read<AttendanceService>(),
            anomalyService: context.read<AnomalyDetectionService>(),
          ),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          const seed = Color(0xFF10B981);

          final lightTheme = ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seed,
              primary: seed,
              secondary: const Color(0xFF059669),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            cardTheme: CardTheme(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            dividerTheme: DividerThemeData(color: Colors.grey.shade300),
            textTheme: GoogleFonts.interTextTheme(),
            appBarTheme: AppBarTheme(
              centerTitle: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E293B),
              titleTextStyle: GoogleFonts.inter(
                color: const Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: seed,
              unselectedItemColor: Colors.grey.shade600,
              type: BottomNavigationBarType.fixed,
              elevation: 8,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: seed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          );

          final darkTheme = ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seed,
              primary: seed,
              secondary: const Color(0xFF34D399),
              brightness: Brightness.dark,
              surface: const Color(0xFF1E1E1E),
              onSurface: const Color(0xFFE2E8F0),
              surfaceContainerHighest: const Color(0xFF2D3748),
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardTheme: CardTheme(
              color: const Color(0xFF1E1E1E),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            dividerTheme: DividerThemeData(color: Colors.grey.shade700),
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
              bodyColor: const Color(0xFFE2E8F0),
              displayColor: const Color(0xFFE2E8F0),
            ),
            appBarTheme: AppBarTheme(
              centerTitle: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: const Color(0xFF1E1E1E),
              foregroundColor: const Color(0xFFE2E8F0),
              titleTextStyle: GoogleFonts.inter(
                color: const Color(0xFFE2E8F0),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: const Color(0xFF1E1E1E),
              selectedItemColor: seed,
              unselectedItemColor: Colors.grey.shade500,
              type: BottomNavigationBarType.fixed,
              elevation: 8,
            ),
            drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF1E1E1E)),
            listTileTheme: ListTileThemeData(
              iconColor: const Color(0xFFE2E8F0),
              textColor: const Color(0xFFE2E8F0),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: seed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith((s) {
                if (s.contains(WidgetState.selected)) return seed;
                return Colors.grey;
              }),
              trackColor: WidgetStateProperty.resolveWith((s) {
                if (s.contains(WidgetState.selected)) return seed.withValues(alpha: 0.35);
                return Colors.grey.withValues(alpha: 0.35);
              }),
            ),
          );

          return MaterialApp(
            title: 'Employee Attendance System',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/history': (context) => const HistoryScreen(),
              '/shift': (context) => const ShiftScreen(),
              '/admin': (context) => const AdminDashboardScreen(),
            },
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final isLoggedIn = await context.read<AuthService>().isLoggedIn();
    if (mounted) {
      if (isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 80, color: cs.primary),
            const SizedBox(height: 24),
            Text(
              l10n.appTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.appSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
