import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/subscription_plan.dart';
import '../models/subscription.dart';

class SubscriptionRepository {
  final ApiClient _apiClient;

  SubscriptionRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // 1. List Subscription Plans for a Restaurant
  Future<List<SubscriptionPlan>> getRestaurantPlans(int restaurantId) async {
    final response = await _apiClient.get(ApiConfig.restaurantPlans(restaurantId));
    final data = response['data'] ?? response['plans'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => SubscriptionPlan.fromJson(json as Map<String, dynamic>)).toList();
  }

  // 2. Get Plan Details
  Future<SubscriptionPlan> getPlanDetails(int planId) async {
    final response = await _apiClient.get('${ApiConfig.subscriptionPlanDetails}/$planId');
    final data = response['data'] ?? response['plan'] ?? response;
    return SubscriptionPlan.fromJson(data as Map<String, dynamic>);
  }

  // 3. Subscribe to a Plan
  Future<Subscription> subscribe({
    required int restaurantId,
    required int subscriptionPlanId,
    required String startDate,
    required int addressId,
    bool autoRenew = true,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.subscriptions,
      body: {
        'restaurant_id': restaurantId,
        'subscription_plan_id': subscriptionPlanId,
        'start_date': startDate,
        'address_id': addressId,
        'auto_renew': autoRenew,
      },
    );
    final data = response['data'] ?? response['subscription'] ?? response;
    return Subscription.fromJson(data as Map<String, dynamic>);
  }

  // 4. List My Subscriptions
  Future<List<Subscription>> getMySubscriptions() async {
    final response = await _apiClient.get(ApiConfig.subscriptions);
    final data = response['data'] ?? response['subscriptions'];
    final List<dynamic> list = (data is List ? data : (data is Map && data.containsKey('data') ? data['data'] : [])) ?? [];
    return list.map((json) => Subscription.fromJson(json as Map<String, dynamic>)).toList();
  }

  // 5. Get Subscription Details
  Future<Subscription> getSubscriptionDetails(int subscriptionId) async {
    final response = await _apiClient.get('${ApiConfig.subscriptions}/$subscriptionId');
    final data = response['data'] ?? response['subscription'] ?? response;
    return Subscription.fromJson(data as Map<String, dynamic>);
  }

  // 6. Pause Subscription
  Future<Subscription> pauseSubscription(int subscriptionId) async {
    final response = await _apiClient.post(ApiConfig.pauseSubscription(subscriptionId));
    final data = response['data'] ?? response['subscription'] ?? response;
    return Subscription.fromJson(data as Map<String, dynamic>);
  }

  // 7. Resume Subscription
  Future<Subscription> resumeSubscription(int subscriptionId) async {
    final response = await _apiClient.post(ApiConfig.resumeSubscription(subscriptionId));
    final data = response['data'] ?? response['subscription'] ?? response;
    return Subscription.fromJson(data as Map<String, dynamic>);
  }

  // 8. Cancel Subscription
  Future<Subscription> cancelSubscription(int subscriptionId) async {
    final response = await _apiClient.post(ApiConfig.cancelSubscription(subscriptionId));
    final data = response['data'] ?? response['subscription'] ?? response;
    return Subscription.fromJson(data as Map<String, dynamic>);
  }

  // 9. Get User Subscription Access & Trial Status
  Future<Map<String, dynamic>> getAccessStatus() async {
    try {
      final response = await _apiClient.get(ApiConfig.subscriptionAccessStatus);
      return (response['data'] ?? response) as Map<String, dynamic>;
    } catch (_) {
      // Fallback default: trial active for 7 days
      return {
        'can_access': true,
        'is_trial': true,
        'trial_days_remaining': 7,
        'message': 'Initial 7-day free trial active.',
      };
    }
  }

  // 10. Get Terms & Conditions
  Future<Map<String, dynamic>> getTermsAndConditions() async {
    try {
      final response = await _apiClient.get(ApiConfig.termsAndConditions);
      return (response['data'] ?? response) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
