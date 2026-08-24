import 'package:flutter/material.dart';
import '../bloc/tiffin_state_provider.dart';
import 'dashboard_screen.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = TiffinStateScope.of(context);
    const Color customerOrange = Color(0xFFFF5E00);
    const Color restaurantGreen = Color(0xFF00A859);

    // 1. Initial State: No Restaurant Selected yet
    if (state.selectedRestaurantId == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('Subscription Plans', style: TextStyle(color: Color(0xFF1F2937))),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.store_outlined, size: 64, color: Color(0xFFD1D5DB)),
                const SizedBox(height: 16),
                const Text(
                  'No Restaurant Selected',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please select a restaurant from the Home tab to browse their subscription packages.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: customerOrange),
                  onPressed: () {
                    // Go to Home screen (tab index 0)
                    context.findAncestorStateOfType<DashboardScreenState>()?.setTab(0);
                  },
                  child: const Text('Browse Restaurants'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2. Loading State
    if (state.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: customerOrange),
        ),
      );
    }

    // 3. Error State
    if (state.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 52, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: customerOrange),
                  onPressed: () => state.fetchRestaurantDetails(state.selectedRestaurantId!),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () {
            context.findAncestorStateOfType<DashboardScreenState>()?.setTab(0);
          },
        ),
        title: const Text(
          'Subscription Plans',
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: state.subscriptionPlans.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Choose Your Plan',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Fresh, home-style meals delivered to your doorstep.\nFlexible and affordable.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 28),

                  // Map Plans
                  ...state.subscriptionPlans.map((plan) {
                    final bool isActive = state.activeSubscription == plan.title;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive ? customerOrange : const Color(0xFFE5E7EB),
                          width: isActive ? 2.5 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isActive ? customerOrange.withOpacity(0.06) : Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          plan.title,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${plan.mealsCount} Meals Package',
                                          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      textBaseline: TextBaseline.alphabetic,
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      children: [
                                        Text(
                                          '₹${plan.price.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: isActive ? customerOrange : const Color(0xFF1F2937),
                                          ),
                                        ),
                                        Text(
                                          '/${plan.duration.toLowerCase()}',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const Divider(color: Color(0xFFF3F4F6)),
                                const SizedBox(height: 16),

                                // Feature Details list
                                _buildBulletRow(restaurantGreen, 'Duration: ${plan.duration}'),
                                _buildBulletRow(restaurantGreen, 'Total: ${plan.mealsCount} Meals'),
                                _buildBulletRow(restaurantGreen, 'Meal Type: ${plan.mealType}'),
                                _buildBulletRow(restaurantGreen, 'Taxes/Discounts: ${plan.taxesAndDisc}'),
                                
                                const SizedBox(height: 20),

                                // Subscribe Button
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isActive ? restaurantGreen : customerOrange,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () {
                                      if (isActive) {
                                        state.cancelSubscription();
                                      } else {
                                        state.subscribeToPlan(plan);
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Subscribed!'),
                                            content: Text('You have successfully subscribed to the ${plan.title}!'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      isActive ? 'Active Subscription (Cancel)' : 'Subscribe Now',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (plan.isPopular)
                            Positioned(
                              top: -12,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: customerOrange,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'POPULAR',
                                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildBulletRow(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: color, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.card_membership_outlined, size: 56, color: Color(0xFFD1D5DB)),
            const SizedBox(height: 16),
            Text(
              'No Subscription Plans Found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 8),
            Text(
              'This restaurant has not configured any subscription meal plans yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}
