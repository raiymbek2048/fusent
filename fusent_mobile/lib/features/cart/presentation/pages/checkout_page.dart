import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/widgets/location_picker_map.dart';
import 'package:fusent_mobile/core/network/api_client.dart';

class CheckoutPage extends StatefulWidget {
  final double totalAmount;
  final int itemCount;

  const CheckoutPage({
    super.key,
    required this.totalAmount,
    required this.itemCount,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _commentController = TextEditingController();
  final ApiClient _apiClient = ApiClient();

  String _deliveryMethod = 'delivery'; // delivery or pickup
  String _paymentMethod = 'cash'; // cash or card
  String? _shopId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final response = await _apiClient.getCart();
      final cart = response.data;
      if (cart != null && cart['items'] != null && cart['items'].length > 0) {
        setState(() {
          _shopId = cart['items'][0]['shopId'] as String?;
        });
      }
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      if (_shopId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка: не удалось определить магазин')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        await _apiClient.checkout(
          shopId: _shopId!,
          shippingAddress: _deliveryMethod == 'delivery' ? _addressController.text : null,
          paymentMethod: _paymentMethod,
          notes: _commentController.text.isNotEmpty ? _commentController.text : null,
        );

        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 12),
                  Text('Заказ оформлен!'),
                ],
              ),
              content: const Text(
                'Ваш заказ успешно оформлен. Мы свяжемся с вами в ближайшее время для подтверждения.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Close dialog and go back to home
                    Navigator.of(context).pop(); // close dialog
                    context.go('/home'); // go to home
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при оформлении заказа: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Оформление заказа'),
        backgroundColor: AppColors.background,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Order Summary
                  _buildSectionTitle('Ваш заказ'),
                  _buildOrderSummary(),
                  const SizedBox(height: 24),

                  // Contact Information
                  _buildSectionTitle('Контактная информация'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Имя и Фамилия',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите ваше имя';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Номер телефона',
                      prefixIcon: Icon(Icons.phone_outlined),
                      hintText: '+996...',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите номер телефона';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Delivery Method
                  _buildSectionTitle('Способ получения'),
                  const SizedBox(height: 12),
                  _buildDeliveryMethodSelector(),
                  const SizedBox(height: 16),

                  // Address (only if delivery selected)
                  if (_deliveryMethod == 'delivery') ...[
                    TextFormField(
                      controller: _addressController,
                      readOnly: true,
                      onTap: () async {
                        final result = await Navigator.push<LocationResult>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LocationPickerMap(),
                          ),
                        );
                        if (result != null && result.address != null) {
                          setState(() {
                            _addressController.text = result.address!;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Адрес доставки',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        hintText: 'Выберите адрес на карте',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.map),
                          onPressed: () async {
                            final result = await Navigator.push<LocationResult>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LocationPickerMap(),
                              ),
                            );
                            if (result != null && result.address != null) {
                              setState(() {
                                _addressController.text = result.address!;
                              });
                            }
                          },
                        ),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (_deliveryMethod == 'delivery' &&
                            (value == null || value.isEmpty)) {
                          return 'Выберите адрес доставки на карте';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Comment
                  TextFormField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: 'Комментарий к заказу (необязательно)',
                      prefixIcon: Icon(Icons.note_outlined),
                      hintText: 'Дополнительная информация...',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Payment Method
                  _buildSectionTitle('Способ оплаты'),
                  const SizedBox(height: 12),
                  _buildPaymentMethodSelector(),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),

            // Bottom bar with total and place order button
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Товары',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                '${widget.itemCount} шт.',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Сумма',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${widget.totalAmount.toInt()} сом',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryMethodSelector() {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Доставка курьером'),
          subtitle: const Text('100 сом'),
          value: 'delivery',
          groupValue: _deliveryMethod,
          onChanged: (value) {
            setState(() {
              _deliveryMethod = value!;
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _deliveryMethod == 'delivery'
                  ? AppColors.primary
                  : AppColors.border,
            ),
          ),
          tileColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        const SizedBox(height: 12),
        RadioListTile<String>(
          title: const Text('Самовывоз'),
          subtitle: const Text('Бесплатно'),
          value: 'pickup',
          groupValue: _deliveryMethod,
          onChanged: (value) {
            setState(() {
              _deliveryMethod = value!;
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _deliveryMethod == 'pickup'
                  ? AppColors.primary
                  : AppColors.border,
            ),
          ),
          tileColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Наличными при получении'),
          value: 'cash',
          groupValue: _paymentMethod,
          onChanged: (value) {
            setState(() {
              _paymentMethod = value!;
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _paymentMethod == 'cash'
                  ? AppColors.primary
                  : AppColors.border,
            ),
          ),
          tileColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        const SizedBox(height: 12),
        RadioListTile<String>(
          title: const Text('Банковской картой'),
          value: 'card',
          groupValue: _paymentMethod,
          onChanged: (value) {
            setState(() {
              _paymentMethod = value!;
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _paymentMethod == 'card'
                  ? AppColors.primary
                  : AppColors.border,
            ),
          ),
          tileColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final deliveryFee = _deliveryMethod == 'delivery' ? 100 : 0;
    final grandTotal = widget.totalAmount + deliveryFee;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Итого к оплате',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${grandTotal.toInt()} сом',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppColors.primary,
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline, size: 20),
              label: Text(
                _isLoading ? 'Оформление...' : 'Подтвердить заказ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
