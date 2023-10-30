import 'dart:convert';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Models/plan_pricing.dart';
import 'package:niri9/Models/user.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Router/routes.dart';
import 'package:niri9/Widgets/gradient_text.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../Repository/repository.dart';
import 'Widgets/plan_column.dart';
import 'Widgets/premium_card.dart';
import 'Widgets/subscription_appbar.dart';
import 'Widgets/type_column.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int selected = 2;
  final _razorpay = Razorpay();

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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(7.h),
        child: const SubscriptionAppbar(title: "Subscription",),
      ),
      backgroundColor: Constants.subscriptionBg,
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 1.w,
          vertical: 2.h,
        ),
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const PremiumCard(),
              SizedBox(
                height: 5.h,
              ),
              Consumer<Repository>(builder: (context, data, _) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 1.h,
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: 2.w,
                  ),
                  color: const Color(0xff0b071e),
                  width: double.infinity,
                  height: 42.5.h,
                  child: Column(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: Row(
                            children: [
                              const TypeColumn(),
                              PlanColumn(
                                displayData: data.subscriptions[0].displayData!,
                                index: 0,
                                plan_type: data.subscriptions[0].plan_type!,
                                discount: data.subscriptions[0].discount!,
                                total_price:
                                    data.subscriptions[0].total_price_inr!,
                                base_price:
                                    data.subscriptions[0].base_price_inr!,
                                selected: selected,
                                updateSet: (int val) {
                                  setState(() {
                                    selected = val;
                                  });
                                },
                              ),
                              PlanColumn(
                                displayData: data.subscriptions[1].displayData!,
                                index: 1,
                                plan_type: data.subscriptions[1].plan_type!,
                                discount: data.subscriptions[1].discount!,
                                total_price:
                                    data.subscriptions[1].total_price_inr!,
                                base_price:
                                    data.subscriptions[1].base_price_inr!,
                                selected: selected,
                                updateSet: (int val) {
                                  setState(() {
                                    selected = val;
                                  });
                                },
                              ),
                              PlanColumn(
                                displayData: data.subscriptions[2].displayData!,
                                index: 2,
                                plan_type: data.subscriptions[2].plan_type!,
                                discount: data.subscriptions[2].discount!,
                                total_price:
                                    data.subscriptions[2].total_price_inr!,
                                base_price:
                                    data.subscriptions[2].base_price_inr!,
                                selected: selected,
                                updateSet: (int val) {
                                  setState(() {
                                    selected = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 4.w,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 0.5.h,
                        ),
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Constants.planButtonColor,
                          ),
                          onPressed: () {
                            // initiateOrder();
                          },
                          child: Center(
                            child: Text(
                              "Continue",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: const Color(0xff002215),
                                  ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap:(){
                          Navigation.instance.navigate(Routes.cuponApply);
                        },
                        child: Text(
                          'Apply Promo Code',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            // fontWeight: FontWeight.bold,
                            fontSize: 9.sp,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint(
        'success ${response.paymentId} ${response.orderId} ${response.signature}');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    try {
      var resp = json.decode(response.message!);
      debugPrint('error ${resp['error']['description']} ${response.code} ');
      Navigation.instance.goBack();
    } catch (e) {
      Navigation.instance.goBack();
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  void fetchSubscription() async {
    final response = await ApiProvider.instance.getSubscriptions();
    if (response.success ?? false) {
      Provider.of<Repository>(context, listen: false)
          .addSubscriptions(response);
      setState(() {
        selected = response.subscriptions
                .indexWhere((element) => (element.is_default ?? 0) == 1) ??
            0;
      });
    }
  }

  void initiatePayment({required double total, User? profile, required id}) {
    var options = {
      'key': 'jMpgLbygk3LidMcKkrq0zGJ6',
      // 'key': FlutterConfig.get('RAZORPAY_KEY'),
      'amount': "${total * 100}",
      'order_id': id,
      "image": "https://tratri.in/assets/assets/images/logos/logo-razorpay.jpg",
      'name': '${profile?.f_name} ${profile?.l_name}',
      'description': 'Books',
      'prefill': {'contact': profile?.mobile??"", 'email': profile?.email??""},
      // 'note': {
      //   'customer_id': customer_id,
      //   'order_id': id,
      // },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void initiateOrder(Repository data) async{
    // final response = await ApiProvider.instance.initiateOrder();
    // if(response.success??false){
    //   initiatePayment(
    //       total: data.subscriptions[selected]
    //           .total_price_inr ??
    //           0,
    //       profile: Provider.of<Repository>(
    //           Navigation.instance.navigatorKey
    //               .currentContext ??
    //               context,
    //           listen: false)
    //           .user,
    //       id:
    //   );
    // }else{
    //
    // }
  }
}
