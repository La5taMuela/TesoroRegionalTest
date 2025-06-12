// map_controls.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:tesoro_regional/core/di/service_locator.dart';
import 'package:tesoro_regional/core/services/location/location_service.dart';

class MapControls extends StatelessWidget {
  final Function(LatLng)? onLocationUpdated;
  final Function(double)? onZoomChanged;

  const MapControls({
    super.key,
    this.onLocationUpdated,
    this.onZoomChanged,
  });

  @override
  Widget build(BuildContext context) {
    final locationService = getIt<LocationService>();

    return Column(
      children: [
        FloatingActionButton(
          heroTag: 'btn-location',
          mini: true,
          onPressed: () async {
            final position = await locationService.getCurrentPosition();
            if (position.latitude != null && position.longitude != null) {
              final latLng = LatLng(position.latitude!, position.longitude!);
              onLocationUpdated?.call(latLng);
            }
          },
          child: const Icon(Icons.my_location),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: 'btn-zoom-in',
          mini: true,
          onPressed: () {
            onZoomChanged?.call(1.0); // Aumentar zoom
          },
          child: const Icon(Icons.zoom_in),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: 'btn-zoom-out',
          mini: true,
          onPressed: () {
            onZoomChanged?.call(-1.0); // Disminuir zoom
          },
          child: const Icon(Icons.zoom_out),
        ),
      ],
    );
  }
}