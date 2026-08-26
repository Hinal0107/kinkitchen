import 'package:flutter/material.dart';
import '../bloc/restaurant_state_provider.dart';

class RestaurantAddPlanScreen extends StatefulWidget {
  final RestaurantStateProvider stateProvider;
  final Map<String, dynamic>? existingPlan;
  final bool isEdit;

  const RestaurantAddPlanScreen({
    super.key,
    required this.stateProvider,
    this.existingPlan,
    this.isEdit = false,
  });

  @override
  State<RestaurantAddPlanScreen> createState() => _RestaurantAddPlanScreenState();
}

class _RestaurantAddPlanScreenState extends State<RestaurantAddPlanScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _mealTypeController = TextEditingController(text: 'Lunch');
  final _durationValueController = TextEditingController(text: '1');
  final _mealsPerDayController = TextEditingController(text: '1');
  final _totalMealsController = TextEditingController();
  final _startDateController = TextEditingController();

  String _selectedDurationType = 'Month(s)';
  String _selectedFrequency = 'Daily (Mon-Sun)';
  DateTime? _selectedStartDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.existingPlan != null) {
      final plan = widget.existingPlan!;
      _nameController.text = plan['title']?.toString() ?? plan['name']?.toString() ?? '';
      _descriptionController.text = plan['description']?.toString() ?? '';
      final pVal = plan['price'];
      if (pVal != null) {
        final dPrice = (pVal is num) ? pVal.toDouble() : (double.tryParse(pVal.toString()) ?? 0.0);
        if (dPrice > 0) _priceController.text = dPrice.toStringAsFixed(2);
      }
      _mealTypeController.text = plan['mealType']?.toString() ?? plan['meal_type']?.toString() ?? 'Lunch';
      _durationValueController.text = plan['duration_value']?.toString() ?? '1';
      _mealsPerDayController.text = plan['meals_per_day']?.toString() ?? '1';
      _totalMealsController.text = plan['total_meals']?.toString() ?? plan['meals']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '';
      
      final String rawDurType = plan['duration_type']?.toString() ?? plan['duration']?.toString() ?? '';
      if (rawDurType.toLowerCase().contains('week')) {
        _selectedDurationType = 'Week(s)';
      } else if (rawDurType.toLowerCase().contains('day')) {
        _selectedDurationType = 'Day(s)';
      } else {
        _selectedDurationType = 'Month(s)';
      }

      final String rawFreq = plan['delivery_frequency']?.toString() ?? '';
      if (rawFreq.isNotEmpty) {
        if (rawFreq.toLowerCase().contains('weekday')) {
          _selectedFrequency = 'Weekdays (Mon-Fri)';
        } else if (rawFreq.toLowerCase().contains('alternate')) {
          _selectedFrequency = 'Alternate Days';
        } else {
          _selectedFrequency = 'Daily (Mon-Sun)';
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _mealTypeController.dispose();
    _durationValueController.dispose();
    _mealsPerDayController.dispose();
    _totalMealsController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF15A22),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
        _startDateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _handleSavePlan() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final name = _nameController.text.trim();
        final description = _descriptionController.text.trim();
        final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
        final mealType = _mealTypeController.text.trim();
        final durationValue = int.tryParse(_durationValueController.text.trim()) ?? 1;
        final mealsPerDay = int.tryParse(_mealsPerDayController.text.trim()) ?? 1;
        final totalMeals = int.tryParse(_totalMealsController.text.trim()) ?? (durationValue * 30 * mealsPerDay);

        if (widget.isEdit && widget.existingPlan != null && widget.existingPlan!['id'] != null) {
          final int planId = widget.existingPlan!['id'];
          await widget.stateProvider.updateCustomSubscriptionPlan(
            planId,
            name: name,
            description: description,
            price: price,
            mealType: mealType,
            durationValue: durationValue,
            durationType: _selectedDurationType,
            mealsPerDay: mealsPerDay,
            totalMeals: totalMeals,
            deliveryFrequency: _selectedFrequency,
            startsOn: _startDateController.text.trim(),
          );
        } else {
          await widget.stateProvider.createCustomSubscriptionPlan(
            name: name,
            description: description,
            price: price,
            mealType: mealType,
            durationValue: durationValue,
            durationType: _selectedDurationType,
            mealsPerDay: mealsPerDay,
            totalMeals: totalMeals,
            deliveryFrequency: _selectedFrequency,
            startsOn: _startDateController.text.trim(),
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isEdit ? 'Subscription plan updated successfully!' : 'Subscription plan created successfully!'),
              backgroundColor: const Color(0xFF00A859),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save plan: $e'),
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
          widget.isEdit ? 'Edit Subscription Plan' : 'Create Subscription Plan',
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
                // 1. Plan Name
                _buildFieldLabel('Plan Name'),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 14),
                  decoration: _buildInputDecoration('e.g. Monthly Gujarati Lunch Box'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter plan name' : null,
                ),
                const SizedBox(height: 16),

                // 2. Description
                _buildFieldLabel('Description'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14),
                  decoration: _buildInputDecoration('e.g. Traditional lunch delivered Mon-Fri'),
                ),
                const SizedBox(height: 16),

                // 3. Price (£) & Meal Type Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Price (£)'),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(fontSize: 14),
                            decoration: _buildInputDecoration('150.00'),
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
                          _buildFieldLabel('Meal Type'),
                          TextFormField(
                            controller: _mealTypeController,
                            style: const TextStyle(fontSize: 14),
                            decoration: _buildInputDecoration('e.g. lunch, dinner'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 4. Duration Value & Duration Type Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Duration Value'),
                          TextFormField(
                            controller: _durationValueController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 14),
                            decoration: _buildInputDecoration('1'),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Enter value';
                              if (int.tryParse(val.trim()) == null) return 'Invalid number';
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
                          _buildFieldLabel('Duration Type'),
                          DropdownButtonFormField<String>(
                            value: _selectedDurationType,
                            isExpanded: true,
                            style: const TextStyle(fontSize: 13.5, color: Color(0xFF1F2937)),
                            decoration: _buildInputDecoration('Month(s)'),
                            items: const [
                              DropdownMenuItem(value: 'Month(s)', child: Text('Month(s)')),
                              DropdownMenuItem(value: 'Week(s)', child: Text('Week(s)')),
                              DropdownMenuItem(value: 'Day(s)', child: Text('Day(s)')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedDurationType = val;
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

                // 5. Meals Per Day & Total Meals Included Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Meals Per Day'),
                          TextFormField(
                            controller: _mealsPerDayController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 14),
                            decoration: _buildInputDecoration('1'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Total Meals Included'),
                          TextFormField(
                            controller: _totalMealsController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 14),
                            decoration: _buildInputDecoration('e.g. 20 or 30'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 6. Delivery Frequency & Starts On (Optional) Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Delivery Frequency'),
                          DropdownButtonFormField<String>(
                            value: _selectedFrequency,
                            isExpanded: true,
                            style: const TextStyle(fontSize: 13.5, color: Color(0xFF1F2937)),
                            decoration: _buildInputDecoration('Daily (Mon-Sun)'),
                            items: const [
                              DropdownMenuItem(value: 'Daily (Mon-Sun)', child: Text('Daily (Mon-Sun)')),
                              DropdownMenuItem(value: 'Weekdays (Mon-Fri)', child: Text('Weekdays (Mon-Fri)')),
                              DropdownMenuItem(value: 'Alternate Days', child: Text('Alternate Days')),
                              DropdownMenuItem(value: 'Custom', child: Text('Custom')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedFrequency = val;
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
                          _buildFieldLabel('Starts On (Optional)'),
                          TextFormField(
                            controller: _startDateController,
                            readOnly: true,
                            onTap: () => _selectStartDate(context),
                            style: const TextStyle(fontSize: 13.5, color: Color(0xFF1F2937)),
                            decoration: _buildInputDecoration(
                              'dd/mm/yyyy',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF6B7280)),
                                onPressed: () => _selectStartDate(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 7. Submit Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _handleSavePlan,
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
                            widget.isEdit ? 'Update Plan' : 'Create Plan',
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
