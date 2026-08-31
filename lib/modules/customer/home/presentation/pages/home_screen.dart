import 'package:flutter/material.dart';
import 'package:kinkitchen/modules/customer/tiffin_state_provider.dart';
import 'package:kinkitchen/modules/customer/home/presentation/pages/dashboard_screen.dart';
import 'package:kinkitchen/shared/models/menu_item.dart';
import 'package:kinkitchen/app/constants/api_constants.dart';

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
    final state = TiffinStateScope.of(context);
    if (!_hasFetchedInitialData) {
      _hasFetchedInitialData = true;
      Future.microtask(() => state.fetchSelectedRestaurantData());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = TiffinStateScope.of(context);
    const Color brandOrange = Color(0xFFFF5E00);

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
              'DELIVERING TO',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/restaurant-selection'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      state.selectedAddress != null
                          ? '${state.selectedAddress!.line1}, ${state.selectedAddress!.city}'
                          : (state.selectedRestaurant != null
                              ? '${state.selectedRestaurant!.name}, ${state.selectedRestaurant!.city}'
                              : 'Select Location'),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1F2937), size: 18),
                ],
              ),
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
          IconButton(
            tooltip: 'Change Kitchen',
            icon: Icon(Icons.storefront_outlined, color: brandOrange),
            onPressed: () => Navigator.pushNamed(context, '/restaurant-selection'),
          ),
        ],
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, TiffinStateProvider state) {
    const Color brandOrange = Color(0xFFFF5E00);

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
                'Please Select a Kitchen First',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select your preferred kitchen to view available meals and add-ons.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => Navigator.pushNamed(context, '/restaurant-selection'),
                icon: const Icon(Icons.location_on, color: Colors.white),
                label: const Text('Browse Kitchens', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: brandOrange),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 52, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: brandOrange),
                onPressed: () => state.fetchSelectedRestaurantData(),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Today's Meal Section Header
          const Text(
            "Today's Meal",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),

          if (state.todayMeals.isEmpty)
            _buildEmptySection('No Today\'s Meal available today')
          else
            ...state.todayMeals.map((meal) => _buildHeroMealCard(
                  context,
                  state,
                  meal: meal,
                  buttonText: 'Add to Cart',
                  buttonColor: brandOrange,
                  itemType: 'Today Meal',
                )),

          const SizedBox(height: 24),

          // 2. Tomorrow's Menu Section Header
          const Text(
            "Tomorrow's Menu",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),

          if (state.tomorrowMeals.isEmpty)
            _buildEmptySection('No Tomorrow\'s Menu published yet')
          else
            ...state.tomorrowMeals.map((meal) => _buildHeroMealCard(
                  context,
                  state,
                  meal: meal,
                  buttonText: 'Pre-order Now',
                  buttonColor: const Color(0xFFE5E7EB),
                  buttonTextColor: const Color(0xFF374151),
                  itemType: 'Tomorrow Meal',
                )),

          const SizedBox(height: 24),

          // 3. Add-ons Section Header
          const Text(
            "Add-ons",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),

          _buildHorizontalAddonsList(context, state),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
        ),
      ),
    );
  }

  // Hero Card matching Screen 1 in design image
  Widget _buildHeroMealCard(
    BuildContext context,
    TiffinStateProvider state, {
    required MenuItem meal,
    required String buttonText,
    required Color buttonColor,
    Color buttonTextColor = Colors.white,
    required String itemType,
  }) {
    final imageUrl = ApiConfig.getFormattedImageUrl(meal.imageUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 160,
              width: double.infinity,
              color: const Color(0xFFF3F4F6),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.restaurant_outlined, size: 48, color: Color(0xFFFF5E00)),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.restaurant_outlined, size: 48, color: Color(0xFFFF5E00)),
                    ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        meal.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    Text(
                      '£${meal.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
                if (meal.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    meal.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 14),

                // Full-width Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: buttonTextColor,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.center,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      state.addToCart(meal, itemType: itemType, quantity: 1);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                    icon: Icon(
                      buttonText == 'Add to Cart' ? Icons.shopping_cart_outlined : Icons.calendar_today_outlined,
                      size: 18,
                    ),
                    label: Text(
                      buttonText,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Horizontal Add-ons List matching Screen 1 in design image
  Widget _buildHorizontalAddonsList(BuildContext context, TiffinStateProvider state) {
    const Color greenBtn = Color(0xFF00A859);

    if (state.addons.isEmpty) {
      return _buildEmptySection('No add-ons currently available.');
    }

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.addons.length,
        itemBuilder: (context, index) {
          final addon = state.addons[index];
          final imageUrl = ApiConfig.getFormattedImageUrl(addon.imageUrl);

          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Box
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    color: const Color(0xFFF3F4F6),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(Icons.fastfood, size: 28, color: greenBtn),
                          )
                        : Icon(Icons.fastfood, size: 28, color: greenBtn),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  addon.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1F2937)),
                ),
                Text(
                  '£${addon.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 28,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenBtn,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.center,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      state.addToCart(addon, itemType: 'Add-on', quantity: 1);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                    child: const Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
