abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String role; // 'customer' or 'restaurant'
  final String email;
  AuthAuthenticated({required this.role, required this.email});
}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}
