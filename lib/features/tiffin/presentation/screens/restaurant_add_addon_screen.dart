import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/widgets/food_image.dart';
import '../bloc/restaurant_state_provider.dart';

class RestaurantAddAddonScreen extends StatefulWidget {
  final RestaurantStateProvider stateProvider;
  final Map<String, dynamic>? existingAddon;
  final bool isEdit;

  const RestaurantAddAddonScreen({
    super.key,
    required this.stateProvider,
    this.existingAddon,
    this.isEdit = false,
  });

  @override
  State<RestaurantAddAddonScreen> createState() => _RestaurantAddAddonScreenState();
}

class _RestaurantAddAddonScreenState extends State<RestaurantAddAddonScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  String _availability = 'In Stock';
  bool _isVeg = true;
  File? _pickedImageFile;
  String? _imageFileName;
  String? _existingImageUrl;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.existingAddon != null) {
      final addon = widget.existingAddon!;
      _nameController.text = addon['title']?.toString() ?? addon['name']?.toString() ?? '';
      _descriptionController.text = addon['description']?.toString() ?? '';
      final numPrice = addon['price'];
      if (numPrice != null) {
        final pVal = (numPrice is num) ? numPrice.toDouble() : (double.tryParse(numPrice.toString()) ?? 0.0);
        if (pVal > 0) {
          _priceController.text = pVal.toStringAsFixed(2);
        }
      }
      _isVeg = addon['isVeg'] ?? true;
      final bool isActive = addon['isActive'] ?? true;
      _availability = isActive ? 'In Stock' : 'Out of Stock';

      final String? img = addon['image']?.toString() ?? addon['imageUrl']?.toString();
      if (img != null && img.isNotEmpty) {
        _existingImageUrl = img;
        _imageFileName = 'Existing image attached';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
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
          _imageFileName = pickedFile.name;
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

  void _showImageSourceActionSheet() {
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

  Future<void> _handleSaveAddon() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final String title = _nameController.text.trim();
        final String desc = _descriptionController.text.trim();
        final double price = double.tryParse(_priceController.text.trim()) ?? 0.0;
        final bool isAvailable = _availability == 'In Stock';

        if (widget.isEdit && widget.existingAddon != null && widget.existingAddon!['id'] != null) {
          final int id = widget.existingAddon!['id'];
          await widget.stateProvider.updateAddon(
            id,
            title,
            price,
            _isVeg,
            description: desc,
            isAvailable: isAvailable,
            image: _pickedImageFile,
          );
        } else {
          await widget.stateProvider.addAddon(
            title,
            price,
            50,
            _isVeg,
            description: desc,
            isAvailable: isAvailable,
            image: _pickedImageFile,
          );
        }

        // Refresh state
        await widget.stateProvider.fetchMenuItems();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isEdit
                  ? 'Add-on "$title" updated successfully!'
                  : 'Add-on "$title" created successfully!'),
              backgroundColor: const Color(0xFF00A859),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save add-on: $e'),
              backgroundColor: Colors.red,
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

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13.5),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFF15A22), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFF15A22);
    const Color labelColor = Color(0xFF374151);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Edit Add-on' : 'Add New Add-on',
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
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Item Name Field
                const Text(
                  'Item Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: labelColor,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration('e.g. Buttermilk / Sweet Lassi'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter item name' : null,
                ),
                const SizedBox(height: 18),

                // 2. Description Field
                const Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: labelColor,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: _buildInputDecoration('e.g. Spiced yogurt drink, 250ml'),
                ),
                const SizedBox(height: 18),

                // 3. Item Image Picker Field
                const Text(
                  'Item Image',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: labelColor,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _showImageSourceActionSheet,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                    ),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: _showImageSourceActionSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3F4F6),
                            foregroundColor: const Color(0xFF374151),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: const BorderSide(color: Color(0xFFD1D5DB), width: 1),
                            ),
                          ),
                          child: const Text(
                            'Choose file',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _imageFileName ?? 'No file chosen',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: _imageFileName != null ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
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
                const SizedBox(height: 18),

                // 4. Price (£ / ₹) and Availability Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price Field
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Price (£)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: labelColor,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _buildInputDecoration('1.50'),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Enter price';
                              if (double.tryParse(val.trim()) == null) return 'Invalid price';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Availability Dropdown
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Availability',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: labelColor,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _availability,
                            isExpanded: true,
                            decoration: _buildInputDecoration('In Stock'),
                            items: const [
                              DropdownMenuItem(value: 'In Stock', child: Text('In Stock')),
                              DropdownMenuItem(value: 'Out of Stock', child: Text('Out of Stock')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _availability = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 5. Vegetarian Switch / Toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _isVeg ? const Color(0xFF00A859) : const Color(0xFF8B0000),
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            alignment: Alignment.center,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _isVeg ? const Color(0xFF00A859) : const Color(0xFF8B0000),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _isVeg ? 'Vegetarian Item' : 'Non-Vegetarian Item',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        activeColor: const Color(0xFF00A859),
                        value: _isVeg,
                        onChanged: (val) {
                          setState(() {
                            _isVeg = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 6. Primary Action Button (Create Add-on / Update Add-on)
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _handleSaveAddon,
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
                            widget.isEdit ? 'Update Add-on' : 'Create Add-on',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
