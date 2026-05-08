// ignore_for_file: deprecated_member_use, prefer_final_locals, prefer_const_constructors, use_decorated_box, unnecessary_brace_in_string_interps

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
  Timer? _timer;
  bool _isTracking = false;
  int _elapsedSeconds = 0;
  double _distanceKm = 0;
  int _currentSteps = 0;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
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

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });

    // Get initial position
    Geolocator.getCurrentPosition().then((pos) {
      if (mounted) {
        setState(() {
          _routePoints.add(LatLng(pos.latitude, pos.longitude));
        });
      }
    });
  }

  void _stopTracking() {
    _timer?.cancel();
    setState(() => _isTracking = false);
  }

  Future<void> _saveWorkout() async {
    if (_routePoints.isEmpty) return;

    final calories = (_elapsedSeconds / 60 * 8).round(); // ~8 cal/min
    final duration = (_elapsedSeconds / 60).ceil();
    final steps = (_distanceKm * 1250).round(); // ~1250 steps per km

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
          content: Text('Workout saved! ${calories} cal, ${duration} min'),
          backgroundColor: FitColors.neonGreen,
        ),
      );
      Navigator.pop(context);
    }
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: FitColors.background,
      body: Stack(
        children: [
          // Map
          locationAsync.when(
            data: (currentLocation) {
              if (_routePoints.isEmpty && _isTracking) {
                _routePoints.add(currentLocation);
              }
              
              // Calculate distance
              if (_routePoints.length > 1 && _isTracking) {
                final lastPoint = _routePoints.last;
                final distance = Geolocator.distanceBetween(
                  lastPoint.latitude,
                  lastPoint.longitude,
                  currentLocation.latitude,
                  currentLocation.longitude,
                ) / 1000;
                _distanceKm += distance;
                _routePoints.add(currentLocation);
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: currentLocation,
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.fit_tracker.app',
                  ),
                  if (_routePoints.length > 1)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          color: FitColors.neonGreen,
                          strokeWidth: 4,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      if (_routePoints.isNotEmpty)
                        Marker(
                          point: _routePoints.first,
                          width: 30,
                          height: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              color: FitColors.neonGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
                          ),
                        ),
                      if (_routePoints.isNotEmpty)
                        Marker(
                          point: _routePoints.last,
                          width: 30,
                          height: 30,
                          child: Container(
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
            },
            loading: () => const Center(child: CircularProgressIndicator(color: FitColors.neonGreen)),
            error: (_, __) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, color: FitColors.textMuted, size: 48),
                  SizedBox(height: 16.h),
                  Text('Location unavailable', style: TextStyle(color: FitColors.textSecondary)),
                ],
              ),
            ),
          ),

          // Stats overlay
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: FitColors.card.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: FitColors.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: _isTracking ? FitColors.neonGreen : FitColors.card.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          _isTracking ? 'Recording' : 'Ready',
                          style: TextStyle(
                            color: _isTracking ? Colors.white : FitColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Bottom stats
                Container(
                  margin: EdgeInsets.all(16.r),
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: FitColors.card.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: FitColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            label: 'Duration',
                            value: _formatDuration(_elapsedSeconds),
                            icon: Icons.timer_rounded,
                          ),
                          _StatItem(
                            label: 'Distance',
                            value: '${_distanceKm.toStringAsFixed(2)} km',
                            icon: Icons.straighten_rounded,
                          ),
                          _StatItem(
                            label: 'Steps',
                            value: _currentSteps.toString(),
                            icon: Icons.directions_walk_rounded,
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _isTracking ? _stopTracking : _startTracking,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                decoration: BoxDecoration(
                                  color: _isTracking ? FitColors.orange : FitColors.neonGreen,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Center(
                                  child: Text(
                                    _isTracking ? 'Stop' : 'Start',
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
                          if (_routePoints.isNotEmpty && !_isTracking) ...[
                            SizedBox(width: 12.w),
                            Expanded(
                              child: GestureDetector(
                                onTap: _saveWorkout,
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
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ],
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