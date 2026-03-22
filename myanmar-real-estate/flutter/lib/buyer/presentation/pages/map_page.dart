/**
 * C端 - 地图找房页面 (OSM + flutter_map)
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final MapController _mapController = MapController();

  // 仰光中心位置
  static const LatLng _yangonCenter = LatLng(16.8661, 96.1951);
  static const double _initialZoom = 12.0;

  bool _showList = false;
  String _selectedClusterName = '';
  int _selectedClusterCount = 0;

  // 模拟聚合数据
  final List<Map<String, dynamic>> _clusters = [
    {'id': '1', 'lat': 16.8661, 'lng': 96.1951, 'count': 128, 'name': 'Tamwe'},
    {'id': '2', 'lat': 16.8156, 'lng': 96.1544, 'count': 86, 'name': 'Bahan'},
    {'id': '3', 'lat': 16.7825, 'lng': 96.1722, 'count': 64, 'name': 'Yankin'},
    {'id': '4', 'lat': 16.8542, 'lng': 96.1234, 'count': 45, 'name': 'Mayangone'},
  ];

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  List<Marker> _buildClusterMarkers() {
    return _clusters.map((cluster) {
      final count = cluster['count'] as int;
      final name = cluster['name'] as String;

      // Size scales slightly with count
      final double size = count > 100 ? 64 : count > 60 ? 56 : 48;

      return Marker(
        point: LatLng(
          cluster['lat'] as double,
          cluster['lng'] as double,
        ),
        width: size,
        height: size,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _showList = true;
              _selectedClusterName = name;
              _selectedClusterCount = count;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary700,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '套',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ---- OSM Map ----
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _yangonCenter,
              initialZoom: _initialZoom,
              onTap: (_, __) {
                if (_showList) setState(() => _showList = false);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.myanmarhome.buyer',
              ),
              MarkerLayer(
                markers: _buildClusterMarkers(),
              ),
            ],
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
                      boxShadow: AppShadows.md,
                    ),
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: AppShadows.md,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search,
                              color: AppColors.gray500),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '搜索区域、小区...',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.gray500,
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

          // ---- Right-side map control buttons ----
          Positioned(
            right: 16,
            top: 100,
            child: Column(
              children: [
                _buildMapButton(
                  icon: Icons.filter_list,
                  onTap: () {
                    // TODO: open filter sheet
                  },
                ),
                const SizedBox(height: 8),
                _buildMapButton(
                  icon: Icons.my_location,
                  onTap: () {
                    _mapController.move(_yangonCenter, _initialZoom);
                  },
                ),
              ],
            ),
          ),

          // ---- Bottom house list sheet ----
          if (_showList)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 300,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Drag handle / dismiss
                    GestureDetector(
                      onTap: () => setState(() => _showList = false),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.gray300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    // Title row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_selectedClusterName区域房源',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '$_selectedClusterCount套',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: AppColors.primary700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Horizontal house cards
                    Expanded(
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return _buildHouseCard(context, index);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: AppShadows.md,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon),
      ),
    );
  }

  Widget _buildHouseCard(BuildContext context, int index) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: Container(
              height: 120,
              color: AppColors.gray200,
              child: const Center(
                child: Icon(Icons.image, color: AppColors.gray400),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '仰光${_selectedClusterName}区精装3室公寓',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '120㎡ · 3室2厅',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.gray600),
                ),
                const SizedBox(height: 8),
                Text(
                  '15,000万 缅币',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                        color: AppColors.primary700,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
