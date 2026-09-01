import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kinkitchen/core/widgets/food_image.dart';
import 'package:kinkitchen/modules/restaurant/restaurant_state_provider.dart';

class RestaurantAddMenuItemScreen extends StatefulWidget {
  final RestaurantStateProvider stateProvider;
  final String? initialMealType;
  final Map<String, dynamic>? existingMeal;
  final bool isEdit;

  const RestaurantAddMenuItemScreen({
    super.key,
    required this.stateProvider,
    this.initialMealType,
    this.existingMeal,
    this.isEdit = false,
  });

  @override
  State<RestaurantAddMenuItemScreen> createState() => _RestaurantAddMenuItemScreenState();
}

class _RestaurantAddMenuItemScreenState extends State<RestaurantAddMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();

  // Input Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _regularPriceController = TextEditingController();
  final _discountPriceController = TextEditingController();

  // Selection States
  String _selectedDietaryType = 'Vegetarian (VEG)';
  String _selectedAvailability = 'Available';
  String? _selectedImageName;
  String? _existingImageUrl;
  File? _pickedImageFile;
  int? _selectedCategoryId;

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Helper methods to normalize dropdown values safely
  String _normalizeDietaryType(String? val) {
    if (val == null || val.isEmpty) return 'Vegetarian (VEG)';
    final s = val.toUpperCase();
    if (s.contains('JAIN')) return 'Jain (JAIN)';
    if (s.contains('VEGAN')) return 'Vegan (VEGAN)';
    if (s.contains('NON')) return 'Non-Vegetarian (NON-VEG)';
    if (s.contains('VEG') || s.contains('VEGETARIAN')) return 'Vegetarian (VEG)';
    return 'Vegetarian (VEG)';
  }

  String _normalizeAvailability(String? val) {
    if (val == null || val.isEmpty) return 'Available';
    final s = val.toUpperCase();
    if (s.contains('OUT') || s.contains('UNAVAILABLE') || s == '0' || s == 'FALSE') {
      return 'Out of Stock';
    }
    return 'Available';
  }

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.existingMeal != null) {
      final meal = widget.existingMeal!;
      _nameController.text = meal['title']?.toString() ?? meal['name']?.toString() ?? '';
      _descriptionController.text = meal['description']?.toString() ?? '';
      
      final numPrice = meal['price'];
      if (numPrice != null) {
        final pVal = (numPrice is num) ? numPrice.toDouble() : (double.tryParse(numPrice.toString()) ?? 0.0);
        if (pVal > 0) {
          _regularPriceController.text = pVal.toStringAsFixed(2);
        }
      }

      final dynamic rawDisc = meal['discount_price'] ?? meal['discountPrice'];
      if (rawDisc != null) {
        final dVal = (rawDisc is num) ? rawDisc.toDouble() : (double.tryParse(rawDisc.toString()) ?? 0.0);
        if (dVal > 0) {
          _discountPriceController.text = dVal.toStringAsFixed(2);
        }
      }

      final bool isVeg = meal['isVeg'] ?? (meal['veg_type'] == 'VEG' || meal['veg_type'] == 'JAIN' || meal['veg_type'] == 'Vegetarian');
      final String rawVType = meal['veg_type']?.toString() ?? (isVeg ? 'VEG' : 'NON_VEG');
      _selectedDietaryType = _normalizeDietaryType(rawVType);

      final dynamic rawAvail = meal['availability'] ?? meal['isActive'];
      _selectedAvailability = _normalizeAvailability(rawAvail?.toString());

      final String? imgUrl = meal['image']?.toString() ?? meal['imageUrl']?.toString();
      if (imgUrl != null && imgUrl.isNotEmpty) {
        _existingImageUrl = imgUrl;
        _selectedImageName = 'Existing image attached';
      }
    }

    if (widget.stateProvider.categories.isNotEmpty) {
      _selectedCategoryId = widget.stateProvider.categories.first.id;
    } else {
      widget.stateProvider.fetchCategories().then((_) {
        if (mounted && widget.stateProvider.categories.isNotEmpty) {
          setState(() {
            _selectedCategoryId = widget.stateProvider.categories.first.id;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _regularPriceController.dispose();
    _discountPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _pickedImageFile = File(pickedFile.path);
          _selectedImageName = pickedFile.name;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    const Color brandOrange = Color(0xFFF15A22);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              const ListTile(
                title: Text(
                  'Select Image Source',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: brandOrange),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: brandOrange),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSaveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final vegType = _selectedDietaryType.contains('VEG') && !_selectedDietaryType.contains('NON')
            ? 'VEG'
            : (_selectedDietaryType.contains('JAIN')
                ? 'JAIN'
                : (_selectedDietaryType.contains('VEGAN') ? 'VEGAN' : 'NON_VEG'));

        final availability = (_selectedAvailability == 'In Stock' || _selectedAvailability == 'Available') ? '1' : '0';

        final priceVal = double.tryParse(_regularPriceController.text.trim()) ?? 0.0;
        final discountText = _discountPriceController.text.trim();
        final discountVal = double.tryParse(discountText);

        final fields = {
          'category_id': _selectedCategoryId?.toString() ?? '1',
          'restaurant_id': widget.stateProvider.profile?.id.toString() ?? '1',
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': priceVal.toStringAsFixed(2),
          if (discountVal != null && discountVal > 0 && discountVal < priceVal)
            'discount_price': discountVal.toStringAsFixed(2),
          'veg_type': vegType,
          'availability': availability,
          'status': 'ACTIVE',
        };

        if (widget.isEdit && widget.existingMeal != null && widget.existingMeal!['id'] != null) {
          final int itemId = widget.existingMeal!['id'];
          await widget.stateProvider.updateMenuItem(itemId, fields, image: _pickedImageFile);
        } else {
          await widget.stateProvider.addMenuItem(fields, image: _pickedImageFile);
        }

        // Refresh state from API/database
        await widget.stateProvider.fetchMenuItems();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isEdit ? 'Item updated successfully!' : 'Meal scheduled successfully!'),
              backgroundColor: const Color(0xFF00A859),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          String errMsg = e.toString();
          final dynamic err = e;
          if (err is Map && err.containsKey('errors')) {
            final buffer = StringBuffer();
            final errors = err['errors'] as Map;
            errors.forEach((key, list) {
              if (list is List) {
                buffer.write('$key: ${list.join(', ')}\n');
              } else {
                buffer.write('$key: $list\n');
              }
            });
            errMsg = buffer.toString().trim();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save meal:\n$errMsg'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 6),
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
  }

  InputDecoration _buildInputDecoration(String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13.5),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFF15A22), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF4B5563),
          fontSize: 13.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFF15A22);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Edit Meal' : 'Add Meal',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Meal Box Name
                _buildFieldLabel('Item name'),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 14),
                  decoration: _buildInputDecoration('e.g. Deluxe Gujarati Thali'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter meal box name' : null,
                ),
                const SizedBox(height: 16),

                // 4. Description
                _buildFieldLabel('Description'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14),
                  decoration: _buildInputDecoration('e.g. 2 curries, sweet, farsan, rotlis...'),
                ),
                const SizedBox(height: 16),

                // 5. Meal Image
                _buildFieldLabel('Item Image'),
                InkWell(
                  onTap: () => _showImageSourceActionSheet(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
                    ),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _showImageSourceActionSheet(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3F4F6),
                            foregroundColor: const Color(0xFF1F2937),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: const BorderSide(color: Color(0xFFD1D5DB), width: 1),
                            ),
                          ),
                          child: const Text(
                            'Choose file',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedImageName ?? 'No file chosen',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: _selectedImageName != null ? const Color(0xFF1F2937) : const Color(0xFF374151),
                            ),
                          ),
                        ),
                        if (_pickedImageFile != null) ...[
                          const SizedBox(width: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(_pickedImageFile!, width: 40, height: 40, fit: BoxFit.cover),
                          ),
                        ] else if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          FoodImage(
                            title: _nameController.text,
                            imageUrl: _existingImageUrl,
                            width: 40,
                            height: 40,
                            borderRadius: 6,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 6. Price (£) & Discount Price (£) Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Price (£)'),
                          TextFormField(
                            controller: _regularPriceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(fontSize: 14),
                            decoration: _buildInputDecoration(''),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Enter price';
                              if (double.tryParse(val.trim()) == null) return 'Invalid price';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Discount Price (£)'),
                          TextFormField(
                            controller: _discountPriceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(fontSize: 14),
                            decoration: _buildInputDecoration(''),
                            validator: (val) {
                              if (val != null && val.trim().isNotEmpty) {
                                final dVal = double.tryParse(val.trim());
                                final pVal = double.tryParse(_regularPriceController.text.trim());
                                if (dVal == null) return 'Invalid price';
                                if (pVal != null && dVal >= pVal) return 'Must be < Price';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 7. Dietary Type & Availability Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Dietary Type'),
                          DropdownButtonFormField<String>(
                            value: _normalizeDietaryType(_selectedDietaryType),
                            isExpanded: true,
                            style: const TextStyle(fontSize: 13.5, color: Color(0xFF1F2937)),
                            decoration: _buildInputDecoration(''),
                            items: const [
                              DropdownMenuItem(value: 'Vegetarian (VEG)', child: Text('Vegetarian (VEG)')),
                              DropdownMenuItem(value: 'Non-Vegetarian (NON-VEG)', child: Text('Non-Vegetarian (NON-VEG)')),
                              DropdownMenuItem(value: 'Jain (JAIN)', child: Text('Jain (JAIN)')),
                              DropdownMenuItem(value: 'Vegan (VEGAN)', child: Text('Vegan (VEGAN)')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedDietaryType = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Availability'),
                          DropdownButtonFormField<String>(
                            value: _normalizeAvailability(_selectedAvailability),
                            isExpanded: true,
                            style: const TextStyle(fontSize: 13.5, color: Color(0xFF1F2937)),
                            decoration: _buildInputDecoration(''),
                            items: const [
                              DropdownMenuItem(value: 'Available', child: Text('Available')),
                              DropdownMenuItem(value: 'Out of Stock', child: Text('Out of Stock')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedAvailability = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // 8. Primary Schedule Meal Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _handleSaveItem,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            widget.isEdit ? 'Update Menu' : 'Create Menu',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
