import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tesoro_regional/core/di/service_locator.dart';
import 'package:tesoro_regional/core/services/location/location_service.dart';
import 'package:tesoro_regional/features/map/domain/entities/strategic_point.dart';
import 'package:tesoro_regional/features/map/presentation/widgets/map_controls.dart';
import 'package:tesoro_regional/features/map/presentation/widgets/map_layers_menu.dart';
import 'package:tesoro_regional/features/map/presentation/widgets/piece_info_sheet.dart';
import 'package:tesoro_regional/features/map/presentation/widgets/progress_menu.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin {
  final MapController _mapController = MapController();
  final List<StrategicPoint> _strategicPoints = [
    StrategicPoint(
      id: '1',
      name: 'Plaza de Armas de Chillán',
      description: 'Corazón histórico de la ciudad',
      latitude: -36.6066,
      longitude: -72.1034,
      iconUrl: 'assets/icons/plaza_icon.png',
      puzzlePieceId: 'piece_1',
      activationRadius: 100.0,
    ),
    StrategicPoint(
      id: '2',
      name: 'Mercado de Chillán',
      description: 'Mercado tradicional con artesanías y comida local',
      latitude: -36.6089,
      longitude: -72.1072,
      iconUrl: 'assets/icons/market_icon.png',
      puzzlePieceId: 'piece_2',
    ),
    StrategicPoint(
      id: '3',
      name: 'Catedral de Chillán',
      description: 'Icono arquitectónico de la ciudad',
      latitude: -36.6051,
      longitude: -72.1021,
      iconUrl: 'assets/icons/cathedral_icon.png',
      puzzlePieceId: 'piece_3',
    ),
    StrategicPoint(
      id: '4',
      name: 'Inacap',
      description: 'Inacap',
      latitude: -36.5942303,
      longitude: -72.1032276,
      iconUrl: 'assets/icons/inacap.png',
      puzzlePieceId: 'piece_4',
    ),
  ];

  StrategicPoint? _activePoint;
  bool _isLoading = true;
  LatLng? _currentPosition;
  bool _mapReady = false;
  String _currentMapLayer =
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  bool _showProgressMenu = false;
  bool _showLayersMenu = false;
  bool _showFullScreenMenu = false;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadSavedProgress();
    _initLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadImages();
    });
  }

  Future<void> _loadSavedProgress() async {
    final prefs = getIt<SharedPreferences>();
    for (final point in _strategicPoints) {
      final isUnlocked = prefs.getBool('point_${point.id}') ?? false;
      if (isUnlocked) {
        final index = _strategicPoints.indexWhere((p) => p.id == point.id);
        if (index != -1) {
          _strategicPoints[index] = point.copyWith(isUnlocked: true);
        }
      }
    }
  }

  Future<void> _saveProgress(String pointId) async {
    final prefs = getIt<SharedPreferences>();
    await prefs.setBool('point_$pointId', true);
  }

  Future<void> _preloadImages() async {
    final uniqueIcons = _strategicPoints.map((p) => p.iconUrl).toSet();
    for (final icon in uniqueIcons) {
      await precacheImage(AssetImage(icon), context);
    }
  }

  Future<void> _initLocation() async {
    try {
      final locationService = getIt<LocationService>();
      final locationData = await locationService.getCurrentPosition();

      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _currentPosition =
              LatLng(locationData.latitude!, locationData.longitude!);
        });
        _mapController.move(_currentPosition!, 15.0);
      }
    } catch (e) {
      // Fallback to default location if there's an error
      _currentPosition = const LatLng(-36.6066, -72.1034); // Chillán centro
      _mapController.move(_currentPosition!, 13.0);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isPointInRange(StrategicPoint point) {
    if (_currentPosition == null) return false;

    final distance = Distance();
    final meters = distance(
      LatLng(point.latitude, point.longitude),
      _currentPosition!,
    );

    return meters <= point.activationRadius;
  }

  void _unlockPoint(StrategicPoint point) {
    setState(() {
      final index = _strategicPoints.indexWhere((p) => p.id == point.id);
      if (index != -1) {
        _strategicPoints[index] = point.copyWith(isUnlocked: true);
        _saveProgress(point.id);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Has desbloqueado ${point.name}!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPointInfo(StrategicPoint point) {
    if (!_isPointInRange(point)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Debes estar a menos de ${point.activationRadius}m de ${point.name}'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _activePoint = point;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Mapa de Ñuble'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.fullscreen),
              onPressed: () => setState(() => _showFullScreenMenu = true),
            ),
            IconButton(
              icon: const Icon(Icons.layers),
              onPressed: () =>
                  setState(() => _showLayersMenu = !_showLayersMenu),
            ),
          ],
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: const LatLng(-36.6066, -72.1034),
                zoom: 13.0,
                minZoom: 10.0, // Límite mínimo
                maxZoom: 18.0, // Límite máximo
                onMapReady: () => setState(() => _mapReady = true),
                interactiveFlags:
                    InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
              children: [
                TileLayer(
                  urlTemplate: _currentMapLayer,
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.app',
                ),
                if (_mapReady)
                  MarkerLayer(
                    markers: _strategicPoints.map((point) {
                      return Marker(
                        point: LatLng(point.latitude, point.longitude),
                        width: 40,
                        height: 40,
                        builder: (ctx) => GestureDetector(
                          onTap: () => _showPointInfo(point),
                          child: Stack(
                            children: [
                              Image.asset(
                                point.iconUrl,
                                width: 40,
                                height: 40,
                              ),
                              if (point.isUnlocked)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                if (_currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentPosition!,
                        width: 30,
                        height: 30,
                        builder: (ctx) => const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () => launchUrl(
                          Uri.parse('https://openstreetmap.org/copyright')),
                    ),
                  ],
                  alignment: AttributionAlignment.bottomRight,
                ),
              ],
            ),
            if (_showFullScreenMenu)
              Positioned.fill(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      AppBar(
                        title: const Text('Menú Completo'),
                        leading: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setState(() => _showFullScreenMenu = false),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _strategicPoints.length,
                          itemBuilder: (ctx, index) {
                            final point = _strategicPoints[index];
                            return ListTile(
                              leading: point.isUnlocked
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.green)
                                  : const Icon(Icons.lock, color: Colors.grey),
                              title: Text(point.name),
                              subtitle: Text(point.description),
                              onTap: () {
                                _showPointInfo(point);
                                setState(() => _showFullScreenMenu = false);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_showLayersMenu)
              Positioned(
                top: 70,
                left: 20,
                child: MapLayersMenu(
                  onLayerSelected: (url) {
                    setState(() {
                      _currentMapLayer = url;
                      _showLayersMenu = false;
                    });
                  },
                  onClose: () => setState(() => _showLayersMenu = false),
                ),
              ),
            Positioned(
              top: 70,
              right: 20,
              child: MapControls(
                onLocationUpdated: (latLng) {
                  setState(() => _currentPosition = latLng);
                  _mapController.move(latLng, _mapController.zoom);
                },
                onZoomChanged: (delta) {
                  _mapController.move(
                    _mapController.center,
                    _mapController.zoom + delta,
                  );
                },
              ),
            ),
            if (_activePoint != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: PieceInfoSheet(
                  point: _activePoint!,
                  onUnlock: () => _unlockPoint(_activePoint!),
                  isInRange: _isPointInRange(_activePoint!),
                  distance: _currentPosition != null
                      ? Distance()
                          .distance(
                            LatLng(_activePoint!.latitude,
                                _activePoint!.longitude),
                            _currentPosition!,
                          )
                          .toStringAsFixed(0)
                      : '--',
                ),
              ),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
