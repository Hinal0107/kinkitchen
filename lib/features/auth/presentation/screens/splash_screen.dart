import 'package:flutter/material.dart';
import '../../../../core/widgets/kinkitchen_logo.dart';
import '../../../../core/widgets/custom_button.dart';
import 'package:kinkitchen/shared/services/auth_service.dart';
import 'package:kinkitchen/shared/services/fcm_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  double _scale = 0.8;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Soft entrance animation
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    });
    _checkSession();
  }

  Future<void> _checkSession() async {
    final String? role = await _authService.getStoredRole();
    if (role != null) {
      try {
        final user = await _authService.getCurrentUser();
        
        // Sync FCM token with backend on successful session restore
        try {
          final fcmToken = await FcmService().getFcmToken();
          if (fcmToken != null) {
            await FcmService().syncTokenWithBackend(fcmToken);
          }
        } catch (e) {
          debugPrint('Error syncing FCM token on session restore: $e');
        }

        if (!mounted) return;
        if (user.role == 'customer') {
          Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
        } else if (user.role == 'restaurant') {
          Navigator.pushNamedAndRemoveUntil(context, '/restaurant-dashboard', (route) => false);
        }
      } catch (e) {
        await _authService.logout();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              const Color(0xFFFF5E00).withOpacity(0.03),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 40),
                
                // Animated Branding Logo
                AnimatedScale(
                  scale: _scale,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOutBack,
                  child: AnimatedOpacity(
                    opacity: _opacity,
                    duration: const Duration(milliseconds: 800),
                    child: const KinKitchenLogo(
                      size: 180,
                      showText: true,
                      subtitle: 'Fresh food, delivered fast to your door.',
                    ),
                  ),
                ),
                
                // Actions
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomButton(
                      text: 'Get Started',
                      suffixIcon: Icons.arrow_forward,
                      onPressed: () {
                        Navigator.pushNamed(context, '/role-selection');
                      },
                    ),
                    const SizedBox(height: 20),
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
                            Navigator.pushNamed(context, '/customer-login');
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
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
