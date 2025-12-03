import 'dart:convert';

import 'package:bulleted_list/bulleted_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:niri9/Constants/constants.dart';
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
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Repository>(builder: (context, data, _) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Constants.backgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.videoDetails?.title ?? "Content",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 19.sp,
                        ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    "${widget.videoDetails?.season_txt ?? ''}${widget.videoDetails?.season_txt != null && widget.videoDetails?.type_name != null ? ' • ' : ''}${widget.videoDetails?.type_name ?? ''}${widget.videoDetails?.type_name != null && widget.videoDetails?.category_name != null ? ' • ' : ''}${widget.videoDetails?.category_name ?? ''}",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[400],
                          fontSize: 13.sp,
                        ),
                  ),
                  SizedBox(height: 3.h),
                ],
              ),
            ),
            // Rent plans list
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                itemBuilder: (context, index) {
                  var item = data.rentPlanDetails?.rentList![index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    child: RentPlanItem(
                      item: item,
                      isSelected: currentIndex == index,
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 2.h);
                },
                itemCount: data.rentPlanDetails?.rentList?.length ?? 0,
              ),
            ),
            SizedBox(height: 2.h),
            // Conditions
            if (data.rentPlanDetails?.conditions != null &&
                data.rentPlanDetails!.conditions!.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Terms & Conditions",
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15.sp,
                              ),
                    ),
                    SizedBox(height: 1.h),
                    BulletedList(
                      bullet: Container(
                        height: 1.2.w,
                        width: 1.2.w,
                        decoration: BoxDecoration(
                          color: Constants.thirdColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      listItems: [
                        for (var i in data.rentPlanDetails!.conditions!)
                          Text(
                            i,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[300],
                                  fontSize: 14.sp,
                                ),
                          )
                      ],
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            // Footer with button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Constants.secondaryColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 5.w,
                vertical: 2.5.h,
              ),
              child: Column(
                children: [
                  Text(
                    "By renting you agree to our Terms of Use",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[400],
                          fontSize: 14.sp,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: loading
                          ? null
                          : () {
                              initiateOrder(Provider.of<Repository>(context,
                                  listen: false));
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.thirdColor,
                        disabledBackgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: loading
                          ? SizedBox(
                              height: 2.5.h,
                              width: 2.5.h,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.movie_creation_outlined,
                                  color: Colors.white,
                                  size: 18.sp,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Rent for ₹${double.tryParse(data.rentPlanDetails?.rentList![currentIndex].totalPriceInr ?? '0')!.toInt()}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                      ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  void initiatePayment(
      {required double total, User? profile, required id, String? rzp_key}) {
    var options = {
      'key': rzp_key,
      'amount': "${total * 100}",
      'description': 'Rent Payment',
      'prefill': {
        'contact': profile?.mobile ?? "",
        'order_id': id,
        'email': profile?.email ?? ""
      },
    };
    debugPrint("Payment options: $options");
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
    try {
      var resp = json.decode(response.message!);
      debugPrint('error ${resp['error']['description']} ${response.code} ');
      Navigation.instance.goBack();
    } catch (e) {
      Navigation.instance.goBack();
    }
  }

  Future<void> verifyPayment(String? orderId, String? paymentId, String? amount,
      BuildContext context) async {
    final response =
        await ApiProvider.instance.verifyPayment(paymentId, orderId, amount);

    if (response.success ?? false) {
      Fluttertoast.showToast(msg: response.message ?? "Payment was successful");

      Navigator.of(context).pop();

      await Future.delayed(const Duration(milliseconds: 300));
    } else {
      Fluttertoast.showToast(msg: response.message ?? "Something went wrong");

      Navigator.of(context).pop();

      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  Constants.selectedPlanColor.withOpacity(0.3),
                  Constants.selectedPlanColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: !isSelected ? Constants.secondaryColor : null,
        border: Border.all(
          color: isSelected
              ? Constants.selectedPlanColor
              : Colors.white.withOpacity(0.1),
          width: isSelected ? 2.0 : 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Constants.selectedPlanColor.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 2.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item?.title ?? "N/A",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Constants.selectedPlanColor
                      : Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item?.duration ?? "15 days",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Price",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[400],
                      fontSize: 13.sp,
                    ),
              ),
              Text(
                "₹${item?.totalPriceInr ?? "N/A"}",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Constants.planButtonColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 19.sp,
                    ),
              ),
            ],
          ),
          if (item?.watchTimeTxt != null && item!.watchTimeTxt!.isNotEmpty) ...[
            SizedBox(height: 1.5.h),
            Divider(
              thickness: 0.5,
              color: Colors.grey[700],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.grey[400],
                  size: 14.sp,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    item!.watchTimeTxt!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[300],
                          fontSize: 13.sp,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
