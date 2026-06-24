import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../services/attendance_service.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final MapController _mapController = MapController();
  Timer? _availabilityTimer;
  LocationAvailability _availability = LocationAvailability.allowed;
  bool _availabilityLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAvailability();
      _availabilityTimer = Timer.periodic(const Duration(seconds: 20), (_) => _refreshAvailability());
    });
  }

  @override
  void dispose() {
    _availabilityTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshAvailability() async {
    if (!mounted) return;
    final loc = context.read<LocationService>();
    final next = await loc.checkAvailability();
    if (!mounted) return;
    setState(() {
      _availability = next;
      _availabilityLoading = false;
    });
  }

  Future<void> _requestPermissionFromBanner() async {
    final loc = context.read<LocationService>();
    await loc.requestPermission();
    await _refreshAvailability();
  }

  Future<void> _openSettingsFromBanner() async {
    final loc = context.read<LocationService>();
    await loc.openAppLocationSettings();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await _refreshAvailability();
  }

  ({IconData icon, Color color, String message, String? actionLabel, VoidCallback? onAction}) _gpsBannerContent(
    BuildContext context,
    AppState appState,
    ColorScheme cs,
  ) {
    if (!appState.isCheckedIn) {
      return (
        icon: Icons.touch_app_outlined,
        color: cs.outline,
        message: 'Lokasi: menunggu check-in. Rekaman titik dimulai setelah Anda check-in.',
        actionLabel: null,
        onAction: null,
      );
    }

    if (_availabilityLoading) {
      return (
        icon: Icons.pending_outlined,
        color: cs.onSurfaceVariant,
        message: 'Memeriksa izin dan layanan lokasi…',
        actionLabel: null,
        onAction: null,
      );
    }

    switch (_availability) {
      case LocationAvailability.servicesDisabled:
        return (
          icon: Icons.location_disabled,
          color: cs.error,
          message: 'Layanan lokasi perangkat mati. Aktifkan GPS/lokasi di pengaturan sistem.',
          actionLabel: null,
          onAction: null,
        );
      case LocationAvailability.permissionDenied:
        return (
          icon: Icons.location_off_outlined,
          color: cs.error,
          message: 'Izin lokasi ditolak. Izinkan akses lokasi agar pelacakan bisa merekam titik.',
          actionLabel: 'Izinkan',
          onAction: _requestPermissionFromBanner,
        );
      case LocationAvailability.permissionDeniedForever:
        return (
          icon: Icons.block_flipped,
          color: cs.error,
          message: 'Izin lokasi diblokir permanen. Buka pengaturan aplikasi untuk mengaktifkannya.',
          actionLabel: 'Pengaturan',
          onAction: _openSettingsFromBanner,
        );
      case LocationAvailability.allowed:
        return (
          icon: Icons.gps_fixed,
          color: const Color(0xFF22C55E),
          message:
              'Lokasi siap. Titik dikirim berkala (~45 dtk) selama status check-in aktif. Pastikan GPS menyala.',
          actionLabel: null,
          onAction: null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileTemplate = isDark
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
        : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';

    return Consumer<AppState>(
      builder: (context, appState, _) {
        final gps = _gpsBannerContent(context, appState, cs);

        final locationTracks = appState.todayRecord?.locationTracks ?? [];
        final currentLocation = locationTracks.isNotEmpty
            ? LatLng(locationTracks.last.latitude, locationTracks.last.longitude)
            : const LatLng(-6.200000, 106.816666);

        final markers = locationTracks.map((track) {
          return Marker(
            point: LatLng(track.latitude, track.longitude),
            width: 40,
            height: 40,
            child: Icon(
              Icons.location_pin,
              color: track.isAnomalous ? cs.error : cs.primary,
              size: 40,
            ),
          );
        }).toList();

        final polyline = Polyline(
          points: locationTracks.map((e) => LatLng(e.latitude, e.longitude)).toList(),
          strokeWidth: 4,
          color: cs.primary.withValues(alpha: 0.55),
        );

        final panelBg = Theme.of(context).cardTheme.color ?? cs.surfaceContainerHighest;

        return Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: currentLocation,
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: tileTemplate,
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.example.flutter_application_1',
                      ),
                      PolylineLayer(
                        polylines: locationTracks.isEmpty ? <Polyline>[] : [polyline],
                      ),
                      MarkerLayer(
                        markers: markers,
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 4,
                    left: 4,
                    right: 4,
                    child: Text(
                      '© OpenStreetMap contributors © CARTO',
                      style: TextStyle(fontSize: 10, color: cs.onSurface.withValues(alpha: 0.55), shadows: const [
                        Shadow(color: Colors.black26, blurRadius: 4),
                      ]),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(12),
                      color: panelBg,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Tracking Status',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: cs.onSurface,
                                        ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: appState.isCheckedIn ? Colors.green.withValues(alpha: 0.18) : cs.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: appState.isCheckedIn ? Colors.green : cs.outline,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        appState.isCheckedIn ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          color: appState.isCheckedIn ? const Color(0xFF22C55E) : cs.onSurfaceVariant,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 20, color: cs.outlineVariant.withValues(alpha: 0.5)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(gps.icon, color: gps.color, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    gps.message,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: cs.onSurface,
                                          height: 1.35,
                                        ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Refresh status lokasi',
                                  onPressed: _refreshAvailability,
                                  icon: Icon(Icons.refresh, color: cs.primary),
                                ),
                              ],
                            ),
                            if (gps.actionLabel != null && gps.onAction != null)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 32),
                                  child: TextButton(
                                    onPressed: gps.onAction,
                                    child: Text(gps.actionLabel!),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 36,
                    right: 16,
                    child: FloatingActionButton.small(
                      backgroundColor: panelBg,
                      foregroundColor: cs.primary,
                      child: const Icon(Icons.my_location),
                      onPressed: () {
                        if (locationTracks.isNotEmpty) {
                          _mapController.move(currentLocation, 15.0);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Material(
                elevation: 8,
                color: panelBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.history, color: cs.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(
                            'Location History',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface),
                          ),
                          const Spacer(),
                          Text(
                            '${locationTracks.length} points',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: locationTracks.isEmpty
                          ? Center(
                              child: Text(
                                'No location tracks available',
                                style: TextStyle(color: cs.onSurfaceVariant),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: locationTracks.length,
                              itemBuilder: (context, index) {
                                final track = locationTracks.reversed.toList()[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: (track.isAnomalous ? cs.error : cs.primary).withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        track.isAnomalous ? Icons.warning_rounded : Icons.location_on_rounded,
                                        color: track.isAnomalous ? cs.error : cs.primary,
                                      ),
                                    ),
                                    title: Text(
                                      '${track.latitude.toStringAsFixed(5)}, ${track.longitude.toStringAsFixed(5)}',
                                      style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface),
                                    ),
                                    subtitle: Text(
                                      'Time: ${track.timestamp.hour.toString().padLeft(2, '0')}:${track.timestamp.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(color: cs.onSurfaceVariant),
                                    ),
                                    trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
