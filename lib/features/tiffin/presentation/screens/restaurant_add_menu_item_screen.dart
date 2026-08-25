import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failure.dart';
import '../bloc/restaurant_state_provider.dart';

class RestaurantAddMenuItemScreen extends StatefulWidget {
  final RestaurantStateProvider stateProvider;

  const RestaurantAddMenuItemScreen({super.key, required this.stateProvider});

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
  final _sortOrderController = TextEditingController(text: '1');
  DateTime _selectedDate = DateTime.now();
  late final TextEditingController _dateController;
  int? _selectedAutofillItemId;

  // Dropdown States
  int? _selectedCategoryId;
  String _selectedDietaryType = 'Vegetarian';
  String _selectedAvailability = 'In Stock';
  String? _selectedImageName;
  File? _pickedImageFile;

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF15A22),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
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

  @override
  void initState() {
    super.initState();
    final todayStr = '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';
    _dateController = TextEditingController(text: todayStr);
    // Default to the first available category
    if (widget.stateProvider.categories.isNotEmpty) {
      _selectedCategoryId = widget.stateProvider.categories.first.id;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _regularPriceController.dispose();
    _discountPriceController.dispose();
    _sortOrderController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateItem() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final vegType = _selectedDietaryType == 'Vegetarian'
            ? 'VEG'
            : (_selectedDietaryType == 'Jain' ? 'JAIN' : 'NON_VEG');

        final availability = _selectedAvailability == 'In Stock' ? '1' : '0';

        final fields = {
          'category_id': _selectedCategoryId.toString(),
          'restaurant_id': widget.stateProvider.profile?.id.toString() ?? '1',
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': _regularPriceController.text.trim(),
          'discount_price': _discountPriceController.text.trim().isEmpty 
              ? '0.0' 
              : _discountPriceController.text.trim(),
          'veg_type': vegType,
          'availability': availability,
          'status': 'Active',
          'sort_order': _sortOrderController.text.trim(),
          'schedule_date': _dateController.text.trim(),
        };

        await widget.stateProvider.addMenuItem(fields, image: _pickedImageFile);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${_nameController.text.trim()}" created successfully!')),
          );
          Navigator.pop(context); // Go back to Home Screen
        }
      } catch (e) {
        if (mounted) {
          String errMsg = e.toString();
          if (e is ValidationFailure && e.errors != null) {
            final buffer = StringBuffer();
            e.errors!.forEach((key, list) {
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
              content: Text('Failed to create item:\n$errMsg'),
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

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFF15A22);
    const Color inputLabelColor = Color(0xFF4B5563);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Add Menu Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add New Menu Item',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 20),

                  // Autofill Dropdown Section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFEAE5), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Autofill from Menu Items',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF15A22), fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          value: _selectedAutofillItemId,
                          hint: const Text('-- Choose Menu Item to Autofill --', style: TextStyle(fontSize: 13)),
                          decoration: _buildInputDecoration('Choose Item'),
                          items: widget.stateProvider.menuItems.map((item) {
                            return DropdownMenuItem<int>(
                              value: item.id,
                              child: Text(item.name, style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              final selectedItem = widget.stateProvider.menuItems.firstWhere((item) => item.id == val);
                              setState(() {
                                _selectedAutofillItemId = val;
                                _nameController.text = selectedItem.name;
                                _descriptionController.text = selectedItem.description;
                                _regularPriceController.text = selectedItem.price.toString();
                                _discountPriceController.text = selectedItem.discountPrice.toString();
                                _selectedCategoryId = selectedItem.categoryId;
                                _selectedDietaryType = selectedItem.vegType == 'VEG' 
                                    ? 'Vegetarian' 
                                    : (selectedItem.vegType == 'JAIN' ? 'Jain' : 'Non-Vegetarian');
                                _selectedAvailability = selectedItem.availability ? 'In Stock' : 'Out of Stock';
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date to Schedule
                  const Text('Date to Schedule', style: TextStyle(fontWeight: FontWeight.bold, color: inputLabelColor, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: _buildInputDecoration('dd/MM/yyyy').copyWith(
                      suffixIcon: const Icon(Icons.calendar_today, color: brandOrange, size: 18),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please select date' : null,
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, color: inputLabelColor, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: _buildInputDecoration('Select Category'),
                    items: widget.stateProvider.categories.map((cat) {
                      return DropdownMenuItem<int>(
                        value: cat.id,
                        child: Text(cat.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategoryId = val;
                      });
                    },
                    validator: (val) => val == null ? 'Please select category' : null,
                  ),
                  const SizedBox(height: 16),

                  // Dish Name Input
                  const Text('Dish Name', style: TextStyle(fontWeight: FontWeight.bold, color: inputLabelColor, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    decoration: _buildInputDecoration('e.g. Special Gujarati Thali'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter dish name' : null,
                  ),
                  const SizedBox(height: 16),

                  // Description Input
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, color: inputLabelColor, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: _buildInputDecoration('e.g. Includes rotis, paneer shaak, sweet, and dal...'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter description' : null,
                  ),
                  const SizedBox(height: 16),

                  // Dish Image Choose File Mock
                  const Text('Dish Image', style: TextStyle(fontWeight: FontWeight.bold, color: inputLabelColor, fontSize: 13)),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => _showImageSourceActionSheet(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // Container(
                          //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          //   decoration: BoxDecoration(
                          //     color: const Color(0xFFE5E7EB),
                          //     borderRadius: BorderRadius.circular(4),
                          //     border: Border.all(color: const Color(0xFFD1D5DB)),
                          //   ),
                          //   child: const Text(
                          //     'Choose file',
                          //     style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                          //   ),
                          // ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedImageName ?? 'No file chosen',
                              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.camera_alt_outlined, color: Color(0xFF9CA3AF), size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Regular & Discount Prices
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Regular Price (₹)', style: TextStyle(fontWeight: FontWeight.bold, color: inputLabelColor, fontSize: 13)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _regularPriceController,
                              keyboardType: TextInputType.number,
                              decoration: _buildInputDecoration('10.00'),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Required';
                                if (double.tryParse(val) == null) return 'Invalid price';
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
                            const Text('Discount Price (₹)', style: TextStyle(fontWeight: FontWeight.bold, color: inputLabelColor, fontSize: 13)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _discountPriceController,
                              keyboardType: TextInputType.number,
                              decoration: _buildInputDecoration('e.g. 8.50'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Dietary Type & Availability Dropdowns
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Dietary Type', style: TextStyle(fontWeight: FontWeight.bold, color: inputLabelColor, fontSize: 13)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _selectedDietaryType,
                              decoration: _buildInputDecoration('Vegetarian'),
                              style: const TextStyle(fontSize: 13, color: Colors.black),
                              items: const [
                                DropdownMenuItem(value: 'Vegetarian', child: Text('Vegetarian', style: TextStyle(fontSize: 13))),
                                DropdownMenuItem(value: 'Non-Vegetarian', child: Text('Non-Vegetarian', style: TextStyle(fontSize: 12))),
                                DropdownMenuItem(value: 'Jain', child: Text('Jain', style: TextStyle(fontSize: 13))),
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
                            const Text('Availability', style: TextStyle(fontWeight: FontWeight.bold, color: inputLabelColor, fontSize: 13)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _selectedAvailability,
                              decoration: _buildInputDecoration('In Stock'),
                              style: const TextStyle(fontSize: 13, color: Colors.black),
                              items: const [
                                DropdownMenuItem(value: 'In Stock', child: Text('In Stock', style: TextStyle(fontSize: 13))),
                                DropdownMenuItem(value: 'Out of Stock', child: Text('Out of Stock', style: TextStyle(fontSize: 12))),
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
                  const SizedBox(height: 16),

                  // Sort Order Input
                  const Text('Sort Order', style: TextStyle(fontWeight: FontWeight.bold, color: inputLabelColor, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _sortOrderController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration('1'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter sort order' : null,
                  ),
                  const SizedBox(height: 28),

                  // Create Item Action Button
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isLoading ? null : _handleCreateItem,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Create Item', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: Colors.white,
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
}
