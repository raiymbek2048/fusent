import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:fusent_mobile/core/widgets/location_picker_map.dart';

class DeliveryAddressesPage extends StatefulWidget {
  const DeliveryAddressesPage({super.key});

  @override
  State<DeliveryAddressesPage> createState() => _DeliveryAddressesPageState();
}

class _DeliveryAddressesPageState extends State<DeliveryAddressesPage> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final response = await _apiClient.getDeliveryAddresses();
      setState(() {
        _addresses = response.data ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAddress(String id) async {
    try {
      await _apiClient.deleteDeliveryAddress(id);
      _loadAddresses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при удалении')),
      );
    }
  }

  Future<void> _setDefault(String id) async {
    try {
      await _apiClient.setDefaultAddress(id);
      _loadAddresses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка')),
      );
    }
  }

  void _showAddressForm([Map<String, dynamic>? address]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddressFormSheet(
        address: address,
        onSave: (data) async {
          try {
            if (address != null) {
              await _apiClient.updateDeliveryAddress(address['id'], data);
            } else {
              await _apiClient.createDeliveryAddress(data);
            }
            Navigator.pop(context);
            _loadAddresses();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ошибка при сохранении')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Адреса доставки')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddressForm(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? const Center(child: Text('Нет сохранённых адресов'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    final isDefault = address['isDefault'] == true;
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          isDefault ? Icons.star : Icons.location_on,
                          color: isDefault ? Colors.amber : null,
                        ),
                        title: Text(address['title'] ?? ''),
                        subtitle: Text(
                          '${address['city']}, ${address['street']} ${address['building'] ?? ''}',
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            if (!isDefault)
                              const PopupMenuItem(
                                value: 'default',
                                child: Text('Сделать основным'),
                              ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Редактировать'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Удалить'),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'default') {
                              _setDefault(address['id']);
                            } else if (value == 'edit') {
                              _showAddressForm(address);
                            } else if (value == 'delete') {
                              _deleteAddress(address['id']);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class AddressFormSheet extends StatefulWidget {
  final Map<String, dynamic>? address;
  final Function(Map<String, dynamic>) onSave;

  const AddressFormSheet({super.key, this.address, required this.onSave});

  @override
  State<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _addressController;
  late TextEditingController _buildingController;
  late TextEditingController _apartmentController;
  late TextEditingController _entranceController;
  late TextEditingController _floorController;
  late TextEditingController _intercomController;
  late TextEditingController _phoneController;
  late TextEditingController _commentController;
  bool _isDefault = false;
  double? _latitude;
  double? _longitude;
  String? _city;
  String? _street;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _titleController = TextEditingController(text: a?['title'] ?? '');

    // Construct full address from existing data
    String fullAddress = '';
    if (a != null && a['city'] != null && a['street'] != null) {
      fullAddress = '${a['city']}, ${a['street']}';
      if (a['building'] != null && a['building'].toString().isNotEmpty) {
        fullAddress += ', ${a['building']}';
      }
    }
    _addressController = TextEditingController(text: fullAddress);

    _city = a?['city'];
    _street = a?['street'];
    _buildingController = TextEditingController(text: a?['building'] ?? '');
    _apartmentController = TextEditingController(text: a?['apartment'] ?? '');
    _entranceController = TextEditingController(text: a?['entrance'] ?? '');
    _floorController = TextEditingController(text: a?['floor'] ?? '');
    _intercomController = TextEditingController(text: a?['intercom'] ?? '');
    _phoneController = TextEditingController(text: a?['phone'] ?? '');
    _commentController = TextEditingController(text: a?['comment'] ?? '');
    _isDefault = a?['isDefault'] == true;
    _latitude = a?['latitude'];
    _longitude = a?['longitude'];
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.of(context).push<LocationResult>(
      MaterialPageRoute(
        builder: (context) => const LocationPickerMap(),
        fullscreenDialog: true,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        final address = result.address ?? '${result.latitude}, ${result.longitude}';
        _addressController.text = address;

        // Parse city and street from address if possible
        final parts = address.split(',').map((e) => e.trim()).toList();
        if (parts.isNotEmpty) {
          _city = parts[0];
          if (parts.length > 1) {
            _street = parts[1];
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.address == null ? 'Новый адрес' : 'Редактировать',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Название (Дом, Работа...)'),
                validator: (v) => v?.isEmpty == true ? 'Обязательно' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Адрес',
                  hintText: 'Выберите адрес на карте',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.location_on),
                    onPressed: _selectLocation,
                  ),
                ),
                readOnly: true,
                onTap: _selectLocation,
                validator: (v) => v?.isEmpty == true ? 'Обязательно' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _buildingController,
                      decoration: const InputDecoration(labelText: 'Дом'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _apartmentController,
                      decoration: const InputDecoration(labelText: 'Квартира'),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _entranceController,
                      decoration: const InputDecoration(labelText: 'Подъезд'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _floorController,
                      decoration: const InputDecoration(labelText: 'Этаж'),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _intercomController,
                decoration: const InputDecoration(labelText: 'Домофон'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Телефон'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(labelText: 'Комментарий'),
                maxLines: 2,
              ),
              CheckboxListTile(
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v ?? false),
                title: const Text('Основной адрес'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onSave({
                        'title': _titleController.text,
                        'city': _city ?? 'Бишкек',
                        'street': _street ?? _addressController.text,
                        'building': _buildingController.text,
                        'apartment': _apartmentController.text,
                        'entrance': _entranceController.text,
                        'floor': _floorController.text,
                        'intercom': _intercomController.text,
                        'phone': _phoneController.text,
                        'comment': _commentController.text,
                        'isDefault': _isDefault,
                        if (_latitude != null) 'latitude': _latitude,
                        if (_longitude != null) 'longitude': _longitude,
                      });
                    }
                  },
                  child: const Text('Сохранить'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
