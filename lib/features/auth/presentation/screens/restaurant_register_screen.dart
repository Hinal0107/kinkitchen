import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class RestaurantRegisterScreen extends StatefulWidget {
  const RestaurantRegisterScreen({super.key});

  @override
  State<RestaurantRegisterScreen> createState() => _RestaurantRegisterScreenState();
}

class _RestaurantRegisterScreenState extends State<RestaurantRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers: Basic Info
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Controllers: Bank Details
  final _bankHolderController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _bankIfscController = TextEditingController();
  final _bankBranchController = TextEditingController();

  bool _isLoading = false;
  final AuthBloc _authBloc = AuthBloc();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _postcodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bankHolderController.dispose();
    _bankAccountController.dispose();
    _bankIfscController.dispose();
    _bankBranchController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final state = await _authBloc.registerRestaurant(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        postcode: _postcodeController.text.trim(),
        password: _passwordController.text,
        bankHolderName: _bankHolderController.text.trim(),
        bankAccountNumber: _bankAccountController.text.trim(),
        bankIfscCode: _bankIfscController.text.trim(),
        bankBranchName: _bankBranchController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (state is AuthAuthenticated) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Partner Registered'),
            content: const Text('Thank you! Your KinKitchen merchant account has been registered and you have been logged in successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushNamedAndRemoveUntil(context, '/restaurant-dashboard', (route) => false);
                },
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        );
      } else if (state is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color restaurantGreen = Color(0xFF00A859);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'KinKitchen Portal',
          style: TextStyle(
            color: restaurantGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Register Restaurant',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Join KinKitchen and start reaching more customers.',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),

                // Section: Basic Info
                Row(
                  children: const [
                    Text(
                      'Basic Info',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                  ],
                ),
                const SizedBox(height: 16),

                // Restaurant Name
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Restaurant Name',
                  hintText: 'e.g. Green Garden Kitchen',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter restaurant name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Email Address
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email Address',
                  hintText: 'manager@restaurant.com',
                  prefixIcon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Phone Number
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Phone Number',
                  hintText: 'e.g. +1 (555) 000-0000',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Full Address
                CustomTextField(
                  controller: _addressController,
                  labelText: 'Full Address',
                  hintText: 'Street, Building, Suite',
                  prefixIcon: Icons.location_on_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter restaurant address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Postcode
                CustomTextField(
                  controller: _postcodeController,
                  labelText: 'Postcode',
                  hintText: 'e.g. 12345',
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter postcode';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Password
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Confirm Password
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  hintText: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Section: Bank Details
                Row(
                  children: const [
                    Text(
                      'Bank Details',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                  ],
                ),
                const SizedBox(height: 16),

                // Account Holder Name
                CustomTextField(
                  controller: _bankHolderController,
                  labelText: 'Account Holder Name',
                  hintText: 'Enter name on bank account',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter holder name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Account Number
                CustomTextField(
                  controller: _bankAccountController,
                  labelText: 'Account Number',
                  hintText: 'Enter account number',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter account number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // IFSC Code
                CustomTextField(
                  controller: _bankIfscController,
                  labelText: 'IFSC Code',
                  hintText: 'e.g. SBIN0001234',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter IFSC code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Branch Name
                CustomTextField(
                  controller: _bankBranchController,
                  labelText: 'Branch Name',
                  hintText: 'e.g. Downtown Main Branch',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter branch name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 36),

                // Register Button (Green)
                CustomButton(
                  text: 'Register Restaurant',
                  backgroundColor: restaurantGreen,
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 20),

                // Policy Text
                const Text(
                  'By registering, you agree to our Terms & Conditions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
