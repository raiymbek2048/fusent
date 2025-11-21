import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/network/api_client.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _methods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  Future<void> _loadMethods() async {
    try {
      final response = await _apiClient.getPaymentMethods();
      setState(() {
        _methods = response.data ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMethod(String id) async {
    try {
      await _apiClient.deletePaymentMethod(id);
      _loadMethods();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при удалении')),
      );
    }
  }

  Future<void> _setDefault(String id) async {
    try {
      await _apiClient.setDefaultPaymentMethod(id);
      _loadMethods();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка')),
      );
    }
  }

  void _showAddMethodSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddPaymentMethodSheet(
        onSave: (data) async {
          try {
            await _apiClient.createPaymentMethod(data);
            Navigator.pop(context);
            _loadMethods();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ошибка при сохранении')),
            );
          }
        },
      ),
    );
  }

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'CARD':
        return Icons.credit_card;
      case 'CASH':
        return Icons.money;
      case 'ELSOM':
      case 'MBANK':
      case 'O_DENGI':
        return Icons.phone_android;
      default:
        return Icons.payment;
    }
  }

  String _getTypeName(String? type) {
    switch (type) {
      case 'CARD':
        return 'Банковская карта';
      case 'CASH':
        return 'Наличные';
      case 'ELSOM':
        return 'Элсом';
      case 'MBANK':
        return 'MBank';
      case 'O_DENGI':
        return 'О! Деньги';
      default:
        return type ?? 'Неизвестно';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Способы оплаты')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMethodSheet,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _methods.isEmpty
              ? const Center(child: Text('Нет сохранённых способов оплаты'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _methods.length,
                  itemBuilder: (context, index) {
                    final method = _methods[index];
                    final isDefault = method['isDefault'] == true;
                    final type = method['type'] as String?;
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          isDefault ? Icons.star : _getTypeIcon(type),
                          color: isDefault ? Colors.amber : null,
                        ),
                        title: Text(_getTypeName(type)),
                        subtitle: Text(
                          type == 'CARD'
                              ? method['cardNumber'] ?? ''
                              : method['phone'] ?? '',
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            if (!isDefault)
                              const PopupMenuItem(
                                value: 'default',
                                child: Text('Сделать основным'),
                              ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Удалить'),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'default') {
                              _setDefault(method['id']);
                            } else if (value == 'delete') {
                              _deleteMethod(method['id']);
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

class AddPaymentMethodSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const AddPaymentMethodSheet({super.key, required this.onSave});

  @override
  State<AddPaymentMethodSheet> createState() => _AddPaymentMethodSheetState();
}

class _AddPaymentMethodSheetState extends State<AddPaymentMethodSheet> {
  String _selectedType = 'CARD';
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isDefault = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Добавить способ оплаты',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Тип'),
              items: const [
                DropdownMenuItem(value: 'CARD', child: Text('Банковская карта')),
                DropdownMenuItem(value: 'CASH', child: Text('Наличные')),
                DropdownMenuItem(value: 'ELSOM', child: Text('Элсом')),
                DropdownMenuItem(value: 'MBANK', child: Text('MBank')),
                DropdownMenuItem(value: 'O_DENGI', child: Text('О! Деньги')),
              ],
              onChanged: (v) => setState(() => _selectedType = v!),
            ),
            if (_selectedType == 'CARD') ...[
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(labelText: 'Номер карты'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _cardHolderController,
                decoration: const InputDecoration(labelText: 'Имя владельца'),
              ),
              TextFormField(
                controller: _expiryController,
                decoration: const InputDecoration(labelText: 'Срок действия (MM/YY)'),
              ),
            ],
            if (_selectedType == 'ELSOM' ||
                _selectedType == 'MBANK' ||
                _selectedType == 'O_DENGI')
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Номер телефона'),
                keyboardType: TextInputType.phone,
              ),
            CheckboxListTile(
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v ?? false),
              title: const Text('Основной способ'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave({
                    'type': _selectedType,
                    'cardNumber': _cardNumberController.text,
                    'cardHolder': _cardHolderController.text,
                    'expiryDate': _expiryController.text,
                    'phone': _phoneController.text,
                    'isDefault': _isDefault,
                  });
                },
                child: const Text('Сохранить'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
