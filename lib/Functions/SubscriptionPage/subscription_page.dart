import 'dart:convert';

import 'package:animated_background/animated_background.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Constants/assets.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Helper/storage.dart';
import 'package:niri9/Models/plan_pricing.dart';
import 'package:niri9/Models/subscription.dart';
import 'package:niri9/Models/user.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Router/routes.dart';
import 'package:niri9/Widgets/gradient_text.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../Repository/repository.dart';
import '../../Widgets/failed_dialogue_content.dart';
import 'Widgets/benifits_widget.dart';
import 'Widgets/plan_column.dart';
import 'Widgets/plans_section.dart';
import 'Widgets/premium_card.dart';
import 'Widgets/subscription_appbar.dart';
import '../../Widgets/successful_content_widget.dart';
import 'Widgets/type_column.dart';

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
  int currentAmount = 419;

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    Future.delayed(Duration.zero, () {
      fetchSubscription();
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: PreferredSize(
    //     preferredSize: Size.fromHeight(7.h),
    //     child: const SubscriptionAppbar(
    //       title: "Subscription",
    //     ),
    //   ),
    //   backgroundColor: Constants.subscriptionBg,
    //   body: Container(
    //     padding: EdgeInsets.symmetric(
    //       horizontal: 1.w,
    //       vertical: 2.h,
    //     ),
    //     height: double.infinity,
    //     width: double.infinity,
    //     child: SingleChildScrollView(
    //       child: Column(
    //         children: [
    //           const PremiumCard(),
    //           SizedBox(
    //             height: 5.h,
    //           ),
    //           Consumer<Repository>(builder: (context, data, _) {
    //             return Container(
    //               padding: EdgeInsets.symmetric(
    //                 horizontal: 2.w,
    //                 vertical: 1.h,
    //               ),
    //               margin: EdgeInsets.symmetric(
    //                 horizontal: 2.w,
    //               ),
    //               color: const Color(0xff0b071e),
    //               width: double.infinity,
    //               height: 42.5.h,
    //               child: Column(
    //                 children: [
    //                   Expanded(
    //                     child: SizedBox(
    //                       width: double.infinity,
    //                       child: Row(
    //                         children: [
    //                           const TypeColumn(),
    //                           PlanColumn(
    //                             displayData: data.subscriptions[0].displayData!,
    //                             index: 0,
    //                             plan_type: data.subscriptions[0].plan_type!,
    //                             discount: data.subscriptions[0].discount!,
    //                             total_price:
    //                                 data.subscriptions[0].total_price_inr!,
    //                             base_price:
    //                                 data.subscriptions[0].base_price_inr!,
    //                             selected: selected,
    //                             updateSet: (int val) {
    //                               setState(() {
    //                                 selected = val;
    //                               });
    //                             },
    //                           ),
    //                           PlanColumn(
    //                             displayData: data.subscriptions[1].displayData!,
    //                             index: 1,
    //                             plan_type: data.subscriptions[1].plan_type!,
    //                             discount: data.subscriptions[1].discount!,
    //                             total_price:
    //                                 data.subscriptions[1].total_price_inr!,
    //                             base_price:
    //                                 data.subscriptions[1].base_price_inr!,
    //                             selected: selected,
    //                             updateSet: (int val) {
    //                               setState(() {
    //                                 selected = val;
    //                               });
    //                             },
    //                           ),
    //                           PlanColumn(
    //                             displayData: data.subscriptions[2].displayData!,
    //                             index: 2,
    //                             plan_type: data.subscriptions[2].plan_type!,
    //                             discount: data.subscriptions[2].discount!,
    //                             total_price:
    //                                 data.subscriptions[2].total_price_inr!,
    //                             base_price:
    //                                 data.subscriptions[2].base_price_inr!,
    //                             selected: selected,
    //                             updateSet: (int val) {
    //                               setState(() {
    //                                 selected = val;
    //                               });
    //                             },
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ),
    //                   Container(
    //                     margin: EdgeInsets.symmetric(
    //                       horizontal: 4.w,
    //                     ),
    //                     padding: EdgeInsets.symmetric(
    //                       vertical: 0.5.h,
    //                     ),
    //                     width: double.infinity,
    //                     child: ElevatedButton(
    //                       style: ElevatedButton.styleFrom(
    //                         backgroundColor: Constants.planButtonColor,
    //                       ),
    //                       onPressed: () {
    //                         initiateOrder(data);
    //                       },
    //                       child: Center(
    //                         child: Text(
    //                           "Continue",
    //                           style: Theme.of(context)
    //                               .textTheme
    //                               .headlineMedium
    //                               ?.copyWith(
    //                                 color: const Color(0xff002215),
    //                               ),
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                   GestureDetector(
    //                     onTap: () {
    //                       Navigation.instance.navigate(Routes.cuponApply);
    //                     },
    //                     child: Text(
    //                       'Apply Promo Code',
    //                       style: TextStyle(
    //                         color: Colors.white,
    //                         decoration: TextDecoration.underline,
    //                         // fontWeight: FontWeight.bold,
    //                         fontSize: 9.sp,
    //                         decorationColor: Colors.white,
    //                       ),
    //                     ),
    //                   ),
    //                   SizedBox(
    //                     height: 1.h,
    //                   ),
    //                 ],
    //               ),
    //             );
    //           }),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
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
              padding: EdgeInsets.symmetric(
                horizontal: 3.w,
                // vertical: 0.5.h,
              ),
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
          padding: EdgeInsets.symmetric(
            horizontal: 4.w,
          ),
          height: 100.h,
          width: 100.w,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                BenefitsWidget(
                  selected: selected,
                ),
                PlansSection(
                  selected: selected,
                  onTap: (int val) {
                    setState(() {
                      selected = val;
                    });
                  },
                  upgrade: () {
                    if (Storage.instance.isLoggedIn) {
                      initiateOrder(
                          Provider.of<Repository>(context, listen: false));
                    } else {
                      Fluttertoast.showToast(
                          msg: "Please Log In before buying a subscription");
                    }
                  },
                ),
              ],
            ),
          ),
          // child: ,
          // ),
        ),
      ),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // """debugPrint(
    //     'success ${response.paymentId} ${response.orderId} ${response.signature}'
    //     )""";
    verifyPayment(voucherNo, response.paymentId, amount, context);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    try {
      var resp = json.decode(response.message!);
      debugPrint('error ${resp['error']['description']} ${response.code} ');
      Navigation.instance.goBack();
      showFailedDialog(
        context: context,
        // orderId: orderId,
        // paymentId: paymentId,
        // amount: amount,
        message: response.message ?? "Please try again later",
      );
    } catch (e) {
      Navigation.instance.goBack();
      showFailedDialog(
        context: context,
        // orderId: orderId,
        // paymentId: paymentId,
        // amount: amount,
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
          if (response.subscriptions.indexWhere((element) =>
                  (element.id ?? 0) == user?.last_sub?.lastSubscription?.id) >=
              0) {
            selected = response.subscriptions.indexWhere((element) =>
                (element.id ?? 0) == user?.last_sub?.lastSubscription?.id);
          }
        } else {
          selected = response.subscriptions
                  .indexWhere((element) => (element.is_default ?? 0) == 1) ??
              0;
        }
      });
    }
  }

  void initiatePayment(
      {required double total, User? profile, required id, String? rzp_key}) {
    var options = {
      'key': rzp_key,
      // 'key': FlutterConfig.get('RAZORPAY_KEY'),
      'amount': "${total * 100}",
      // 'order_id': id,
      // "image": "https://tratri.in/assets/assets/images/logos/logo-razorpay.jpg",
      // 'name': '${profile?.f_name} ${profile?.l_name}',
      'description': 'Books',
      'prefill': {
        'contact': profile?.mobile ?? "",
        'order_id': id,
        'email': profile?.email ?? ""
      },
      // 'note': {
      //   'customer_id': customer_id,
      //   'order_id': id,
      // },
    };
    debugPrint("$options");
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void initiateOrder(Repository data) async {
    final response = await ApiProvider.instance
        .initiateOrder(data.subscriptions[selected].id ?? 0, 0, 0);
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
                listen: false)
            .user,
        id: response.result?.voucherNo ?? "",
      );
    } else {
      Fluttertoast.showToast(msg: response.message ?? "Something Went wrong");
    }
  }

  Future<void> fetchProfile() async {
    // Navigation.instance.navigate(Routes.loadingScreen);
    final response = await ApiProvider.instance.getProfile();
    if (response.success ?? false) {
      // Navigation.instance.goBack();
      // Storage.instance.
      Provider.of<Repository>(context, listen: false).setUser(response.user!);
      debugPrint("User: ${response.user?.last_sub}");
    } else {
      // Navigation.instance.goBack();
      // showError(response.message ?? "Something went wrong");
    }
  }

  Future<void> verifyPayment(String? orderId, String? paymentId, String? amount,
      BuildContext context) async {
    Navigation.instance.navigate(Routes.loadingScreen);
    final response =
        await ApiProvider.instance.verifyPayment(paymentId, orderId, amount);
    if (response.success ?? false) {
      Fluttertoast.showToast(
          msg: response.message ?? "Payment was successfully");
      // showDialog(context: context, builder: builder);

      await fetchProfile();
      Navigation.instance.goBack();
      showSuccessDialog(
        context: context,
        // orderId: orderId,
        // paymentId: paymentId,
        // amount: amount,
        message: response.message ?? "You have successfully subscribed",
      );
      Navigation.instance.goBack();
    } else {
      Navigation.instance.goBack();
      Fluttertoast.showToast(msg: response.message ?? "Something went wrong");
      showFailedDialog(
        context: context,
        // orderId: orderId,
        // paymentId: paymentId,
        // amount: amount,
        message: response.message ?? "Please try again later",
      );
      Navigation.instance.goBack();
    }
  }

  void showSuccessDialog(
      {required BuildContext context,
      // String? orderId,
      // String? paymentId,
      // String? amount,
      String? message}) {
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
        });
  }

  void showFailedDialog(
      {required BuildContext context,
      // String? orderId,
      // String? paymentId,
      // String? amount,
      String? message}) {
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
            content: FailedDialogContent(
              message: message,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Navigation.instance.goBack();
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
        });
  }
}
