import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  final _positionController = StreamController<Position>.broadcast();
  final List<Position> _routePositions = [];

  Stream<Position> get positionStream => _positionController.stream;
  List<Position> get routePositions => List.unmodifiable(_routePositions);

  Future<bool> requestPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> startTracking() async {
    _routePositions.clear();
    
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _routePositions.add(position);
        _positionController.add(position);
      },
      onError: (error) {
        _positionController.addError(error);
      },
    );
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  double calculateTotalDistance() {
    double totalDistance = 0;
    for (int i = 1; i < _routePositions.length; i++) {
      totalDistance += Geolocator.distanceBetween(
        _routePositions[i - 1].latitude,
        _routePositions[i - 1].longitude,
        _routePositions[i].latitude,
        _routePositions[i].longitude,
      );
    }
    return totalDistance / 1000;
  }

  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    stopTracking();
    _positionController.close();
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  final service = LocationService();
  ref.onDispose(() => service.dispose());
  return service;
});

final currentPositionProvider = FutureProvider<Position?>((ref) async {
  final service = ref.watch(locationServiceProvider);
  final hasPermission = await service.requestPermission();
  if (!hasPermission) return null;
  return service.getCurrentPosition();
});