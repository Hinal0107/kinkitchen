import 'package:flutter/material.dart';
import '../bloc/tiffin_state_provider.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasFetchedInitialData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Auto-fetch restaurants from API when screen loads
    final state = TiffinStateScope.of(context);
    if (!_hasFetchedInitialData && !state.isLoading && state.errorMessage == null) {
      _hasFetchedInitialData = true;
      Future.microtask(() => state.fetchRestaurants());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = TiffinStateScope.of(context);
    const Color customerOrange = Color(0xFFFF5E00);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'KinKitchen - Tiffin Delivery',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: customerOrange),
            onPressed: () => state.fetchRestaurants(),
          ),
        ],
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, TiffinStateProvider state) {
    const Color customerOrange = Color(0xFFFF5E00);

    // 1. Loading State
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: customerOrange),
      );
    }

    // 2. Error State
    if (state.errorMessage != null) {
      return Center(
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
                onPressed: () => state.fetchRestaurants(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Empty State (DATABASE IS COMPLETELY EMPTY)
    if (state.restaurants.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: customerOrange.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.restaurant_outlined, size: 56, color: customerOrange),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Restaurants Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'There are currently no active restaurants available on our database. Please check again later.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: customerOrange),
                onPressed: () => state.fetchRestaurants(),
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Success State (Real API Data UI)
    return RefreshIndicator(
      color: customerOrange,
      onRefresh: () => state.fetchRestaurants(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: state.restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = state.restaurants[index];

          return GestureDetector(
            onTap: () {
              // Fetch categories and menus for selected restaurant
              state.fetchRestaurantDetails(restaurant.id);
              // Switch tab programmatically to Menu (Index 1)
              context.findAncestorStateOfType<DashboardScreenState>()?.setTab(1);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Logo Placeholder
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: customerOrange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.storefront_outlined, color: customerOrange, size: 28),
                  ),
                  const SizedBox(width: 16),

                  // Restaurant Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          restaurant.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${restaurant.address}, ${restaurant.city}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 18),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
