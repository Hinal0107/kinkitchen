import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  State<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  final AuthBloc _authBloc = AuthBloc();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postcodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final state = await _authBloc.registerCustomer(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        postcode: _postcodeController.text.trim(),
        password: _passwordController.text,
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
            title: const Text('Account Created'),
            content: const Text('Your KinKitchen account was successfully created and you have been logged in!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
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
          'KinKitchen',
          style: TextStyle(
            color: Color(0xFFFF5E00),
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
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Join KinKitchen for fresh, fast delivery.',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),

                // Full Name
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  hintText: 'John Doe',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Email Address
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email Address',
                  hintText: 'john@example.com',
                  prefixIcon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
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
                  hintText: '+1 (555) 000-0000',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Section: Delivery Details
                Row(
                  children: const [
                    Text(
                      'Delivery Details',
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

                // Street Address
                CustomTextField(
                  controller: _addressController,
                  labelText: 'Street Address',
                  hintText: '123 Main St, Apt 4B',
                  prefixIcon: Icons.home_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your street address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // City & Postcode (Row)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomTextField(
                        controller: _cityController,
                        labelText: 'City',
                        hintText: 'Cityville',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: _postcodeController,
                        labelText: 'Postcode',
                        hintText: '12345',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Section: Password
                Row(
                  children: const [
                    Text(
                      'Security',
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
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 36),

                // Submit Button
                CustomButton(
                  text: 'Create Account',
                  suffixIcon: Icons.arrow_forward,
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 20),

                // Back to Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/customer-login');
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: Color(0xFFFF5E00),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
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
