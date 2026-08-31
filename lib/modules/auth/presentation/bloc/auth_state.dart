import 'package:kinkitchen/shared/models/user.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String role;
  final String email;
  final User? user;

  AuthAuthenticated({
    required this.role,
    required this.email,
    this.user,
  });
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}
