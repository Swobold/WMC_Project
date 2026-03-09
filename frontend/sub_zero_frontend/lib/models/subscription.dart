import 'category.dart';

class Subscription {
  final int id;
  final String title;
  final double price;
  final String billingCycle;
  final String firstPaymentDate;
  final String nextReminderDate;
  final Category category;
  final String currency;

  Subscription({
    required this.id,
    required this.title,
    required this.price,
    required this.billingCycle,
    required this.firstPaymentDate,
    required this.nextReminderDate,
    required this.category,
    required this.currency,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      billingCycle: json['billing_cycle'] as String,
      firstPaymentDate: json['first_payment_date'] as String,
      nextReminderDate: json['next_reminder_date'] as String,
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
      currency: json['currency'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'billing_cycle': billingCycle,
        'first_payment_date': firstPaymentDate,
        'next_reminder_date': nextReminderDate,
        'category': category.toJson(),
        'currency': currency,
      };
}

/// Für POST/PUT an das Backend (nur die benötigten Felder)
class SubscriptionInput {
  final String title;
  final double price;
  final String billingCycle;
  final String firstPaymentDate;
  final String nextReminderDate;
  final int categoryId;

  SubscriptionInput({
    required this.title,
    required this.price,
    required this.billingCycle,
    required this.firstPaymentDate,
    required this.nextReminderDate,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'price': price,
        'billing_cycle': billingCycle,
        'first_payment_date': firstPaymentDate,
        'next_reminder_date': nextReminderDate,
        'category_id': categoryId,
      };
}
