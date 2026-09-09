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

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
    _checkSession();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
              const Color(0xFFFF5E00).withOpacity(0.04),
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
                
                // Animated Branding Logo with Pulse & Glow
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft orange background aura
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFF5E00).withValues(alpha: 0.06),
                              // borderRadius: 40,
                            ),
                          ),
                        ),
                        const KinKitchenLogo(
                          size: 180,
                          showText: true,
                          subtitle: 'Fresh food, delivered fast to your door.',
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Actions with Slide & Fade Transition
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomButton(
                          text: 'Get Started',
                          suffixIcon: Icons.arrow_forward,
                          onPressed: () {
                            Navigator.pushNamed(context, '/role-selection');
                          },
                        ),
                        const SizedBox(height: 40),
                      ],
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
