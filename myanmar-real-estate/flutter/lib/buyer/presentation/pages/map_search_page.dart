/**
 * C端 - 地图找房页面 (OSM + flutter_map)
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// Data models for map search response
// ---------------------------------------------------------------------------

class _MapMarker {
  final int id;
  final double lat;
  final double lng;
  final double price;
  final String priceUnit;
  final int count;

  const _MapMarker({
    required this.id,
    required this.lat,
    required this.lng,
    required this.price,
    required this.priceUnit,
    required this.count,
  });

  factory _MapMarker.fromJson(Map<String, dynamic> json) {
    return _MapMarker(
      id: (json['id'] as num).toInt(),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      priceUnit: json['price_unit'] as String? ?? 'MMK',
      count: (json['count'] as num? ?? 1).toInt(),
    );
  }

  /// Format price as short label, e.g. 3000000 -> "300万"
  String get priceLabel {
    if (price >= 1000000) {
      final wan = (price / 10000).round();
      return '$wan万';
    }
    return price.toStringAsFixed(0);
  }
}

class _MapCluster {
  final double lat;
  final double lng;
  final int count;
  final double avgPrice;

  const _MapCluster({
    required this.lat,
    required this.lng,
    required this.count,
    required this.avgPrice,
  });

  factory _MapCluster.fromJson(Map<String, dynamic> json) {
    return _MapCluster(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      count: (json['count'] as num).toInt(),
      avgPrice: (json['avg_price'] as num? ?? 0).toDouble(),
    );
  }

  String get avgPriceLabel {
    if (avgPrice >= 1000000) {
      final wan = (avgPrice / 10000).round();
      return '$wan万';
    }
    return avgPrice.toStringAsFixed(0);
  }
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class MapSearchPage extends ConsumerStatefulWidget {
  const MapSearchPage({super.key});

  @override
  ConsumerState<MapSearchPage> createState() => _MapSearchPageState();
}

class _MapSearchPageState extends ConsumerState<MapSearchPage> {
  // Yangon center
  static const LatLng _yangonCenter = LatLng(16.8661, 96.1951);
  static const double _initialZoom = 12.0;

  final MapController _mapController = MapController();
  final Dio _dio = Dio();

  List<_MapMarker> _markers = [];
  List<_MapCluster> _clusters = [];
  bool _isLoading = false;

  // Track selected marker for detail card
  _MapMarker? _selectedMarker;

  @override
  void initState() {
    super.initState();
    // Load initial data for Yangon default view
    _fetchMapData(
      swLat: 16.7,
      swLng: 96.0,
      neLat: 17.0,
      neLng: 96.4,
      zoom: _initialZoom,
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    _dio.close();
    super.dispose();
  }

  Future<void> _fetchMapData({
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
    required double zoom,
  }) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final resp = await _dio.get(
        '${ApiConstants.baseApiUrl}/houses/map-search',
        queryParameters: {
          'sw_lat': swLat,
          'sw_lng': swLng,
          'ne_lat': neLat,
          'ne_lng': neLng,
          'zoom': zoom.round(),
        },
      );
      final body = resp.data;
      if (body != null && body['data'] != null) {
        final data = body['data'] as Map<String, dynamic>;
        final rawMarkers = data['markers'] as List<dynamic>? ?? [];
        final rawClusters = data['clusters'] as List<dynamic>? ?? [];
        setState(() {
          _markers = rawMarkers
              .map((e) => _MapMarker.fromJson(e as Map<String, dynamic>))
              .toList();
          _clusters = rawClusters
              .map((e) => _MapCluster.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (_) {
      // Network error: keep existing data, silently ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveEnd) {
      final bounds = _mapController.camera.visibleBounds;
      _fetchMapData(
        swLat: bounds.southWest.latitude,
        swLng: bounds.southWest.longitude,
        neLat: bounds.northEast.latitude,
        neLng: bounds.northEast.longitude,
        zoom: _mapController.camera.zoom,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Build marker widgets
  // ---------------------------------------------------------------------------

  List<Marker> _buildMarkerWidgets() {
    final List<Marker> result = [];

    // Single house markers (price bubbles)
    for (final m in _markers) {
      result.add(Marker(
        point: LatLng(m.lat, m.lng),
        width: 80,
        height: 36,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedMarker = m;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _selectedMarker?.id == m.id
                  ? AppColors.primary900
                  : AppColors.primary700,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              m.priceLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ));
    }

    // Cluster markers (count badge)
    for (final c in _clusters) {
      result.add(Marker(
        point: LatLng(c.lat, c.lng),
        width: 60,
        height: 60,
        child: GestureDetector(
          onTap: () {
            // Zoom in on cluster tap
            _mapController.move(
              LatLng(c.lat, c.lng),
              _mapController.camera.zoom + 1.5,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary700.withOpacity(0.85),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${c.count}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  c.avgPriceLabel,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Stack(
        children: [
          // ---- Real OSM map ----
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _yangonCenter,
              initialZoom: _initialZoom,
              onMapEvent: _onMapEvent,
              onTap: (_, __) {
                // Dismiss selected marker on empty tap
                if (_selectedMarker != null) {
                  setState(() => _selectedMarker = null);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.myanmarhome.buyer',
              ),
              MarkerLayer(
                markers: _buildMarkerWidgets(),
              ),
            ],
          ),

          // ---- Loading indicator ----
          if (_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: const LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: Colors.transparent,
              ),
            ),

          // ---- Top search bar ----
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.gray500),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: l.searchHint,
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---- Map controls (zoom + locate) ----
          Positioned(
            right: 16,
            bottom: 100,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  IconButton(
                    onPressed: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      );
                    },
                    icon: const Icon(Icons.add),
                  ),
                  Divider(height: 1, color: AppColors.gray200),
                  IconButton(
                    onPressed: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      );
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  Divider(height: 1, color: AppColors.gray200),
                  IconButton(
                    onPressed: () {
                      _mapController.move(_yangonCenter, _initialZoom);
                    },
                    icon: const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),
          ),

          // ---- Selected marker house card ----
          if (_selectedMarker != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 90,
              child: _buildHouseCard(_selectedMarker!),
            ),

          // ---- Bottom filter bar ----
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    _buildFilterButton('区域'),
                    _buildFilterButton('价格'),
                    _buildFilterButton('房型'),
                    _buildFilterButton('筛选'),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.list),
                      label: const Text('列表'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: Size.zero,
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildHouseCard(_MapMarker marker) {
    return GestureDetector(
      onTap: () {
        // Navigate to house detail — stubbed for now
        setState(() => _selectedMarker = null);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 60,
                color: AppColors.gray200,
                child: const Icon(Icons.home, color: AppColors.gray400),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '房源 #${marker.id}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '点击查看详情',
                    style: TextStyle(fontSize: 12, color: AppColors.gray500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    marker.priceLabel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }
}
