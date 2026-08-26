abstract class AddressEvent {}

class FetchAddressesEvent extends AddressEvent {}

class CreateAddressEvent extends AddressEvent {
  final String label;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  CreateAddressEvent({
    required this.label,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.pincode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });
}

class UpdateAddressEvent extends AddressEvent {
  final int addressId;
  final Map<String, dynamic> data;
  UpdateAddressEvent({required this.addressId, required this.data});
}

class DeleteAddressEvent extends AddressEvent {
  final int addressId;
  DeleteAddressEvent(this.addressId);
}
