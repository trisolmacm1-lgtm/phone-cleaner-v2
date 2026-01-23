import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:phone_cleaner_2/core/utils/constants.dart';
import 'package:phone_cleaner_2/screens/paywall_screen/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/routes.dart';

class PremiumProvider extends ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  static const String _monthlySubscriptionId = monthlyId;
  final String _appSecretKey = appStoreKey;
  static const String _weeklySubscriptionId = weeklyTrialId;

  PremiumModel? _activePlan;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  List<PremiumModel> _availablePlans = [];
  Map<String, ProductDetails> _productDetailsMap = {};

  String? _nextRoute;

  String? get nextRoute => _nextRoute;

  static const Set<String> _kProductIds = {
    _weeklySubscriptionId,
    _monthlySubscriptionId,
  };

  void clearRoute() => _nextRoute = null;

  // PremiumProvider() {
  //   initialize();
  // }

  // Getters
  List<PremiumModel> get availablePlans => _availablePlans;

  PremiumModel? get activePlan => _activePlan;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get isSubscribe => _activePlan != null;
  // bool get isSubscribe  => true;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      debugPrint("Premium Provider call");
      _setLoading(true);

      final bool isAvailable = await _inAppPurchase.isAvailable();
      if (!isAvailable) {
        log("Store is not available");
        _setError('Store is not available');
        return;
      }

      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onError: (error) => _setError('Purchase stream error: $error'),
      );

      await _loadProducts();
      await _loadSubscriptionState();

      // Auto recheck subscription
      if (_activePlan != null && defaultTargetPlatform == TargetPlatform.iOS) {
        log("Auto recheck subscription");
        log(_activePlan!.id);
        final prefs = await SharedPreferences.getInstance();
        final receiptData = prefs.getString('ios_receipt');
        if (receiptData != null) {
          await _verifyIOSReceipt(receiptData);
        }
      }

      _isInitialized = true;
    } catch (e) {
      _setError('Initialization failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(_kProductIds);

      print('key: $_kProductIds');

      print('Response: ${response.productDetails}');
      if (response.error != null) {
        _setError('Failed to load products: ${response.error}');
        return;
      }

      _availablePlans = response.productDetails
          .map((product) => PremiumModel.fromProductDetails(product))
          .toList();

      _productDetailsMap = {
        for (var product in response.productDetails) product.id: product,
      };

      log("productDetailsMap: ${_productDetailsMap.length}");

      _availablePlans.sort(
        (a, b) => a.duration.inDays.compareTo(b.duration.inDays),
      );

      log("availablePlans: ${_availablePlans.length}");
      log("availablePlans: ${_availablePlans.first.price}");
      log("availablePlans: ${_availablePlans.last.price}");

      notifyListeners();
    } catch (e) {
      _setError('Error loading products: $e');
    }
  }

  Future<void> restorePurchases() async {
    try {
      _setLoading(true);
      await _inAppPurchase.restorePurchases();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      _setError('Failed to restore purchases: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> subscribe(String productId) async {
    try {
      _setLoading(true);
      _clearError();

      final ProductDetails? productDetails = _getProductDetails(productId);
      if (productDetails == null) {
        log("Product not found");
        _setError('Product not found');
        return;
      }

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: null,
      );

      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!success) {
        log("Failed to initiate purchase");
        _setError('Failed to initiate purchase');
      } else {
        log("Purchase initiated successfully");
      }
    } catch (e) {
      log("Purchase failed: $e");
      _setError('Purchase failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _onPurchaseUpdate(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        log("Purchase pending");
        _setLoading(true);
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        log("Purchase canceled");
        _setLoading(false);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        log("Purchase error");
        _setLoading(false);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        log("Purchased or restored");
        await prefs.setBool("isPremium", true);
        _handleSuccessfulPurchase(purchaseDetails);

        // navigate to home screen
        _nextRoute = AppRouter.success;
        notifyListeners();
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(
    PurchaseDetails purchaseDetails,
  ) async {
    try {
      if (purchaseDetails.verificationData.source == 'app_store') {
        await _verifyIOSReceipt(
          purchaseDetails.verificationData.serverVerificationData,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'ios_receipt',
          purchaseDetails.verificationData.serverVerificationData,
        );
      }

      final plan = _availablePlans.firstWhere(
        (plan) => plan.id == purchaseDetails.productID,
      );

      _activePlan = PremiumModel(
        id: plan.id,
        title: plan.title,
        description: plan.description,
        price: plan.price,
        duration: plan.duration,
        isActive: true,
      );

      await _saveSubscriptionState();
      _setLoading(false);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to process purchase: $e');
      _setLoading(false);
    }
  }

  Future<void> _verifyIOSReceipt(String receiptData) async {
    log("Verifying called");
    final Map<String, dynamic> payload = {
      'receipt-data': receiptData,
      'password': _appSecretKey,
      'exclude-old-transactions': true,
    };

    final response = await http.post(
      Uri.parse(
        kDebugMode
            ? 'https://sandbox.itunes.apple.com/verifyReceipt'
            : 'https://buy.itunes.apple.com/verifyReceipt',
      ),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    log("Verifying response: ${response.statusCode}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> receipt = json.decode(response.body);
      log("Receipt: ${receipt['status']}");
      if (receipt['status'] == 0) {
        log('Receipt verified successfully');
        await _handleSubscriptionValidation(receipt);
      } else {
        log('Receipt verification failed');
        await _handleSubscriptionNotPurchased();
      }
    } else {
      log("Failed to verify receipt");
      await _handleSubscriptionNotPurchased();
      throw Exception(
        'Failed to verify receipt. Status: ${response.statusCode}',
      );
    }
  }

  Future<void> _handleSubscriptionValidation(
    Map<String, dynamic> receipt,
  ) async {
    final List<dynamic>? latestReceiptInfo = receipt['latest_receipt_info'];

    if (latestReceiptInfo != null && latestReceiptInfo.isNotEmpty) {
      final latest = latestReceiptInfo.last;
      final int expiresMs = int.tryParse(latest['expires_date_ms'] ?? '0') ?? 0;
      final DateTime expiration = DateTime.fromMillisecondsSinceEpoch(
        expiresMs,
      );

      if (expiration.isAfter(DateTime.now())) {
        final String? productId = latest['product_id'];
        final plan = _availablePlans.firstWhere((plan) => plan.id == productId);

        _activePlan = PremiumModel(
          id: plan.id,
          title: plan.title,
          description: plan.description,
          price: plan.price,
          duration: plan.duration,
          isActive: true,
        );

        await _saveSubscriptionState();
        notifyListeners();
        return;
      }
    }

    await _handleSubscriptionNotPurchased();
  }

  Future<void> _handleSubscriptionNotPurchased() async {
    _activePlan = null;

    log("Subscription not purchased");
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_subscription_id');
    await prefs.remove('subscription_start_date');
    await prefs.remove('ios_receipt');
    log("${_activePlan?.id}");

    _activePlan = null;
    notifyListeners();
  }

  Future<void> _saveSubscriptionState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_activePlan != null) {
      await prefs.setString('active_subscription_id', _activePlan!.id);
      await prefs.setString(
        'subscription_start_date',
        DateTime.now().toIso8601String(),
      );
    }
  }

  Future<void> _loadSubscriptionState() async {
    final prefs = await SharedPreferences.getInstance();
    final subscriptionId = prefs.getString('active_subscription_id');
    final startDateString = prefs.getString('subscription_start_date');

    if (subscriptionId != null && startDateString != null) {
      final startDate = DateTime.parse(startDateString);
      final plan = _availablePlans.firstWhere(
        (plan) => plan.id == subscriptionId,
        // orElse: () => _availablePlans.first,
      );

      final expirationDate = startDate.add(plan.duration);
      if (DateTime.now().isBefore(expirationDate)) {
        _activePlan = PremiumModel(
          id: plan.id,
          title: plan.title,
          description: plan.description,
          price: plan.price,
          duration: plan.duration,
          isActive: true,
        );
      }
    }
  }

  ProductDetails? _getProductDetails(String productId) {
    try {
      final plan = _availablePlans.firstWhere((plan) => plan.id == productId);
      return _productDetailsMap[plan.id];
    } catch (e) {
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
