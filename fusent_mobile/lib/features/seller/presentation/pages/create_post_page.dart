import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/di/injection_container.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _imagePicker = ImagePicker();

  String _selectedPostType = 'TEXT';
  String _selectedVisibility = 'PUBLIC';
  bool _isLoading = false;
  bool _isLoadingProducts = false;
  List<XFile> _selectedImages = [];
  List<Map<String, dynamic>> _products = [];
  String? _selectedProductId;

  final List<Map<String, String>> _postTypes = [
    {'value': 'TEXT', 'label': 'Текст'},
    {'value': 'PHOTO', 'label': 'Фото'},
    {'value': 'PRODUCT', 'label': 'Товар'},
  ];

  final List<Map<String, String>> _visibilityOptions = [
    {'value': 'PUBLIC', 'label': 'Публичный'},
    {'value': 'FOLLOWERS', 'label': 'Подписчики'},
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      final apiClient = sl<ApiClient>();
      final response = await apiClient.getMyProducts();

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> productsData = response.data as List<dynamic>;

        setState(() {
          _products = productsData.map((product) {
            return {
              'id': product['id'],
              'name': product['name'] ?? 'Без названия',
              'price': (product['basePrice'] ?? 0).toDouble(),
              'imageUrl': product['imageUrl'],
            };
          }).toList();
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки товаров: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 70,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = images;
          if (_selectedPostType == 'TEXT') {
            _selectedPostType = 'PHOTO';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при выборе изображений: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      if (_selectedImages.isEmpty && _selectedPostType == 'PHOTO') {
        _selectedPostType = 'TEXT';
      }
    });
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiClient = sl<ApiClient>();

      // Upload images first if any
      List<Map<String, dynamic>>? mediaList;
      if (_selectedImages.isNotEmpty) {
        mediaList = [];
        for (int i = 0; i < _selectedImages.length; i++) {
          final image = _selectedImages[i];
          try {
            final uploadResponse = await apiClient.uploadPostMedia(image.path);
            if (uploadResponse.statusCode == 200 && uploadResponse.data != null) {
              final url = uploadResponse.data['url'];
              mediaList.add({
                'mediaType': 'IMAGE',
                'url': url,
                'sortOrder': i,
              });
            }
          } catch (e) {
            print('Error uploading image: $e');
          }
        }
      }

      final response = await apiClient.createPost(
        text: _textController.text.trim(),
        postType: _selectedPostType,
        visibility: _selectedVisibility,
        media: mediaList,
        linkedProductId: _selectedProductId,
      );

      if (mounted && response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Пост успешно создан!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } on DioException catch (e) {
      String errorMessage = 'Ошибка при создании поста';

      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'];
        } else if (data is String) {
          errorMessage = data;
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Неизвестная ошибка: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать пост'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Post Type
              DropdownButtonFormField<String>(
                value: _selectedPostType,
                decoration: const InputDecoration(
                  labelText: 'Тип поста',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _postTypes.map((type) {
                  return DropdownMenuItem(
                    value: type['value'],
                    child: Text(type['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPostType = value!;
                    // Load products if PRODUCT type is selected
                    if (value == 'PRODUCT' && _products.isEmpty) {
                      _loadProducts();
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // Visibility
              DropdownButtonFormField<String>(
                value: _selectedVisibility,
                decoration: const InputDecoration(
                  labelText: 'Видимость',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.visibility),
                ),
                items: _visibilityOptions.map((option) {
                  return DropdownMenuItem(
                    value: option['value'],
                    child: Text(option['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVisibility = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Product Selection (only for PRODUCT type)
              if (_selectedPostType == 'PRODUCT') ...[
                _isLoadingProducts
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        value: _selectedProductId,
                        decoration: const InputDecoration(
                          labelText: 'Выберите товар *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.inventory_2),
                        ),
                        items: _products.map((product) {
                          return DropdownMenuItem(
                            value: product['id'] as String,
                            child: Row(
                              children: [
                                if (product['imageUrl'] != null && product['imageUrl'] != '')
                                  Container(
                                    width: 40,
                                    height: 40,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: AppColors.surface,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        product['imageUrl'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.image, size: 24, color: AppColors.textSecondary);
                                        },
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        product['name'] as String,
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${product['price']} сом',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProductId = value;
                          });
                        },
                        validator: (value) {
                          if (_selectedPostType == 'PRODUCT' && value == null) {
                            return 'Выберите товар для публикации';
                          }
                          return null;
                        },
                      ),
                const SizedBox(height: 16),
              ],

              // Post Text
              TextFormField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Текст поста *',
                  hintText: 'Что нового в вашем магазине?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите текст поста';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Image picker button
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: Text(_selectedImages.isEmpty ? 'Добавить фото' : 'Добавить ещё'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
              const SizedBox(height: 16),

              // Selected images preview
              if (_selectedImages.isNotEmpty) ...[
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_selectedImages[index].path),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Опубликовать',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 16),

              // Required fields note
              const Text(
                '* - обязательные поля',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
