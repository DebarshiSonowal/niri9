import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Helper/storage.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Router/routes.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum IAP_Status {
  pending,
  purchased,
  error,
  cancelled,
}

class SubscriptionProductMapping {
  final int subscriptionId;
  final String productId;
  final String duration;
  final int tier;

  const SubscriptionProductMapping({
    required this.subscriptionId,
    required this.productId,
    required this.duration,
    required this.tier,
  });
}

class AppleIAPService {
  AppleIAPService._();

  static final AppleIAPService instance = AppleIAPService._();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _isLoadingProducts = false;
  bool _productsLoaded = false;
  String? _orderId;
  String? _amount;
  Function? _onPurchaseComplete;
  Function? _onPurchaseError;
  Timer? _watchdogTimer;

  // FIX: Track processed transactions to prevent duplicate verification
  final Set<String> _processedTransactionIds = {};

  String? _currentSubscriptionProductId;
  int? _currentSubscriptionTier;

  final List<SubscriptionProductMapping> _productMappings = [
    SubscriptionProductMapping(
      subscriptionId: 1,
      productId: 'com.niri9.subscription.monthly',
      duration: 'monthly',
      tier: 1,
    ),
    SubscriptionProductMapping(
      subscriptionId: 2,
      productId: 'com.niri9.subscription.quarterly',
      duration: 'quarterly',
      tier: 2,
    ),
    SubscriptionProductMapping(
      subscriptionId: 3,
      productId: 'com.niri9.subscription.halfyearly',
      duration: 'halfyearly',
      tier: 3,
    ),
    SubscriptionProductMapping(
      subscriptionId: 4,
      productId: 'com.niri9.subscription.yearly',
      duration: 'yearly',
      tier: 4,
    ),
  ];

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
  bool get purchasePending => _purchasePending;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get productsLoaded => _productsLoaded;
  String? get currentSubscriptionProductId => _currentSubscriptionProductId;
  int? get currentSubscriptionTier => _currentSubscriptionTier;

  void setCurrentSubscription(String? productId) {
    _currentSubscriptionProductId = productId;

    if (productId != null) {
      final mapping = _productMappings.firstWhere(
        (m) => m.productId == productId,
        orElse: () => _productMappings.first,
      );
      _currentSubscriptionTier = mapping.tier;
      debugPrint('Current subscription tier: $_currentSubscriptionTier');
    } else {
      _currentSubscriptionTier = null;
    }
  }

  bool isSubscriptionEnabled(String productId) {
    if (_currentSubscriptionTier == null) {
      return true;
    }

    final mapping = _productMappings.firstWhere(
      (m) => m.productId == productId,
      orElse: () => _productMappings.first,
    );

    return mapping.tier >= _currentSubscriptionTier!;
  }

  bool isCurrentSubscription(String productId) {
    return _currentSubscriptionProductId == productId;
  }

  int? getTierForProductId(String productId) {
    try {
      final mapping = _productMappings.firstWhere(
        (m) => m.productId == productId,
      );
      return mapping.tier;
    } catch (e) {
      return null;
    }
  }

  Future<bool> initialize() async {
    debugPrint('🍎 Starting Apple IAP initialization...');

    if (!Platform.isIOS && !Platform.isMacOS) {
      debugPrint('❌ Not on iOS/macOS platform');
      return false;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();

      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
      debugPrint('✅ StoreKit delegate set up');
    }

    final bool isAvailable = await _inAppPurchase.isAvailable();
    _isAvailable = isAvailable;

    if (!isAvailable) {
      debugPrint('❌ The Apple App Store is not available');
      debugPrint(
          '💡 Make sure StoreKit Configuration file is set up in Xcode scheme');
      return false;
    }

    debugPrint('✅ App Store is available');

    _subscription = _inAppPurchase.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () {
        debugPrint('⚠️ Purchase stream closed');
      },
      onError: (error) {
        debugPrint('❌ Error in IAP Stream: $error');
        _handlePurchaseError('Stream error: $error');
      },
    );

    debugPrint('✅ Purchase stream listener set up');

    final productsLoaded = await loadProducts(null);

    if (productsLoaded) {
      debugPrint(
          '✅ Initialized successfully with ${_products.length} products');
    } else {
      debugPrint('⚠️ Initialized but no products loaded');
    }

    return productsLoaded;
  }

  Future<bool> loadProducts([List<String>? productIds]) async {
    if (!_isAvailable) {
      debugPrint('❌ Store not available');
      Fluttertoast.showToast(msg: "App Store is not available");
      return false;
    }

    if (_isLoadingProducts) {
      debugPrint('⏳ Products are already being loaded, waiting...');
      int attempts = 0;
      while (_isLoadingProducts && attempts < 100) {
        await Future.delayed(Duration(milliseconds: 100));
        attempts++;
      }
      return _productsLoaded;
    }

    if (_productsLoaded && _products.isNotEmpty && productIds == null) {
      debugPrint('✅ Products already loaded (${_products.length}), reusing');
      return true;
    }

    _isLoadingProducts = true;
    debugPrint('🔄 Loading products from StoreKit...');

    try {
      final idsToLoad = _productMappings.map((m) => m.productId).toSet();

      debugPrint('📦 Requesting products: $idsToLoad');

      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(idsToLoad);

      if (response.error != null) {
        debugPrint('❌ Error loading products: ${response.error}');
        Fluttertoast.showToast(
          msg: "Failed to load subscriptions. Check StoreKit setup.",
          toastLength: Toast.LENGTH_LONG,
        );
        return false;
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint(
            '⚠️ Products not found in App Store: ${response.notFoundIDs}');
      }

      _products = response.productDetails;

      if (_products.isEmpty) {
        debugPrint('❌ No products loaded from App Store');
        return false;
      }

      // Sort by tier
      _products.sort((a, b) {
        final tierA = getTierForProductId(a.id) ?? 0;
        final tierB = getTierForProductId(b.id) ?? 0;
        return tierA.compareTo(tierB);
      });

      _productsLoaded = true;
      debugPrint('✅ Successfully loaded ${_products.length} products:');
      for (var product in _products) {
        debugPrint('   ✓ ${product.id}');
        debugPrint('     Title: ${product.title}');
        debugPrint('     Price: ${product.price}');
      }

      return true;
    } catch (e) {
      debugPrint('❌ Exception loading products: $e');
      return false;
    } finally {
      _isLoadingProducts = false;
    }
  }

  ProductDetails? findProductForSubscription(int subscriptionId) {
    if (!_productsLoaded) {
      debugPrint('⚠️ Products not loaded yet!');
      return null;
    }

    try {
      final mapping = _productMappings.firstWhere(
        (mapping) => mapping.subscriptionId == subscriptionId,
      );

      final product = _products.firstWhere(
        (product) => product.id == mapping.productId,
      );

      debugPrint(
          '✅ Found product: ${product.id} for subscription ID: $subscriptionId');
      return product;
    } catch (e) {
      debugPrint('❌ Product not found for subscription ID: $subscriptionId');
      return null;
    }
  }

  Future<ProductDetails?> ensureProductLoaded(int subscriptionId) async {
    if (!_productsLoaded || _products.isEmpty) {
      debugPrint('🔄 Products not loaded yet, loading now...');
      Fluttertoast.showToast(msg: "Loading subscription options...");
      final success = await loadProducts(null);

      if (!success) {
        debugPrint('❌ Failed to load products');
        return null;
      }
    }

    final product = findProductForSubscription(subscriptionId);

    if (product == null) {
      debugPrint('❌ Product not found for subscription ID: $subscriptionId');
      Fluttertoast.showToast(
        msg: "This subscription is not available",
        toastLength: Toast.LENGTH_LONG,
      );
    }

    return product;
  }

  Future<bool> buySubscriptionById(
      int subscriptionId, String orderId, String amount,
      {Function? onComplete, Function? onError}) async {
    debugPrint('💳 Starting purchase - Subscription ID: $subscriptionId');

    final product = await ensureProductLoaded(subscriptionId);

    if (product == null) {
      debugPrint('❌ Cannot proceed - product not found');
      Fluttertoast.showToast(
        msg: "Subscription not available",
        toastLength: Toast.LENGTH_SHORT,
      );
      return false;
    }

    debugPrint(
        '✅ Found product: ${product.id} for subscription ID: $subscriptionId');
    return await buySubscription(product, orderId, amount,
        onComplete: onComplete, onError: onError);
  }

  Future<bool> buySubscription(
      ProductDetails product, String orderId, String amount,
      {Function? onComplete, Function? onError}) async {
    if (_purchasePending) {
      debugPrint('⚠️ A purchase is already in progress');
      Fluttertoast.showToast(msg: "A purchase is already in progress");
      return false;
    }

    if (!isSubscriptionEnabled(product.id)) {
      Fluttertoast.showToast(
        msg: "Cannot downgrade to a lower subscription tier",
        toastLength: Toast.LENGTH_LONG,
      );
      return false;
    }

    _watchdogTimer?.cancel();

    _purchasePending = true;
    _orderId = orderId;
    _amount = amount;
    _onPurchaseComplete = onComplete;
    _onPurchaseError = onError;

    try {
      debugPrint('💳 Initiating purchase for: ${product.id}');
      debugPrint('📝 Order ID: $orderId, Amount: $amount');

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: Storage.instance.userId,
      );

      debugPrint("🔄 Calling StoreKit...");

      final bool purchaseStarted =
          await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      if (!purchaseStarted) {
        debugPrint('❌ Purchase failed to start');
        _purchasePending = false;
        _handlePurchaseError("Failed to start purchase");
        return false;
      }

      debugPrint('✅ Purchase request sent to StoreKit');
      debugPrint('⏳ Waiting for user to complete purchase...');

      _watchdogTimer = Timer(Duration(minutes: 2), () {
        if (_purchasePending) {
          debugPrint(
              '⏰ Purchase watchdog triggered - no response in 2 minutes');
          _purchasePending = false;
          _handlePurchaseError(
              'Purchase is taking too long. If payment was deducted, use "Restore Purchases".');
        }
      });

      return true;
    } catch (e) {
      _purchasePending = false;
      _watchdogTimer?.cancel();
      debugPrint('❌ Exception initiating purchase: $e');

      final errorString = e.toString().toLowerCase();
      if (errorString.contains('usercancelled') ||
          errorString.contains('user cancelled') ||
          errorString.contains('canceled')) {
        debugPrint('👤 User cancelled the purchase');
        Fluttertoast.showToast(
            msg: "Purchase cancelled", toastLength: Toast.LENGTH_SHORT);
        if (_onPurchaseError != null) {
          _onPurchaseError!();
        }
      } else {
        _handlePurchaseError('Failed to start purchase: $e');
      }
      return false;
    }
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    debugPrint('📬 Purchase update: ${purchaseDetailsList.length} items');

    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint('📦 Processing: ${purchaseDetails.productID}');
      debugPrint('📊 Status: ${purchaseDetails.status}');

      // FIX: Generate unique transaction ID
      final transactionId = _getTransactionId(purchaseDetails);

      // FIX: Skip if already processed
      if (_processedTransactionIds.contains(transactionId)) {
        debugPrint('⏭️ Transaction already processed: $transactionId');
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
        continue;
      }

      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('⏳ Purchase pending (user may be authenticating)');
        Fluttertoast.showToast(
          msg: "Processing payment...",
          toastLength: Toast.LENGTH_SHORT,
        );
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('❌ Purchase error: ${purchaseDetails.error?.message}');

        _watchdogTimer?.cancel();
        _handlePurchaseError(purchaseDetails.error?.message ?? 'Unknown error');

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        debugPrint('✅ Purchase completed: ${purchaseDetails.productID}');

        // FIX: Mark as processed immediately
        _processedTransactionIds.add(transactionId);

        _watchdogTimer?.cancel();

        try {
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            await _deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
          }
        } catch (e) {
          debugPrint('❌ Error processing purchase: $e');
          _handlePurchaseError('Error verifying purchase: $e');
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        debugPrint('👤 Purchase cancelled by user');
        _watchdogTimer?.cancel();
        _purchasePending = false;

        Fluttertoast.showToast(
          msg: "Purchase cancelled",
          toastLength: Toast.LENGTH_SHORT,
        );

        if (_onPurchaseError != null) {
          _onPurchaseError!();
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  // FIX: Generate unique transaction ID
  String _getTransactionId(PurchaseDetails purchaseDetails) {
    // Use transaction date + product ID as unique identifier
    final date =
        purchaseDetails.transactionDate ?? DateTime.now().toIso8601String();
    return '${purchaseDetails.productID}_$date';
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    debugPrint('🔍 Verifying purchase with backend...');
    debugPrint('Product: ${purchaseDetails.productID}');
    debugPrint('Transaction Date: ${purchaseDetails.transactionDate}');

    if (purchaseDetails.verificationData.serverVerificationData.isEmpty) {
      debugPrint('❌ No receipt data available');
      return false;
    }

    final receiptData = purchaseDetails.verificationData.serverVerificationData;
    debugPrint('📄 Receipt data: ${receiptData.length} chars');

    try {
      final response = await ApiProvider.instance.verifyApplePayment(
        _orderId ?? '',
        purchaseDetails.productID,
        _amount ?? '',
        receiptData,
        purchaseDetails.transactionDate ?? '',
      );

      debugPrint(
          'Backend response: ${response.success ?? false ? "✅ SUCCESS" : "❌ FAILED"}');
      if (response.message != null) {
        debugPrint('Message: ${response.message}');
      }

      return response.success ?? false;
    } catch (e) {
      debugPrint('❌ Exception during verification: $e');
      return false;
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    debugPrint('🎉 Delivering product: ${purchaseDetails.productID}');

    setCurrentSubscription(purchaseDetails.productID);
    _purchasePending = false;

    Fluttertoast.showToast(
        msg: "Payment successful! Your subscription is now active.",
        toastLength: Toast.LENGTH_LONG);

    if (_onPurchaseComplete != null) {
      _onPurchaseComplete!();
    }

    Navigation.instance.navigate(Routes.loadingScreen);
    await _updateUserProfile();
  }

  Future<void> _updateUserProfile() async {
    debugPrint('🔄 Updating user profile...');
    try {
      final response = await ApiProvider.instance.getProfile();
      if (response.success ?? false) {
        final context = Navigation.instance.navigatorKey.currentContext;
        if (context != null && context.mounted) {
          Provider.of<Repository>(context, listen: false)
              .setUser(response.user!);
        }
        debugPrint('✅ Profile updated');
        Navigation.instance.goBack();
        Navigation.instance.goBack();
      } else {
        debugPrint('❌ Failed to update profile');
        Navigation.instance.goBack();
        Fluttertoast.showToast(msg: "Failed to update profile");
      }
    } catch (e) {
      debugPrint('❌ Exception updating profile: $e');
      Navigation.instance.goBack();
    }
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    debugPrint('⚠️ Invalid purchase: ${purchaseDetails.productID}');
    _purchasePending = false;

    Fluttertoast.showToast(
        msg: "We couldn't verify your purchase. Please contact support.",
        toastLength: Toast.LENGTH_LONG);

    if (_onPurchaseError != null) {
      _onPurchaseError!();
    }
  }

  void _handlePurchaseError(String message) {
    debugPrint('❌ Purchase error: $message');
    _purchasePending = false;

    final errorLower = message.toLowerCase();
    if (errorLower.contains('usercancelled') ||
        errorLower.contains('user cancelled') ||
        errorLower.contains('cancel')) {
      if (_onPurchaseError != null) {
        _onPurchaseError!();
      }
      return;
    }

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
    );

    if (_onPurchaseError != null) {
      _onPurchaseError!();
    }
  }

  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      Fluttertoast.showToast(msg: "App Store is not available");
      return;
    }

    try {
      debugPrint('🔄 Restoring purchases...');
      Fluttertoast.showToast(msg: "Restoring purchases...");

      // FIX: Clear processed transactions when restoring
      _processedTransactionIds.clear();

      await _inAppPurchase.restorePurchases();
      debugPrint('✅ Restore purchases completed');

      await Future.delayed(Duration(seconds: 2));

      Fluttertoast.showToast(
        msg: "If you had purchases, they have been restored",
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      debugPrint('❌ Error restoring purchases: $e');
      Fluttertoast.showToast(
        msg: "Failed to restore purchases: $e",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  void dispose() {
    debugPrint('🔄 Disposing Apple IAP Service');
    _watchdogTimer?.cancel();
    _subscription.cancel();
    _processedTransactionIds.clear();
  }
}

class ExamplePaymentQueueDelegate extends SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
