import 'package:flutter/material.dart';
import '../bloc/tiffin_state_provider.dart';
import 'dashboard_screen.dart';
import '../../../../models/subscription_plan.dart';

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
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1F2937)),
            onPressed: () {},
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
          // Active Subscription Status Banner
          if (activeSub != null) ...[
            _buildActiveSubscriptionCard(context, activeSub, brandOrange, brandGreen, state),
            const SizedBox(height: 24),
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
                      if (isActive) {
                        state.cancelSubscription();
                      } else {
                        state.subscribeToPlan(plan);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Subscribed to ${plan.title}!')),
                        );
                      }
                    },
                    child: Text(
                      isActive ? 'Active Plan (Cancel)' : (isBestValue ? 'Subscribe Now' : 'Select Plan'),
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
                        SnackBar(content: Text('Subscribed to $title!')),
                      );
                    },
                    child: Text(
                      isBestValue ? 'Subscribe Now' : 'Select Plan',
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

  Widget _buildActiveSubscriptionCard(
    BuildContext context,
    dynamic activeSub,
    Color brandOrange,
    Color brandGreen,
    TiffinStateProvider state,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brandGreen, width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Plan: ${activeSub.plan?.title ?? state.activeSubscription}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  activeSub.status.toUpperCase(),
                  style: TextStyle(color: brandGreen, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Remaining Meals: ${activeSub.remainingMeals} / ${activeSub.totalMeals}', style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
        ],
      ),
    );
  }
}
