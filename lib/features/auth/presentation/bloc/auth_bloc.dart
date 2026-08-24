import '../../../../services/auth_service.dart';
import '../../../../models/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Concrete AuthBloc mapping auth requests directly to the Firebase & Laravel API.
class AuthBloc {
  final AuthService _authService = AuthService();
  
  AuthState _state = AuthInitial();
  AuthState get state => _state;

  // Sign in flow for both customer and restaurant
  Future<AuthState> login({
    required String email,
    required String password,
  }) async {
    _state = AuthLoading();
    try {
      final User user = await _authService.login(email: email, password: password);
      _state = AuthAuthenticated(role: user.role, email: user.email);
      return _state;
    } catch (e) {
      _state = AuthError(message: e.toString());
      return _state;
    }
  }

  // Register Customer flow
  Future<AuthState> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String postcode,
    required String password,
  }) async {
    _state = AuthLoading();
    try {
      final User user = await _authService.registerCustomer(
        name: name,
        email: email,
        phone: phone,
        address: address,
        city: city,
        postcode: postcode,
        password: password,
      );
      _state = AuthAuthenticated(role: user.role, email: user.email);
      return _state;
    } catch (e) {
      _state = AuthError(message: e.toString());
      return _state;
    }
  }

  // Register Restaurant flow
  Future<AuthState> registerRestaurant({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String postcode,
    required String password,
    required String bankHolderName,
    required String bankAccountNumber,
    required String bankIfscCode,
    required String bankBranchName,
  }) async {
    _state = AuthLoading();
    try {
      final User user = await _authService.registerRestaurant(
        name: name,
        email: email,
        phone: phone,
        address: address,
        postcode: postcode,
        password: password,
        bankHolderName: bankHolderName,
        bankAccountNumber: bankAccountNumber,
        bankIfscCode: bankIfscCode,
        bankBranchName: bankBranchName,
      );
      _state = AuthAuthenticated(role: user.role, email: user.email);
      return _state;
    } catch (e) {
      _state = AuthError(message: e.toString());
      return _state;
    }
  }

  // Logout flow
  Future<void> logout() async {
    await _authService.logout();
    _state = AuthInitial();
  }

  // Fallback simulator for events
  void add(AuthEvent event) {
    if (event is CustomerLoginEvent) {
      _state = AuthLoading();
      _state = AuthAuthenticated(role: 'customer', email: event.email);
    } else if (event is RestaurantLoginEvent) {
      _state = AuthLoading();
      _state = AuthAuthenticated(role: 'restaurant', email: event.email);
    }
  }
}
