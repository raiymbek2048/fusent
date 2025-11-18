import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/di/injection_container.dart';
import 'package:fusent_mobile/features/seller/data/models/shop_model.dart';
import 'package:fusent_mobile/features/seller/data/services/shop_service.dart';
import 'package:fusent_mobile/core/widgets/location_picker_map.dart';

class ShopsManagementPage extends StatefulWidget {
  const ShopsManagementPage({super.key});

  @override
  State<ShopsManagementPage> createState() => _ShopsManagementPageState();
}

class _ShopsManagementPageState extends State<ShopsManagementPage> {
  final ShopService _shopService = sl<ShopService>();

  List<ShopModel> _shops = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  Future<void> _loadShops() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final shops = await _shopService.getMyShops();
      setState(() {
        _shops = shops;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteShop(String shopId) async {
    try {
      await _shopService.deleteShop(shopId);
      _loadShops();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Филиал удален')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  void _showCreateEditDialog({ShopModel? shop}) {
    final isEdit = shop != null;
    final nameController = TextEditingController(text: shop?.name ?? '');
    final addressController = TextEditingController(text: shop?.address ?? '');
    final phoneController = TextEditingController(text: shop?.phone ?? '');
    final latController = TextEditingController(text: shop?.lat?.toString() ?? '');
    final lonController = TextEditingController(text: shop?.lon?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Редактировать филиал' : 'Создать филиал'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Название *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Адрес',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Телефон',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push<LocationResult>(
                    MaterialPageRoute(
                      builder: (context) => LocationPickerMap(
                        initialLat: latController.text.isNotEmpty
                            ? double.tryParse(latController.text)
                            : null,
                        initialLon: lonController.text.isNotEmpty
                            ? double.tryParse(lonController.text)
                            : null,
                      ),
                    ),
                  );

                  if (result != null) {
                    latController.text = result.latitude.toString();
                    lonController.text = result.longitude.toString();
                    if (result.address != null && addressController.text.isEmpty) {
                      addressController.text = result.address!;
                    }
                  }
                },
                icon: const Icon(Icons.map),
                label: const Text('Выбрать на карте'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: latController,
                      decoration: const InputDecoration(
                        labelText: 'Широта',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: lonController,
                      decoration: const InputDecoration(
                        labelText: 'Долгота',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      readOnly: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Введите название филиала')),
                );
                return;
              }

              try {
                final lat = latController.text.isNotEmpty
                    ? double.tryParse(latController.text)
                    : null;
                final lon = lonController.text.isNotEmpty
                    ? double.tryParse(lonController.text)
                    : null;

                if (isEdit) {
                  await _shopService.updateShop(
                    shop.id,
                    UpdateShopRequest(
                      name: nameController.text,
                      address: addressController.text.isNotEmpty ? addressController.text : null,
                      phone: phoneController.text.isNotEmpty ? phoneController.text : null,
                      lat: lat,
                      lon: lon,
                    ),
                  );
                } else {
                  await _shopService.createShop(
                    CreateShopRequest(
                      name: nameController.text,
                      address: addressController.text.isNotEmpty ? addressController.text : null,
                      phone: phoneController.text.isNotEmpty ? phoneController.text : null,
                      lat: lat,
                      lon: lon,
                    ),
                  );
                }

                if (mounted) {
                  Navigator.of(context).pop();
                  _loadShops();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEdit ? 'Филиал обновлен' : 'Филиал создан')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка: $e')),
                  );
                }
              }
            },
            child: Text(isEdit ? 'Сохранить' : 'Создать'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои филиалы'),
        backgroundColor: const Color(0xFF00BCD4),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ошибка загрузки',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadShops,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : _shops.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.storefront_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'У вас пока нет филиалов',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Нажмите "+" чтобы создать первый филиал',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadShops,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _shops.length,
                        itemBuilder: (context, index) {
                          final shop = _shops[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF00BCD4),
                                child: Text(
                                  shop.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                shop.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (shop.address != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            shop.address!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (shop.phone != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(shop.phone!),
                                      ],
                                    ),
                                  ],
                                  if (shop.rating != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 16, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${shop.rating!.toStringAsFixed(1)} (${shop.totalReviews ?? 0} отзывов)',
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showCreateEditDialog(shop: shop);
                                  } else if (value == 'delete') {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Удалить филиал?'),
                                        content: Text('Вы уверены, что хотите удалить "${shop.name}"?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('Отмена'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              _deleteShop(shop.id);
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: const Text('Удалить'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Редактировать'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 20, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Удалить', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateEditDialog(),
        backgroundColor: const Color(0xFF00BCD4),
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
