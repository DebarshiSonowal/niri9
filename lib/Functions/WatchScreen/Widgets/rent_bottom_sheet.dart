import 'dart:convert';

import 'package:bulleted_list/bulleted_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:niri9/Models/rent_plan_details_response.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../API/api_provider.dart';
import '../../../Models/user.dart';
import '../../../Models/video.dart';
import '../../../Navigation/Navigate.dart';

class RentBottomSheet extends StatefulWidget {
  const RentBottomSheet({
    super.key,
    this.videoDetails,
  });

  final Video? videoDetails;

  @override
  State<RentBottomSheet> createState() => _RentBottomSheetState();
}

class _RentBottomSheetState extends State<RentBottomSheet> {
  int currentIndex = 0;
  final _razorpay = Razorpay();
  String? voucherNo, amount;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Repository>(builder: (context, data, _) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        width: double.infinity,
        height: 95.h,
        padding: EdgeInsets.symmetric(
          horizontal: 6.w,
          vertical: 2.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 3.h,
              ),
              Text(
                widget.videoDetails?.title ?? "Illegal",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
              ),
              SizedBox(
                height: 1.h,
              ),
              Text(
                "${widget.videoDetails?.season_txt} . ${widget.videoDetails?.type_name} . ${widget.videoDetails?.category_name}",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black54,
                      fontSize: 10.sp,
                    ),
              ),
              SizedBox(
                height: 1.h,
              ),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var item = data.rentPlanDetails?.rentList![index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    child: RentPlanItem(
                        item: item, isSelected: currentIndex == index),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 1.5.h,
                  );
                },
                itemCount: data.rentPlanDetails?.rentList?.length ?? 0,
              ),
              BulletedList(
                bullet: Container(
                  height: 1.5.w,
                  width: 1.5.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black54),
                  ),
                ),
                listItems: [
                  for (var i in data.rentPlanDetails?.conditions ?? []) i
                ],
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: const Color(0xffececec),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 2.w,
                  vertical: 1.5.h,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44.w,
                      child: Text(
                        "By renting you agree to our Terms of Use",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.black,
                              // fontWeight: FontWeight.bold,
                              fontSize: 9.sp,
                            ),
                      ),
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    SizedBox(
                      width: 33.w,
                      height: 5.h,
                      child: ElevatedButton(
                        onPressed: () {
                          initiateOrder(
                              Provider.of<Repository>(context, listen: false));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1b5fbd),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // <-- Radius
                          ),
                        ),
                        child: loading
                            ? SizedBox(
                                height: 10,
                                width: 10,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Rent for ₹ ${double.tryParse(data.rentPlanDetails?.rentList![currentIndex].totalPriceInr ?? '0')!.toInt()}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 11.sp,
                                    ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
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
    debugPrint("shoWMeas $options");
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void initiateOrder(Repository data) async {
    setState(() {
      loading = true;
    });
    final response = await ApiProvider.instance.initiateOrder(
      Provider.of<Repository>(context, listen: false)
              .rentPlanDetails
              ?.rentList![currentIndex]
              .id ??
          0,
      data.videoDetails?.id ?? 0,
      1,
    );
    if (response.success ?? false) {
      setState(() {
        voucherNo = response.result?.voucherNo;
        amount = response.result?.grandTotal ?? "0";
        loading = false;
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
      setState(() {
        loading = false;
      });
      Fluttertoast.showToast(msg: response.message ?? "Something Went wrong");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint(
        'success ${response.paymentId} ${response.orderId} ${response.signature}');
    verifyPayment(voucherNo, response.paymentId, amount, context);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    try {
      var resp = json.decode(response.message!);
      debugPrint('error ${resp['error']['description']} ${response.code} ');
      Navigation.instance.goBack();
      // showFailedDialog(
      //   context: context,
      //   // orderId: orderId,
      //   // paymentId: paymentId,
      //   // amount: amount,
      //   message: response.message ?? "Please try again later",
      // );
    } catch (e) {
      Navigation.instance.goBack();
      // showFailedDialog(
      //   context: context,
      //   // orderId: orderId,
      //   // paymentId: paymentId,
      //   // amount: amount,
      //   message: response.message ?? "Please try again later",
      // );
    }
  }

  Future<void> verifyPayment(String? orderId, String? paymentId, String? amount,
      BuildContext context) async {
    final response =
        await ApiProvider.instance.verifyPayment(paymentId, orderId, amount);

    if (response.success ?? false) {
      Fluttertoast.showToast(
          msg: response.message ?? "Payment was successfully");

      // Close the bottom sheet BEFORE showing success dialog
      Navigator.of(context).pop();

      await Future.delayed(Duration(milliseconds: 300)); // smooth transition

      // showSuccessDialog(
      //   context: context,
      //   message: response.message ?? "You have successfully subscribed",
      // );
    } else {
      Fluttertoast.showToast(msg: response.message ?? "Something went wrong");

      // Close the bottom sheet BEFORE showing failure dialog
      Navigator.of(context).pop();

      await Future.delayed(Duration(milliseconds: 300)); // smooth transition

      // showFailedDialog(
      //   context: context,
      //   message: response.message ?? "Please try again later",
      // );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  // void showSuccessDialog(
  //     {required BuildContext context,
  //     // String? orderId,
  //     // String? paymentId,
  //     // String? amount,
  //     String? message}) {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: Text(
  //             "Payment Successful",
  //             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //                   color: Colors.white,
  //                   fontSize: 12.sp,
  //                 ),
  //           ),
  //           content: SuccessfulContentWidget(message: message ?? ""),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigation.instance.goBack();
  //                 Navigator.pop(context);
  //               },
  //               child: Text(
  //                 "Close",
  //                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //                       color: Colors.white70,
  //                       fontSize: 12.sp,
  //                     ),
  //               ),
  //             ),
  //           ],
  //         );
  //       });
  // }

  // void showFailedDialog(
  //     {required BuildContext context,
  //     // String? orderId,
  //     // String? paymentId,
  //     // String? amount,
  //     String? message}) {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: Text(
  //             "Payment Failed",
  //             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //                   color: Colors.white,
  //                   fontSize: 12.sp,
  //                 ),
  //           ),
  //           content: FailedDialogContent(
  //             message: message,
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 // Navigation.instance.goBack();
  //                 Navigator.pop(context);
  //               },
  //               child: Text(
  //                 "Close",
  //                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //                       color: Colors.white70,
  //                       fontSize: 12.sp,
  //                     ),
  //               ),
  //             ),
  //           ],
  //         );
  //       });
  // }
}

class RentPlanItem extends StatelessWidget {
  const RentPlanItem({
    super.key,
    required this.item,
    required this.isSelected,
  });

  final bool isSelected;
  final RentPlan? item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: !isSelected ? Colors.grey.shade100 : Colors.grey.shade300,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 1.5.h,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item?.title ?? "N/A",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.black,
                      // fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                    ),
              ),
              Text(
                item?.duration ?? "15 days",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                    ),
              ),
            ],
          ),
          SizedBox(
            height: 0.4.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Price",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.black,
                      // fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                    ),
              ),
              Text(
                "₹${item?.totalPriceInr ?? "N/A"}",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.sp,
                    ),
              ),
            ],
          ),
          Divider(
            thickness: 0.2.h,
            color: const Color(0xffc1c1c1),
          ),
          Text(
            item?.watchTimeTxt ?? "",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.black,
                  // fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
                ),
          ),
        ],
      ),
    );
  }
}
