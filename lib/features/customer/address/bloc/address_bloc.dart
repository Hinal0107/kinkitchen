import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kinkitchen/shared/repositories/address_repository.dart';
import 'address_event.dart';
import 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRepository _addressRepository;

  AddressBloc({AddressRepository? addressRepository})
      : _addressRepository = addressRepository ?? AddressRepository(),
        super(AddressInitial()) {
    on<FetchAddressesEvent>(_onFetchAddresses);
    on<CreateAddressEvent>(_onCreateAddress);
    on<UpdateAddressEvent>(_onUpdateAddress);
    on<DeleteAddressEvent>(_onDeleteAddress);
  }

  Future<void> _onFetchAddresses(FetchAddressesEvent event, Emitter<AddressState> emit) async {
    emit(AddressLoading());
    try {
      final addresses = await _addressRepository.getAddresses();
      emit(AddressLoaded(addresses));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onCreateAddress(CreateAddressEvent event, Emitter<AddressState> emit) async {
    try {
      await _addressRepository.createAddress(
        label: event.label,
        line1: event.line1,
        line2: event.line2,
        city: event.city,
        state: event.state,
        pincode: event.pincode,
        latitude: event.latitude,
        longitude: event.longitude,
        isDefault: event.isDefault,
      );
      add(FetchAddressesEvent());
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onUpdateAddress(UpdateAddressEvent event, Emitter<AddressState> emit) async {
    try {
      await _addressRepository.updateAddress(event.addressId, event.data);
      add(FetchAddressesEvent());
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onDeleteAddress(DeleteAddressEvent event, Emitter<AddressState> emit) async {
    try {
      await _addressRepository.deleteAddress(event.addressId);
      add(FetchAddressesEvent());
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }
}
