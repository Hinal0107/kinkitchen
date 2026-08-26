import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/widgets/food_image.dart';
import '../../../../models/menu_category.dart';
import '../bloc/restaurant_state_provider.dart';

class RestaurantAddCategoryScreen extends StatefulWidget {
  final RestaurantStateProvider stateProvider;
  final MenuCategory? existingCategory;
  final bool isEdit;

  const RestaurantAddCategoryScreen({
    super.key,
    required this.stateProvider,
    this.existingCategory,
    this.isEdit = false,
  });

  @override
  State<RestaurantAddCategoryScreen> createState() => _RestaurantAddCategoryScreenState();
}

class _RestaurantAddCategoryScreenState extends State<RestaurantAddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sortOrderController = TextEditingController(text: '1');

  File? _pickedImageFile;
  String? _selectedImageName;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.existingCategory != null) {
      final cat = widget.existingCategory!;
      _nameController.text = cat.name;
      _descriptionController.text = cat.description;
      if (cat.imageUrl != null && cat.imageUrl!.isNotEmpty) {
        _existingImageUrl = cat.imageUrl;
        _selectedImageName = 'Existing image attached';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _sortOrderController.dispose();
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
      debugPrint('Error picking category image: $e');
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
                  'Select Category Image',
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

  Future<void> _handleSaveCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final name = _nameController.text.trim();
        final desc = _descriptionController.text.trim();

        if (widget.isEdit && widget.existingCategory != null) {
          await widget.stateProvider.updateCategory(
            widget.existingCategory!.id,
            name,
            desc,
            widget.existingCategory!.status,
            image: _pickedImageFile,
          );
        } else {
          await widget.stateProvider.createCategory(
            name,
            desc,
            'ACTIVE',
            image: _pickedImageFile,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isEdit ? 'Category "$name" updated successfully!' : 'Category "$name" created successfully!'),
              backgroundColor: const Color(0xFF00A859),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create category: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          widget.isEdit ? 'Edit Menu Category' : 'Add New Menu',
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
                // 1. Category Name
                _buildFieldLabel('Item Name'),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 14),
                  decoration: _buildInputDecoration('e.g. Punjabi Thalis'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter category name' : null,
                ),
                const SizedBox(height: 16),

                // 2. Description
                _buildFieldLabel('Description'),
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(fontSize: 14),
                  decoration: _buildInputDecoration('Short summary of items'),
                ),
                const SizedBox(height: 16),

                // 3. Category Image
                _buildFieldLabel('Item Image'),
                InkWell(
                  onTap: _showImageSourceActionSheet,
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
                          onPressed: _showImageSourceActionSheet,
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

                // 4. Sort Order
                _buildFieldLabel('Sort Order'),
                TextFormField(
                  controller: _sortOrderController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 14),
                  decoration: _buildInputDecoration('1'),
                ),
                const SizedBox(height: 28),

                // 5. Submit Button
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
                    onPressed: _isLoading ? null : _handleSaveCategory,
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
