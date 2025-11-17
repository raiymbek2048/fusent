import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/constants/app_constants.dart';

class ShopsMapPage extends StatefulWidget {
  const ShopsMapPage({super.key});

  @override
  State<ShopsMapPage> createState() => _ShopsMapPageState();
}

class _ShopsMapPageState extends State<ShopsMapPage> {
  final MapController _mapController = MapController();
  Shop? _selectedShop;

  // Mock data - replace with real data from backend
  final List<Shop> _shops = [
    Shop(
      id: '1',
      name: 'Fashion Store',
      address: 'Бишкек, ул. Чуй 123',
      latitude: 42.8746,
      longitude: 74.5698,
      rating: 4.5,
      reviewsCount: 120,
      imageUrl: '',
      isOpen: true,
      workingHours: '9:00 - 20:00',
    ),
    Shop(
      id: '2',
      name: 'Tech Paradise',
      address: 'Бишкек, ул. Ибраимова 67',
      latitude: 42.8756,
      longitude: 74.5708,
      rating: 4.9,
      reviewsCount: 203,
      imageUrl: '',
      isOpen: true,
      workingHours: '9:00 - 20:00',
    ),
    Shop(
      id: '3',
      name: 'Book World',
      address: 'Бишкек, пр. Манаса 45',
      latitude: 42.8736,
      longitude: 74.5688,
      rating: 4.7,
      reviewsCount: 156,
      imageUrl: '',
      isOpen: false,
      workingHours: '10:00 - 19:00',
    ),
  ];

  void _goToShop(Shop shop) {
    _mapController.move(
      LatLng(shop.latitude, shop.longitude),
      16.0,
    );
    setState(() {
      _selectedShop = shop;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // OpenStreetMap (бесплатно!)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(
                AppConstants.defaultLatitude,
                AppConstants.defaultLongitude,
              ),
              initialZoom: AppConstants.defaultZoom,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'kg.bishkek.fusent.mobile',
              ),
              MarkerLayer(
                markers: _shops.map((shop) {
                  return Marker(
                    point: LatLng(shop.latitude, shop.longitude),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedShop = shop;
                        });
                      },
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.95),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.location_on, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Карта магазинов',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_shops.length} точек',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      _showFilterBottomSheet();
                    },
                  ),
                ],
              ),
            ),
          ),

          // My location button
          Positioned(
            bottom: _selectedShop != null ? 220 : 100,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                _mapController.move(
                  const LatLng(
                    AppConstants.defaultLatitude,
                    AppConstants.defaultLongitude,
                  ),
                  AppConstants.defaultZoom,
                );
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),

          // Zoom buttons
          Positioned(
            bottom: _selectedShop != null ? 300 : 180,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      currentZoom + 1,
                    );
                  },
                  mini: true,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      currentZoom - 1,
                    );
                  },
                  mini: true,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),

          // Shop list button
          Positioned(
            bottom: _selectedShop != null ? 220 : 100,
            left: 16,
            child: FloatingActionButton.extended(
              onPressed: () {
                _showShopsListBottomSheet();
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.list),
              label: const Text('Список'),
            ),
          ),

          // Selected shop card
          if (_selectedShop != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: _buildShopCard(_selectedShop!),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShopCard(Shop shop) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.textSecondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.surface,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: shop.imageUrl.isNotEmpty
                    ? Image.network(
                        shop.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.store, size: 40);
                        },
                      )
                    : const Icon(Icons.store, size: 40),
              ),
            ),
            const SizedBox(width: 12),

            // Shop info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          shop.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            _selectedShop = null;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${shop.rating} (${shop.reviewsCount} отзывов)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          shop.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: shop.isOpen ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        shop.isOpen ? shop.workingHours : 'Закрыто',
                        style: TextStyle(
                          fontSize: 12,
                          color: shop.isOpen ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Show route
                },
                icon: const Icon(Icons.directions),
                label: const Text('Маршрут'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Call shop
                },
                icon: const Icon(Icons.phone),
                label: const Text('Позвонить'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: View shop products
            },
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Смотреть товары'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  void _showShopsListBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Магазины рядом',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                itemCount: _shops.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final shop = _shops[index];
                  return ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.surface,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: shop.imageUrl.isNotEmpty
                            ? Image.network(
                                shop.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.store);
                                },
                              )
                            : const Icon(Icons.store),
                      ),
                    ),
                    title: Text(shop.name),
                    subtitle: Text(
                      shop.address,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              shop.rating.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: shop.isOpen
                                ? AppColors.success.withOpacity(0.2)
                                : AppColors.error.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            shop.isOpen ? 'Открыто' : 'Закрыто',
                            style: TextStyle(
                              fontSize: 10,
                              color: shop.isOpen ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _goToShop(shop);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Фильтры',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Только открытые'),
                  value: false,
                  onChanged: (value) {
                    // TODO: Filter by open status
                  },
                ),
                CheckboxListTile(
                  title: const Text('Рейтинг 4.5+'),
                  value: false,
                  onChanged: (value) {
                    // TODO: Filter by rating
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Применить'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Models
class Shop {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewsCount;
  final String imageUrl;
  final bool isOpen;
  final String workingHours;

  Shop({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewsCount,
    required this.imageUrl,
    required this.isOpen,
    required this.workingHours,
  });
}
