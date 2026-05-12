import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:uuid/uuid.dart';
import 'package:fit_tracker/src/features/fitness/data/models/fitness_models.dart';
import 'package:flutter_animate/flutter_animate.dart';

final locationProvider = StreamProvider<LatLng>((ref) {
  return Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  ).map((pos) => LatLng(pos.latitude, pos.longitude));
});

class MapWorkoutScreen extends ConsumerStatefulWidget {
  const MapWorkoutScreen({super.key});

  @override
  ConsumerState<MapWorkoutScreen> createState() => _MapWorkoutScreenState();
}

class _MapWorkoutScreenState extends ConsumerState<MapWorkoutScreen> {
  final MapController _mapController = MapController();
  final List<LatLng> _routePoints = [];
  bool _isTracking = false;
  double _distanceKm = 0;
  int _currentSteps = 0;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services')),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission permanently denied')),
        );
      }
    }
  }

  void _startTracking() {
    setState(() {
      _isTracking = true;
      _routePoints.clear();
      _elapsedSeconds = 0;
      _distanceKm = 0;
      _currentSteps = 0;
    });

    Geolocator.getCurrentPosition().then((pos) {
      if (mounted) {
        setState(() {
          _routePoints.add(LatLng(pos.latitude, pos.longitude));
        });
      }
    });
  }

  void _stopTracking() {
    setState(() => _isTracking = false);
  }

  void _onLocationUpdate(LatLng loc) {
    if (!_isTracking) return;
    setState(() {
      if (_routePoints.length > 1) {
        final last = _routePoints.last;
        _distanceKm += Geolocator.distanceBetween(
          last.latitude, last.longitude,
          loc.latitude, loc.longitude,
        ) / 1000;
      }
      _routePoints.add(loc);
    });
  }

  Future<void> _saveWorkout() async {
    if (_routePoints.isEmpty) return;

    final calories = (_elapsedSeconds / 60 * 8).round();
    final duration = (_elapsedSeconds / 60).ceil();
    final steps = (_distanceKm * 1250).round();

    final activity = ActivityModel(
      id: const Uuid().v4(),
      type: 'Outdoor Run',
      durationMinutes: duration,
      caloriesBurned: calories.toDouble(),
      steps: steps,
      date: DateTime.now(),
      notes: 'GPS tracked workout - ${(_distanceKm * 1000).toInt()}m',
    );

    await ref.read(fitnessRepoProvider).saveActivity(activity);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Workout saved! $calories cal, $duration min'),
          backgroundColor: FitColors.neonGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: FitColors.background,
      body: Stack(
        children: [
          RepaintBoundary(
            child: locationAsync.when(
              data: (loc) {
                _onLocationUpdate(loc);
                return _RouteMap(
                  mapController: _mapController,
                  routePoints: _routePoints,
                  currentLocation: loc,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off, color: FitColors.textMuted, size: 48),
                    SizedBox(height: 16.h),
                    const Text('Location unavailable', style: TextStyle(color: FitColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RoundButton(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: FitColors.textPrimary),
                      ),
                      _StatusBadge(isTracking: _isTracking),
                    ],
                  ),
                ),
                const Spacer(),
                _WorkoutStatsPanel(
                  isTracking: _isTracking,
                  distanceKm: _distanceKm,
                  currentSteps: _currentSteps,
                  elapsedSeconds: _elapsedSeconds,
                  hasRoutePoints: _routePoints.isNotEmpty,
                  onStart: _startTracking,
                  onStop: _stopTracking,
                  onSave: _saveWorkout,
                  onElapsedTick: () => setState(() => _elapsedSeconds++),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteMap extends StatelessWidget {
  const _RouteMap({
    required this.mapController,
    required this.routePoints,
    required this.currentLocation,
  });

  final MapController mapController;
  final List<LatLng> routePoints;
  final LatLng currentLocation;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentLocation,
        initialZoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.fit_tracker.app',
        ),
        if (routePoints.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                color: FitColors.neonGreen,
                strokeWidth: 4,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (routePoints.isNotEmpty)
              Marker(
                point: routePoints.first,
                width: 30,
                height: 30,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: FitColors.neonGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
                ),
              ),
            if (routePoints.isNotEmpty)
              Marker(
                point: routePoints.last,
                width: 30,
                height: 30,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: FitColors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.location_on, color: Colors.white, size: 18),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _WorkoutStatsPanel extends StatefulWidget {
  const _WorkoutStatsPanel({
    required this.isTracking,
    required this.distanceKm,
    required this.currentSteps,
    required this.elapsedSeconds,
    required this.hasRoutePoints,
    required this.onStart,
    required this.onStop,
    required this.onSave,
    required this.onElapsedTick,
  });

  final bool isTracking;
  final double distanceKm;
  final int currentSteps;
  final int elapsedSeconds;
  final bool hasRoutePoints;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onSave;
  final VoidCallback onElapsedTick;

  @override
  State<_WorkoutStatsPanel> createState() => _WorkoutStatsPanelState();
}

class _WorkoutStatsPanelState extends State<_WorkoutStatsPanel> {
  Timer? _timer;

  @override
  void didUpdateWidget(_WorkoutStatsPanel old) {
    super.didUpdateWidget(old);
    if (widget.isTracking && !old.isTracking) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        widget.onElapsedTick();
      });
    } else if (!widget.isTracking && old.isTracking) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: FitColors.card.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: FitColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Duration', value: _formatDuration(widget.elapsedSeconds), icon: Icons.timer_rounded),
              _StatItem(label: 'Distance', value: '${widget.distanceKm.toStringAsFixed(2)} km', icon: Icons.straighten_rounded),
              _StatItem(label: 'Steps', value: widget.currentSteps.toString(), icon: Icons.directions_walk_rounded),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: widget.isTracking ? widget.onStop : widget.onStart,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: widget.isTracking ? FitColors.orange : FitColors.neonGreen,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        widget.isTracking ? 'Stop' : 'Start',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.hasRoutePoints && !widget.isTracking) ...[
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onSave,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: FitColors.blue,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: FitColors.card.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: IconButton(
        icon: child,
        onPressed: onTap,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isTracking});
  final bool isTracking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isTracking ? FitColors.neonGreen : FitColors.card.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        isTracking ? 'Recording' : 'Ready',
        style: TextStyle(
          color: isTracking ? Colors.white : FitColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: FitColors.neonGreen, size: 20.sp),
      SizedBox(height: 4.h),
      Text(value, style: TextStyle(color: FitColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w700)),
      Text(label, style: TextStyle(color: FitColors.textSecondary, fontSize: 11.sp)),
    ],
  );
}
