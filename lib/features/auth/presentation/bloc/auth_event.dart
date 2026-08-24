abstract class AuthEvent {}

class CustomerLoginEvent extends AuthEvent {
  final String email;
  final String password;
  CustomerLoginEvent({required this.email, required this.password});
}

class CustomerRegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String postcode;
  final String password;
  CustomerRegisterEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.postcode,
    required this.password,
  });
}

class RestaurantLoginEvent extends AuthEvent {
  final String email;
  final String password;
  RestaurantLoginEvent({required this.email, required this.password});
}

class RestaurantRegisterEvent extends AuthEvent {
  final String restaurantName;
  final String email;
  final String phone;
  final String address;
  final String postcode;
  final String password;
  final String bankHolderName;
  final String bankAccountNumber;
  final String bankIfscCode;
  final String bankBranchName;
  RestaurantRegisterEvent({
    required this.restaurantName,
    required this.email,
    required this.phone,
    required this.address,
    required this.postcode,
    required this.password,
    required this.bankHolderName,
    required this.bankAccountNumber,
    required this.bankIfscCode,
    required this.bankBranchName,
  });
}

class LogoutEvent extends AuthEvent {}
