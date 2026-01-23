import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumModel {
  final String id;
  final String title;
  final Duration duration;
  final String description;
  final String price;
  final bool isActive;

  PremiumModel({
    required this.id,
    required this.title,
    required this.price,
    required this.duration,
    required this.description,
    this.isActive = false,
  });

  factory PremiumModel.fromProductDetails(ProductDetails details) {
    Duration duration;
    if (details.id.contains('weekly')) {
      duration = const Duration(days: 7);
    } else if (details.id.contains('monthly')) {
      duration = const Duration(days: 30);
    } else {
      duration = const Duration(days: 30); // default
    }

    return PremiumModel(
      id: details.id,
      title: details.title,
      description: details.description,
      price: details.price,
      duration: duration,
    );
  }
}