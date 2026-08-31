import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kinkitchen/shared/repositories/restaurant_repository.dart';
import 'restaurant_profile_event.dart';
import 'restaurant_profile_state.dart';

class RestaurantProfileBloc extends Bloc<RestaurantProfileEvent, RestaurantProfileState> {
  final RestaurantRepository _restaurantRepository;

  RestaurantProfileBloc({RestaurantRepository? restaurantRepository})
      : _restaurantRepository = restaurantRepository ?? RestaurantRepository(),
        super(RestaurantProfileInitial()) {
    on<FetchRestaurantProfileEvent>(_onFetchProfile);
    on<UpdateRestaurantProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onFetchProfile(FetchRestaurantProfileEvent event, Emitter<RestaurantProfileState> emit) async {
    emit(RestaurantProfileLoading());
    try {
      final profile = await _restaurantRepository.getProfile();
      emit(RestaurantProfileLoaded(profile));
    } catch (e) {
      emit(RestaurantProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(UpdateRestaurantProfileEvent event, Emitter<RestaurantProfileState> emit) async {
    emit(RestaurantProfileLoading());
    try {
      final profile = await _restaurantRepository.updateProfile(event.fields, logo: event.logo);
      emit(RestaurantProfileOperationSuccess(profile: profile, message: 'Profile updated successfully!'));
    } catch (e) {
      emit(RestaurantProfileError(e.toString()));
    }
  }
}
