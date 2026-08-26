import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/auth_repository.dart';
import '../../../../models/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(AuthInitial()) {
    on<CustomerLoginEvent>(_onCustomerLogin);
    on<RestaurantLoginEvent>(_onRestaurantLogin);
    on<CustomerRegisterEvent>(_onCustomerRegister);
    on<RestaurantRegisterEvent>(_onRestaurantRegister);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCustomerLogin(CustomerLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(email: event.email, password: event.password);
      emit(AuthAuthenticated(role: user.role, email: user.email, user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onRestaurantLogin(RestaurantLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(email: event.email, password: event.password);
      emit(AuthAuthenticated(role: user.role, email: user.email, user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onCustomerRegister(CustomerRegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(
        name: event.name,
        email: event.email,
        phone: event.phone,
        password: event.password,
        passwordConfirmation: event.password,
        role: 'CUSTOMER',
      );
      emit(AuthAuthenticated(role: user.role, email: user.email, user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onRestaurantRegister(RestaurantRegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(
        name: event.restaurantName,
        email: event.email,
        phone: event.phone,
        password: event.password,
        passwordConfirmation: event.password,
        role: 'RESTAURANT',
      );
      emit(AuthAuthenticated(role: user.role, email: user.email, user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.getMe();
      emit(AuthAuthenticated(role: user.role, email: user.email, user: user));
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

  // Backward compatibility helper methods
  Future<AuthState> login({required String email, required String password}) async {
    add(CustomerLoginEvent(email: email, password: password));
    return state;
  }

  Future<AuthState> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String postcode,
    required String password,
  }) async {
    add(CustomerRegisterEvent(
      name: name,
      email: email,
      phone: phone,
      address: address,
      city: city,
      postcode: postcode,
      password: password,
    ));
    return state;
  }

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
    add(RestaurantRegisterEvent(
      restaurantName: name,
      email: email,
      phone: phone,
      address: address,
      postcode: postcode,
      password: password,
      bankHolderName: bankHolderName,
      bankAccountNumber: bankAccountNumber,
      bankIfscCode: bankIfscCode,
      bankBranchName: bankBranchName,
    ));
    return state;
  }
}
