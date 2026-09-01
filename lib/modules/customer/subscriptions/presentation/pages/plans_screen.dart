import 'package:flutter/material.dart';
import 'package:kinkitchen/modules/customer/tiffin_state_provider.dart';
import 'package:kinkitchen/modules/customer/home/presentation/pages/dashboard_screen.dart';
import 'package:kinkitchen/shared/models/subscription_plan.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = TiffinStateScope.of(context);
    const Color brandOrange = Color(0xFFFF5E00);
    const Color brandGreen = Color(0xFF00A859);
    final activeSub = state.activeSubscriptionDetails;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'LOCATION',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_outlined, color: brandOrange, size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    state.selectedRestaurant != null
                        ? '${state.selectedRestaurant!.name}, ${state.selectedRestaurant!.city}'
                        : 'Current Location',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: 'Notifications',
                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1F2937)),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
              if (state.unreadNotificationCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5E00),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${state.unreadNotificationCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _buildBody(context, state, activeSub, brandOrange, brandGreen),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TiffinStateProvider state,
    dynamic activeSub,
    Color brandOrange,
    Color brandGreen,
  ) {
    if (state.selectedRestaurantId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront, size: 64, color: brandOrange),
              const SizedBox(height: 16),
              const Text(
                'No Kitchen Selected',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please select a kitchen from Home tab to browse subscription plans.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: brandOrange),
                onPressed: () {
                  context.findAncestorStateOfType<DashboardScreenState>()?.setTab(0);
                },
                child: const Text('Browse Kitchens', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // "My Subscription" Feature Card matching user design screenshot
          if (activeSub != null || state.activeSubscription != 'None') ...[
            _buildMySubscriptionHeaderAndCard(context, state, activeSub, brandOrange),
            const SizedBox(height: 28),
          ],

          // Title & Subtitle Header matching Screen 3 in design image
          const Text(
            'Choose Your Plan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Fresh, home-style meals delivered to your doorstep.\nFlexible and affordable.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 24),

          // Plan Cards list
          if (state.subscriptionPlans.isNotEmpty)
            ...state.subscriptionPlans.map((plan) => _buildPlanCard(context, state, plan, brandOrange, brandGreen))
          else ...[
            // Default mock plans matching design screenshot if API plans list is empty
            _buildMockPlanCard(
              context,
              state,
              title: 'Weekly Plan',
              subtitle: '7 Days of Meals',
              price: '£49',
              period: '/week',
              isBestValue: false,
              features: ['1 Meal / Day', 'Standard Menu', 'No Weekend Delivery'],
              brandOrange: brandOrange,
              brandGreen: brandGreen,
            ),
            _buildMockPlanCard(
              context,
              state,
              title: 'Monthly Plan',
              subtitle: '30 Days of Meals',
              price: '£180',
              period: '/month',
              isBestValue: true,
              features: ['Save 10% overall', 'Flexible Delivery (Pause anytime)', 'Premium Menu Options', 'Weekend Delivery Included'],
              brandOrange: brandOrange,
              brandGreen: brandGreen,
            ),
            _buildMockPlanCard(
              context,
              state,
              title: '15 Days Plan',
              subtitle: 'Half-month coverage',
              price: '£99',
              period: '/15 days',
              isBestValue: false,
              features: ['Standard Menu Options', 'Save 5%', 'No Weekend Delivery'],
              brandOrange: brandOrange,
              brandGreen: brandGreen,
            ),
          ],

          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4B5563),
              side: const BorderSide(color: Color(0xFFD1D5DB)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pushNamed(context, '/terms-and-conditions'),
            icon: const Icon(Icons.gavel_outlined, size: 18),
            label: const Text(
              'View Subscription Terms & Conditions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    TiffinStateProvider state,
    SubscriptionPlan plan,
    Color brandOrange,
    Color brandGreen,
  ) {
    final bool isActive = state.activeSubscription == plan.title;
    final bool isBestValue = plan.isPopular;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? brandOrange : (isBestValue ? brandOrange : const Color(0xFFE5E7EB)),
          width: isBestValue || isActive ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${plan.mealsCount} Days of Meals',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '£${plan.price.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                        ),
                        Text(
                          '/${plan.duration.toLowerCase()}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildCheckRow(brandGreen, '${plan.mealsCount} Meal / Day'),
                _buildCheckRow(brandGreen, 'Flexible Delivery (Pause anytime)'),
                _buildCheckRow(brandGreen, 'Max Validity Window: ${plan.maxValidityDays} Days'),

                const SizedBox(height: 18),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isBestValue || isActive ? brandOrange : const Color(0xFFF3F4F6),
                      foregroundColor: isBestValue || isActive ? Colors.white : const Color(0xFF374151),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      if (isActive || (state.hasActiveSubscription && state.remainingSubscriptionMeals > 0)) {
                        _showActiveSubscriptionNoticeDialog(context, state);
                      } else {
                        try {
                          state.subscribeToPlan(plan);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Successfully subscribed to ${plan.title}! Valid for daily use.'),
                              backgroundColor: brandGreen,
                            ),
                          );
                        } catch (e) {
                          _showActiveSubscriptionNoticeDialog(context, state);
                        }
                      }
                    },
                    child: Text(
                      isActive
                          ? 'Current Active Plan'
                          : (state.hasActiveSubscription && state.remainingSubscriptionMeals > 0
                              ? 'Plan Active (Use Daily)'
                              : (isBestValue ? 'Subscribe Now' : 'Select Plan')),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isBestValue)
            Positioned(
              top: -12,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: brandOrange),
                ),
                child: const Text(
                  'BEST VALUE',
                  style: TextStyle(color: Colors.deepOrange, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showActiveSubscriptionNoticeDialog(BuildContext context, TiffinStateProvider state) {
    final activeSub = state.activeSubscriptionDetails;
    final String planName = activeSub?.plan?.title ?? state.activeSubscription;
    final int remaining = state.remainingSubscriptionMeals;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.stars_rounded, color: Color(0xFF00A859), size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Active Subscription Running',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          'You already have an active "$planName" subscription with $remaining meals remaining.\n\n'
          'Per Terms & Conditions, you do NOT need to purchase a new plan every day. You can continue using your current subscription every day until all meals are completed or expired.',
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF374151), height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK, Got it', style: TextStyle(color: Color(0xFFFF5E00), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMockPlanCard(
    BuildContext context,
    TiffinStateProvider state, {
    required String title,
    required String subtitle,
    required String price,
    required String period,
    required bool isBestValue,
    required List<String> features,
    required Color brandOrange,
    required Color brandGreen,
  }) {
    final bool isActive = state.activeSubscription == title;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBestValue ? brandOrange : const Color(0xFFE5E7EB),
          width: isBestValue ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          price,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                        ),
                        Text(
                          period,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...features.map((f) => _buildCheckRow(brandGreen, f)),

                const SizedBox(height: 18),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isBestValue ? brandOrange : const Color(0xFFF3F4F6),
                      foregroundColor: isBestValue ? Colors.white : const Color(0xFF374151),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      if (isActive || (state.hasActiveSubscription && state.remainingSubscriptionMeals > 0)) {
                        _showActiveSubscriptionNoticeDialog(context, state);
                      } else {
                        try {
                          state.subscribeToPlan(SubscriptionPlan(
                            id: 1,
                            restaurantId: state.selectedRestaurantId ?? 1,
                            title: title,
                            price: 180.0,
                            duration: period,
                            mealsCount: 30,
                            mealType: 'Veg',
                            taxesAndDisc: '',
                            isPopular: isBestValue,
                            status: 'ACTIVE',
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Successfully subscribed to $title! Valid for daily use.'),
                              backgroundColor: brandGreen,
                            ),
                          );
                        } catch (e) {
                          _showActiveSubscriptionNoticeDialog(context, state);
                        }
                      }
                    },
                    child: Text(
                      isActive
                          ? 'Current Active Plan'
                          : (state.hasActiveSubscription && state.remainingSubscriptionMeals > 0
                              ? 'Plan Active (Use Daily)'
                              : (isBestValue ? 'Subscribe Now' : 'Select Plan')),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isBestValue)
            Positioned(
              top: -12,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: brandOrange),
                ),
                child: const Text(
                  'BEST VALUE',
                  style: TextStyle(color: Colors.deepOrange, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckRow(Color iconColor, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMySubscriptionHeaderAndCard(
    BuildContext context,
    TiffinStateProvider state,
    dynamic activeSub,
    Color brandOrange,
  ) {
    final String planTitle = (activeSub?.plan?.title ?? state.activeSubscription ?? 'HOME THALI').toString().toUpperCase();
    final int totalCount = activeSub?.totalMeals ?? 27;
    final int usedCount = activeSub?.usedMeals ?? 27;
    final int remainingCount = activeSub?.remainingMeals ?? 0;
    final int daysCount = activeSub?.maxValidityDays ?? 20;
    final String priceStr = activeSub?.plan != null
        ? '£${activeSub.plan!.price.toStringAsFixed(0)}'
        : '₹1';
    final String expireDate = activeSub?.endDate ?? activeSub?.maxValidityDate ?? '05 Mar 2025';

    return Column(
      children: [
        // Title Header: "My Subscription" with accent red/orange color & Log Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                children: [
                  TextSpan(text: 'My ', style: TextStyle(color: Color(0xFFEF4444))),
                  TextSpan(text: 'Subscription', style: TextStyle(color: Color(0xFF1F2937))),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening Subscription History...')),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.receipt_long_outlined, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Main Subscription Card matching user design image
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD6C2), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF5E00).withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Header with Red Ribbon Badge Tag, Thali & Days, and Price
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    // Red Ribbon Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                          topRight: Radius.circular(4),
                          bottomLeft: Radius.circular(4),
                        ),
                      ),
                      child: Text(
                        planTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Plan Details text
                    Expanded(
                      child: Text(
                        '$totalCount Thali\'s | $daysCount Day\'s',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                    // Price
                    Text(
                      priceStr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),

              // 3 Circular Stat Widgets (Total, Used, Remaining)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2EC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildStatGauge('Total', totalCount),
                    const SizedBox(width: 10),
                    _buildStatGauge('Used', usedCount),
                    const SizedBox(width: 10),
                    _buildStatGauge('Remaining', remainingCount),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Bottom Expiration Pill Button
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFFC7B2), width: 1.2),
                  ),
                  child: Text(
                    'Expire on $expireDate',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatGauge(String title, int count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Circular Ring with Red Number in Center
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFAFAFA),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 3),
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
