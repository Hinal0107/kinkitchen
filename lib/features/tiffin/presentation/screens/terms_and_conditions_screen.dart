import 'package:flutter/material.dart';
import '../../../../repositories/subscription_repository.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  final SubscriptionRepository _repository = SubscriptionRepository();
  bool _isLoading = true;
  Map<String, dynamic>? _termsData;

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    try {
      final data = await _repository.getTermsAndConditions();
      if (mounted) {
        setState(() {
          _termsData = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF5E00);
    const Color restaurantGreen = Color(0xFF00A859);

    final List<Map<String, dynamic>> defaultSections = [
      {
        'id': 'free_trial',
        'title': '1. Free Trial / Initial Period Policy',
        'icon': Icons.card_giftcard,
        'content':
            'Newly registered customers can view tiffin menus, meals, and details for a specified free trial period (7 days). Once this free trial period expires, customers must purchase an active subscription plan to view subscription-related meal details or place meal orders.',
      },
      {
        'id': 'duration_validity',
        'title': '2. Subscription Duration & Pending Meals Expiry Rules',
        'icon': Icons.av_timer_rounded,
        'content':
            'Each subscription plan includes a specific meal count and a maximum validity window:\n\n'
            '• Weekly Subscription Plan: Includes 7 meals, with a maximum validity of 14 days from the plan start date.\n'
            '• Monthly Subscription Plan: Includes 30 meals, with a maximum validity of 60 days from the plan start date.\n\n'
            'If you have remaining/pending meals that are not ordered within the maximum validity duration (14 days for Weekly, 60 days for Monthly), your subscription plan will automatically expire, and all unused meals will be forfeited.',
      },
      {
        'id': 'reminders',
        'title': '3. Subscription Expiry Reminders',
        'icon': Icons.notifications_active_outlined,
        'content':
            'To help you complete your included meals on time, KinKitchen displays dynamic expiry warnings on your Plan screen and sends automated reminders 2 days prior to expiration (e.g., "Your plan will expire in 2 days.").',
      },
      {
        'id': 'addons_policy',
        'title': '4. Add-ons & Separate Payment Requirements',
        'icon': Icons.add_shopping_cart_rounded,
        'content':
            'Subscription plan pricing strictly includes only the meals defined within that plan. Any additional add-ons (side dishes, beverages, extra items) selected beyond the subscription meals are NOT included in the subscription price.\n\n'
            'Customers are required to make a separate payment for all add-ons and associated taxes or delivery fees during cart checkout.',
      },
      {
        'id': 'cancellations',
        'title': '5. Subscriptions Pause & Cancellation',
        'icon': Icons.pause_circle_outline,
        'content':
            'You may pause or cancel your subscription at any time. Pausing delays upcoming scheduled daily meal deliveries without sacrificing remaining meal validity days.',
      },
    ];

    final sections = (_termsData != null && _termsData!['sections'] is List)
        ? List<Map<String, dynamic>>.from((_termsData!['sections'] as List).map((s) => Map<String, dynamic>.from(s)))
        : defaultSections;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Banner Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.08),
                          restaurantGreen.withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.gavel_rounded, color: primaryColor, size: 24),
                            SizedBox(width: 10),
                            Text(
                              'Subscription Terms & Rules',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please review our backend-driven subscription policies regarding free trial access, meal validity, 14/60-day expiry windows, and separate add-on payments.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4B5563),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sections list
                  ...sections.map((sec) {
                    final String title = sec['title']?.toString() ?? 'Term';
                    final String content = sec['content']?.toString() ?? '';
                    final IconData icon = sec['icon'] is IconData
                        ? sec['icon'] as IconData
                        : Icons.article_outlined;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(icon, color: primaryColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Color(0xFFF3F4F6)),
                          const SizedBox(height: 12),
                          Text(
                            content,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF4B5563),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Last updated: August 2026 • KinKitchen Tiffin System',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
