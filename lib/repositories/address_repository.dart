import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/address.dart';

class AddressRepository {
  final ApiClient _apiClient;

  AddressRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // 1. List Addresses
  Future<List<Address>> getAddresses() async {
    final response = await _apiClient.get(ApiConfig.addresses);
    final data = response['data'] ?? response['addresses'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => Address.fromJson(json as Map<String, dynamic>)).toList();
  }

  // 2. Create Address
  Future<Address> createAddress({
    required String label,
    required String line1,
    String? line2,
    required String city,
    required String state,
    required String pincode,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.addresses,
      body: {
        'label': label,
        'line1': line1,
        if (line2 != null && line2.isNotEmpty) 'line2': line2,
        'city': city,
        'state': state,
        'pincode': pincode,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'is_default': isDefault,
      },
    );
    final data = response['data'] ?? response['address'] ?? response;
    return Address.fromJson(data as Map<String, dynamic>);
  }

  // 3. Update Address
  Future<Address> updateAddress(int addressId, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      '${ApiConfig.addresses}/$addressId',
      body: data,
    );
    final resData = response['data'] ?? response['address'] ?? response;
    return Address.fromJson(resData as Map<String, dynamic>);
  }

  // 4. Delete Address
  Future<void> deleteAddress(int addressId) async {
    await _apiClient.delete('${ApiConfig.addresses}/$addressId');
  }
}
