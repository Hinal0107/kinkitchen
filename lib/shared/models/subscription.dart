import 'subscription_plan.dart';
import 'restaurant.dart';

class Subscription {
  final int id;
  final int userId;
  final int restaurantId;
  final int subscriptionPlanId;
  final String status; // 'active', 'paused', 'cancelled', 'expired', 'completed'
  final String startDate;
  final String? endDate;
  final bool autoRenew;
  final SubscriptionPlan? plan;
  final Restaurant? restaurant;

  // Dynamic Backend & Expiry Fields
  final int totalMeals;
  final int usedMeals;
  final int remainingMeals;
  final int maxValidityDays;
  final String? maxValidityDate;
  final int daysUntilExpiry;
  final String? expiryReminderMessage;
  final String? expirationReason;
  final String paymentStatus;

  Subscription({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.subscriptionPlanId,
    required this.status,
    required this.startDate,
    this.endDate,
    this.autoRenew = true,
    this.plan,
    this.restaurant,
    this.totalMeals = 0,
    this.usedMeals = 0,
    this.remainingMeals = 0,
    this.maxValidityDays = 14,
    this.maxValidityDate,
    this.daysUntilExpiry = 14,
    this.expiryReminderMessage,
    this.expirationReason,
    this.paymentStatus = 'PAID',
  });

  bool get isExpiringSoon {
    if (status.toUpperCase() != 'ACTIVE' && status.toLowerCase() != 'active') return false;
    return daysUntilExpiry <= 2 && daysUntilExpiry >= 0;
  }

  bool get isExpiredStatus {
    final s = status.toUpperCase();
    if (s == 'EXPIRED' || s == 'COMPLETED' || s == 'CANCELLED') return true;
    if (remainingMeals <= 0) return true;
    if (daysUntilExpiry < 0) return true;
    return false;
  }

  String get effectiveReminderMessage {
    if (expiryReminderMessage != null && expiryReminderMessage!.isNotEmpty) {
      return expiryReminderMessage!;
    }
    if (isExpiringSoon) {
      if (daysUntilExpiry == 0) return "Your plan will expire today.";
      if (daysUntilExpiry == 1) return "Your plan will expire in 1 day.";
      return "Your plan will expire in 2 days.";
    }
    return '';
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val, [int fallback = 0]) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? fallback;
      return fallback;
    }

    bool toBool(dynamic val, [bool fallback = true]) {
      if (val is bool) return val;
      if (val is int) return val == 1;
      if (val is String) return val == '1' || val.toLowerCase() == 'true';
      return fallback;
    }

    final parsedPlan = json['plan'] != null
        ? SubscriptionPlan.fromJson(json['plan'] as Map<String, dynamic>)
        : (json['subscription_plan'] != null
            ? SubscriptionPlan.fromJson(json['subscription_plan'] as Map<String, dynamic>)
            : null);

    final parsedRestaurant = json['restaurant'] != null
        ? Restaurant.fromJson(json['restaurant'] as Map<String, dynamic>)
        : null;

    final String startStr = json['start_date']?.toString() ?? json['startDate']?.toString() ?? '';
    final int planTotal = parsedPlan?.mealsCount ?? 7;
    final int total = toInt(json['total_meals'], planTotal);
    final int used = toInt(json['used_meals'], 0);
    final int rawRemaining = json['remaining_meals'] != null
        ? toInt(json['remaining_meals'])
        : (total - used);
    final int remaining = rawRemaining < 0 ? 0 : rawRemaining;

    // Calculate max validity days (Weekly: 14 days, Monthly: 60 days)
    final int defaultValidity = parsedPlan?.maxValidityDays ?? 14;
    final int valDays = toInt(json['max_validity_days'], defaultValidity);

    // Compute max validity date
    String? valDate = json['max_validity_date']?.toString();
    if ((valDate == null || valDate.isEmpty) && startStr.isNotEmpty) {
      final parsedStart = DateTime.tryParse(startStr);
      if (parsedStart != null) {
        final calcEnd = parsedStart.add(Duration(days: valDays));
        valDate = "${calcEnd.year}-${calcEnd.month.toString().padLeft(2, '0')}-${calcEnd.day.toString().padLeft(2, '0')}";
      }
    }

    // Days until expiry calculation
    int calcDays = 0;
    if (json['days_until_expiry'] != null) {
      calcDays = toInt(json['days_until_expiry']);
    } else if (valDate != null && valDate.isNotEmpty) {
      final targetDate = DateTime.tryParse(valDate);
      if (targetDate != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
        calcDays = target.difference(today).inDays;
      }
    } else {
      calcDays = valDays;
    }

    String rawStatus = json['status']?.toString() ?? 'ACTIVE';
    if (remaining <= 0 || calcDays < 0) {
      if (rawStatus.toUpperCase() == 'ACTIVE') {
        rawStatus = 'EXPIRED';
      }
    }

    return Subscription(
      id: toInt(json['id']),
      userId: toInt(json['user_id'] ?? json['customer_id']),
      restaurantId: toInt(json['restaurant_id']),
      subscriptionPlanId: toInt(json['subscription_plan_id']),
      status: rawStatus,
      startDate: startStr,
      endDate: json['end_date']?.toString(),
      autoRenew: toBool(json['auto_renew']),
      plan: parsedPlan,
      restaurant: parsedRestaurant,
      totalMeals: total,
      usedMeals: used,
      remainingMeals: remaining,
      maxValidityDays: valDays,
      maxValidityDate: valDate,
      daysUntilExpiry: calcDays < 0 ? 0 : calcDays,
      expiryReminderMessage: json['expiry_reminder_message']?.toString(),
      expirationReason: json['expiration_reason']?.toString(),
      paymentStatus: json['payment_status']?.toString() ?? 'PAID',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'subscription_plan_id': subscriptionPlanId,
      'status': status,
      'start_date': startDate,
      'end_date': endDate,
      'auto_renew': autoRenew ? 1 : 0,
      'plan': plan?.toJson(),
      'restaurant': restaurant?.toJson(),
      'total_meals': totalMeals,
      'used_meals': usedMeals,
      'remaining_meals': remainingMeals,
      'max_validity_days': maxValidityDays,
      'max_validity_date': maxValidityDate,
      'days_until_expiry': daysUntilExpiry,
      'expiry_reminder_message': expiryReminderMessage,
      'expiration_reason': expirationReason,
      'payment_status': paymentStatus,
    };
  }
}
