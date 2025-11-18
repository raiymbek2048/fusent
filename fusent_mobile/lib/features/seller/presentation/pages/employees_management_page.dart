import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/di/injection_container.dart';
import 'package:fusent_mobile/features/seller/data/models/employee_model.dart';
import 'package:fusent_mobile/features/seller/data/models/shop_model.dart';
import 'package:fusent_mobile/features/seller/data/services/employee_service.dart';
import 'package:fusent_mobile/features/seller/data/services/shop_service.dart';

class EmployeesManagementPage extends StatefulWidget {
  const EmployeesManagementPage({super.key});

  @override
  State<EmployeesManagementPage> createState() => _EmployeesManagementPageState();
}

class _EmployeesManagementPageState extends State<EmployeesManagementPage> {
  final EmployeeService _employeeService = sl<EmployeeService>();
  final ShopService _shopService = sl<ShopService>();

  List<EmployeeModel> _employees = [];
  List<ShopModel> _shops = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final employeesFuture = _employeeService.getAllEmployees();
      final shopsFuture = _shopService.getMyShops();

      final results = await Future.wait([employeesFuture, shopsFuture]);

      setState(() {
        _employees = results[0] as List<EmployeeModel>;
        _shops = results[1] as List<ShopModel>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEmployee(String employeeId) async {
    try {
      await _employeeService.deleteEmployee(employeeId);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Сотрудник удален')),
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

  void _showCreateEmployeeDialog() {
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    String? selectedShopId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Добавить сотрудника'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Полное имя *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Пароль *',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
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
                DropdownButtonFormField<String>(
                  value: selectedShopId,
                  decoration: const InputDecoration(
                    labelText: 'Филиал *',
                    border: OutlineInputBorder(),
                  ),
                  items: _shops.map((shop) {
                    return DropdownMenuItem(
                      value: shop.id,
                      child: Text(shop.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedShopId = value;
                    });
                  },
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
                if (fullNameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    passwordController.text.isEmpty ||
                    selectedShopId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Заполните все обязательные поля')),
                  );
                  return;
                }

                try {
                  await _employeeService.createEmployee(
                    CreateEmployeeRequest(
                      fullName: fullNameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      phone: phoneController.text.isNotEmpty ? phoneController.text : null,
                      shopId: selectedShopId!,
                    ),
                  );

                  if (mounted) {
                    Navigator.of(context).pop();
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Сотрудник создан')),
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
              child: const Text('Создать'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeShopDialog(EmployeeModel employee) {
    String? selectedShopId = employee.shopId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Изменить филиал'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Сотрудник: ${employee.fullName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedShopId,
                decoration: const InputDecoration(
                  labelText: 'Новый филиал',
                  border: OutlineInputBorder(),
                ),
                items: _shops.map((shop) {
                  return DropdownMenuItem(
                    value: shop.id,
                    child: Text(shop.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedShopId = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedShopId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Выберите филиал')),
                  );
                  return;
                }

                try {
                  await _employeeService.updateEmployeeShop(
                    employee.id,
                    UpdateEmployeeShopRequest(shopId: selectedShopId!),
                  );

                  if (mounted) {
                    Navigator.of(context).pop();
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Филиал изменен')),
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
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои сотрудники'),
        backgroundColor: const Color(0xFFFF5722),
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
                        onPressed: _loadData,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : _employees.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'У вас пока нет сотрудников',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Нажмите "+" чтобы добавить первого сотрудника',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _employees.length,
                        itemBuilder: (context, index) {
                          final employee = _employees[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFFF5722),
                                child: Text(
                                  employee.fullName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                employee.fullName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.email, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          employee.email,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (employee.phone != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(employee.phone!),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.storefront, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(employee.shopName),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'change_shop') {
                                    _showChangeShopDialog(employee);
                                  } else if (value == 'delete') {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Удалить сотрудника?'),
                                        content: Text('Вы уверены, что хотите удалить "${employee.fullName}"?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('Отмена'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              _deleteEmployee(employee.id);
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
                                    value: 'change_shop',
                                    child: Row(
                                      children: [
                                        Icon(Icons.swap_horiz, size: 20),
                                        SizedBox(width: 8),
                                        Text('Изменить филиал'),
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
        onPressed: _showCreateEmployeeDialog,
        backgroundColor: const Color(0xFFFF5722),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
