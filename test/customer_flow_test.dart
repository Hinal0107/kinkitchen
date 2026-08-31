import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kinkitchen/shared/models/menu_item.dart';
import 'package:kinkitchen/shared/models/restaurant.dart';
import 'package:kinkitchen/modules/customer/tiffin_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Customer Flow & State Unit Tests', () {
    late TiffinStateProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      provider = TiffinStateProvider();
    });

    test('Initial cart is empty and calculations return correct zeros/defaults', () {
      expect(provider.cartItems.isEmpty, true);
      expect(provider.totalCartCount, 0);
      expect(provider.subtotal, 0.0);
      expect(provider.taxAmount, 0.0);
      expect(provider.deliveryFee, 0.0);
      expect(provider.total, 0.0);
    });

    test('Adding and removing cart items updates totals and item quantities', () {
      final item1 = MenuItem(
        id: 101,
        restaurantId: 1,
        categoryId: 1,
        name: 'Veg Deluxe Thali',
        description: 'Roti, Sabzi, Dal, Rice, Sweet',
        price: 12.50,
        discountPrice: 12.50,
        vegType: 'VEG',
        availability: true,
        status: 'ACTIVE',
      );

      final item2 = MenuItem(
        id: 102,
        restaurantId: 1,
        categoryId: 2,
        name: 'Gulab Jamun Extra',
        description: '2 pcs',
        price: 3.50,
        discountPrice: 3.50,
        vegType: 'VEG',
        availability: true,
        status: 'ACTIVE',
      );

      provider.addToCart(item1, quantity: 2);
      expect(provider.totalCartCount, 2);
      expect(provider.subtotal, 25.0);
      expect(provider.getItemQuantity(101), 2);

      provider.addToCart(item2, itemType: 'Add-on', quantity: 1);
      expect(provider.totalCartCount, 3);
      expect(provider.subtotal, 28.50);
      expect(provider.addonCartItems.length, 1);
      expect(provider.addonSubtotal, 3.50);

      // Tax = 5% of 28.50 = 1.425
      expect(provider.taxAmount, closeTo(1.425, 0.001));
      expect(provider.deliveryFee, 2.0);
      expect(provider.total, closeTo(31.925, 0.001));

      // Remove 1 quantity of item1
      provider.removeFromCart(item1);
      expect(provider.getItemQuantity(101), 1);
      expect(provider.totalCartCount, 2);

      // Clear cart
      provider.clearCart();
      expect(provider.cartItems.isEmpty, true);
    });

    test('Selecting restaurant clears previous restaurant cart items', () async {
      final restaurantA = Restaurant(
        id: 1,
        name: 'Kitchen A',
        email: 'kitchena@example.com',
        phone: '1234567890',
        description: 'Description A',
        address: 'Street 1',
        city: 'London',
        state: 'London',
        country: 'UK',
        pincode: 'E1 6AN',
        openingTime: '08:00',
        closingTime: '22:00',
        logoUrl: '',
        status: 'ACTIVE',
      );

      final restaurantB = Restaurant(
        id: 2,
        name: 'Kitchen B',
        email: 'kitchenb@example.com',
        phone: '0987654321',
        description: 'Description B',
        address: 'Street 2',
        city: 'London',
        state: 'London',
        country: 'UK',
        pincode: 'E2 6AN',
        openingTime: '08:00',
        closingTime: '22:00',
        logoUrl: '',
        status: 'ACTIVE',
      );

      final itemA = MenuItem(
        id: 201,
        restaurantId: 1,
        categoryId: 1,
        name: 'Thali A',
        description: 'Desc',
        price: 10.0,
        discountPrice: 10.0,
        vegType: 'VEG',
        availability: true,
        status: 'ACTIVE',
      );

      await provider.selectRestaurant(restaurantA);
      provider.addToCart(itemA);
      expect(provider.cartItems.length, 1);

      await provider.selectRestaurant(restaurantB);
      expect(provider.selectedRestaurantId, 2);
      expect(provider.cartItems.isEmpty, true);
    });
  });
}
