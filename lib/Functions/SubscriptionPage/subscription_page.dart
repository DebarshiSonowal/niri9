import 'dart:convert';
import 'dart:io';

import 'package:animated_background/animated_background.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Constants/assets.dart';
import 'package:niri9/Helper/storage.dart';
import 'package:niri9/Models/user.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Router/routes.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Repository/repository.dart';
import '../../Services/apple_iap_service.dart';
import '../../Widgets/failed_dialogue_content.dart';
import 'Widgets/benifits_widget.dart';
import 'Widgets/plans_section.dart';
import '../../Widgets/successful_content_widget.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage>
    with TickerProviderStateMixin {
  int selected = 2;
  final _razorpay = Razorpay();
  String? voucherNo, amount;
  bool _isProcessing = false;
  final AppleIAPService _iapService = AppleIAPService.instance;

  @override
  void initState() {
    super.initState();

    // Set up Razorpay only for Android
    if (Platform.isAndroid) {
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }

    Future.delayed(Duration.zero, () {
      fetchSubscription();
      if (Platform.isIOS) {
        _initializeIAP();
      }
    });
  }

  Future<void> _initializeIAP() async {
    try {
      debugPrint('🚀 Initializing IAP for iOS...');
      final initialized = await _iapService.initialize();

      if (!initialized) {
        debugPrint('❌ Failed to initialize IAP');

        // Show helpful message for simulator
        if (!kReleaseMode) {
          Fluttertoast.showToast(
            msg: "Could not load subscriptions. Check StoreKit Configuration.",
            toastLength: Toast.LENGTH_LONG,
          );
        }
      } else {
        debugPrint('✅ IAP initialized successfully');
        debugPrint('📦 Available products: ${_iapService.products.length}');

        // Log all loaded products for debugging
        for (var product in _iapService.products) {
          debugPrint('   📱 Product: ${product.id}');
          debugPrint('      Title: ${product.title}');
          debugPrint('      Price: ${product.price}');
        }

        // Trigger UI rebuild to show StoreKit prices
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('❌ Error initializing IAP: $e');
    }
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      _razorpay.clear();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(7.h),
        child: SafeArea(
          child: AnimatedBackground(
            behaviour: RandomParticleBehaviour(
              options: ParticleOptions(
                spawnMaxRadius: 20.w,
                spawnMaxSpeed: 20.00,
                particleCount: 5,
                spawnMinSpeed: 10.00,
                minOpacity: 0.3,
                spawnOpacity: 0.4,
                image: Image.asset(Assets.logoTransparent),
              ),
            ),
            vsync: this,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigation.instance.goBack();
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                      // Show restore button for iOS
                      if (Platform.isIOS)
                        TextButton(
                          onPressed: _restorePurchases,
                          child: Text(
                            'Restore',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          height: 100.h,
          width: 100.w,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                BenefitsWidget(selected: selected),
                PlansSection(
                  selected: selected,
                  onTap: (int val) {
                    setState(() {
                      selected = val;
                    });
                  },
                  upgrade: _handleUpgradePressed,
                  // Pass IAP service for iOS prices
                  iapService: Platform.isIOS ? _iapService : null,
                ),
                SizedBox(height: 1.h),
                _buildRequiredDisclosures(),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequiredDisclosures() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscription Information',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            Platform.isIOS
                ? '• Payment will be charged to your Apple ID account at confirmation of purchase\n'
                    '• Subscription automatically renews unless cancelled at least 24 hours before the end of the current period\n'
                    '• Your account will be charged for renewal within 24 hours prior to the end of the current period\n'
                    '• You can manage and cancel your subscriptions in your App Store account settings'
                : '• Payment will be charged to your account at confirmation of purchase\n'
                    '• Subscription automatically renews unless cancelled\n'
                    '• You can manage and cancel your subscriptions in your account settings',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  fontSize: 12.sp,
                  height: 1.4,
                ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _openPrivacyPolicy,
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 13.sp,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(' | ', style: TextStyle(color: Colors.white70)),
              TextButton(
                onPressed: _openTermsOfUse,
                child: Text(
                  'Terms of Use (EULA)',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 13.sp,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openPrivacyPolicy() {
    launchUrl(
      Uri.parse('https://niri9.com/privacy'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _openTermsOfUse() {
    launchUrl(
      Uri.parse('https://niri9.com/terms-and-condition'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _handleUpgradePressed() async {
    if (_isProcessing) {
      Fluttertoast.showToast(msg: "Processing previous request...");
      return;
    }

    if (!Storage.instance.isLoggedIn) {
      Fluttertoast.showToast(msg: "Please Log In before buying a subscription");
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      if (Platform.isIOS) {
        await _handleIOSPurchase();
      } else if (Platform.isAndroid) {
        _handleRazorpayPurchase();
      }
    } finally {
      if (Platform.isIOS) {
        // Don't reset for iOS immediately as purchase is async
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
          }
        });
      } else {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _handleIOSPurchase() async {
    final repo = Provider.of<Repository>(context, listen: false);
    final subscriptionId = repo.subscriptions[selected].id ?? 0;

    debugPrint('🛒 Starting iOS purchase - Subscription ID: $subscriptionId');

    // Create order on backend first
    final response =
        await ApiProvider.instance.initiateOrder(subscriptionId, 0, 0);

    if (!(response.success ?? false)) {
      Fluttertoast.showToast(msg: response.message ?? "Failed to create order");
      return;
    }

    setState(() {
      voucherNo = response.result?.voucherNo;
      amount = response.result?.grandTotal ?? "0";
    });

    // Initiate StoreKit purchase
    final success = await _iapService.buySubscriptionById(
      subscriptionId,
      voucherNo ?? '',
      amount ?? '0',
      onComplete: () {
        debugPrint('✅ Purchase completed successfully');
        showSuccessDialog(
          context: context,
          message: "Your subscription is now active!",
        );
        setState(() {
          _isProcessing = false;
        });
      },
      onError: () {
        debugPrint('❌ Purchase failed or cancelled');
        setState(() {
          _isProcessing = false;
        });
      },
    );

    if (!success) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _handleRazorpayPurchase() {
    final repo = Provider.of<Repository>(context, listen: false);
    initiateOrder(repo);
  }

  void _restorePurchases() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await _iapService.restorePurchases();
      await fetchProfile();
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Razorpay handlers (Android only)
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    verifyPayment(voucherNo, response.paymentId, amount, context);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    try {
      var resp = json.decode(response.message!);
      debugPrint('error ${resp['error']['description']} ${response.code}');
      Navigation.instance.goBack();
      showFailedDialog(
        context: context,
        message: response.message ?? "Please try again later",
      );
    } catch (e) {
      Navigation.instance.goBack();
      showFailedDialog(
        context: context,
        message: response.message ?? "Please try again later",
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  void fetchSubscription() async {
    final response = await ApiProvider.instance.getSubscriptions();
    if (response.success ?? false) {
      Provider.of<Repository>(context, listen: false)
          .addSubscriptions(response);
      final user = Provider.of<Repository>(context, listen: false).user;
      setState(() {
        if (user?.has_subscription ?? false) {
          final index = response.subscriptions.indexWhere((element) =>
              (element.id ?? 0) == user?.last_sub?.lastSubscription?.id);
          if (index >= 0) {
            selected = index;
          }
        } else {
          final defaultIndex = response.subscriptions
              .indexWhere((element) => (element.is_default ?? 0) == 1);
          selected = defaultIndex >= 0 ? defaultIndex : 0;
        }
      });
    }
  }

  void initiatePayment({
    required double total,
    User? profile,
    required id,
    String? rzp_key,
  }) {
    var options = {
      'key': rzp_key,
      'amount': "${total * 100}",
      'description': 'Books',
      'prefill': {
        'contact': profile?.mobile ?? "",
        'order_id': id,
        'email': profile?.email ?? ""
      },
    };
    debugPrint("$options");
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void initiateOrder(Repository data) async {
    final response = await ApiProvider.instance.initiateOrder(
      data.subscriptions[selected].id ?? 0,
      0,
      0,
    );
    if (response.success ?? false) {
      setState(() {
        voucherNo = response.result?.voucherNo;
        amount = response.result?.grandTotal ?? "0";
      });
      initiatePayment(
        rzp_key: response.result?.rzp_key ?? "",
        total: double.parse(response.result?.grandTotal ?? "0"),
        profile: Provider.of<Repository>(
          Navigation.instance.navigatorKey.currentContext ?? context,
          listen: false,
        ).user,
        id: response.result?.voucherNo ?? "",
      );
    } else {
      Fluttertoast.showToast(msg: response.message ?? "Something Went wrong");
    }
  }

  Future<void> fetchProfile() async {
    final response = await ApiProvider.instance.getProfile();
    if (response.success ?? false) {
      Provider.of<Repository>(context, listen: false).setUser(response.user!);
      debugPrint("User: ${response.user?.last_sub}");
    }
  }

  Future<void> verifyPayment(
    String? orderId,
    String? paymentId,
    String? amount,
    BuildContext context,
  ) async {
    Navigation.instance.navigate(Routes.loadingScreen);
    final response = await ApiProvider.instance.verifyPayment(
      paymentId,
      orderId,
      amount,
    );
    if (response.success ?? false) {
      Fluttertoast.showToast(msg: response.message ?? "Payment was successful");

      await fetchProfile();
      Navigation.instance.goBack();
      showSuccessDialog(
        context: context,
        message: response.message ?? "You have successfully subscribed",
      );
      Navigation.instance.goBack();
    } else {
      Navigation.instance.goBack();
      Fluttertoast.showToast(msg: response.message ?? "Something went wrong");
      showFailedDialog(
        context: context,
        message: response.message ?? "Please try again later",
      );
      Navigation.instance.goBack();
    }
  }

  void showSuccessDialog({required BuildContext context, String? message}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Payment Successful",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 12.sp,
                ),
          ),
          content: SuccessfulContentWidget(message: message ?? ""),
          actions: [
            TextButton(
              onPressed: () {
                Navigation.instance.goBack();
                Navigator.pop(context);
              },
              child: Text(
                "Close",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontSize: 12.sp,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showFailedDialog({required BuildContext context, String? message}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Payment Failed",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 12.sp,
                ),
          ),
          content: FailedDialogContent(message: message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Close",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontSize: 12.sp,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}
