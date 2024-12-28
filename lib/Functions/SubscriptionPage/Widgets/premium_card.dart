import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:intl/intl.dart';
import 'package:niri9/main.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/constants.dart';
import '../../../Repository/repository.dart';
import '../../../Widgets/gradient_text.dart';

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<Repository>(builder: (context, data, _) {
      return data.user?.last_sub == null
          ? Container()
          : Card(
              margin: EdgeInsets.symmetric(
                horizontal: 13.w,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Constants.subscriptionCardBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 1.5.h,
                  horizontal: 8.w,
                ),
                child: Column(
                  children: [
                    GradientText(
                      data.user?.last_sub?.lastSubscription?.title ?? "Premium",
                      style: TextStyle(
                        fontSize: 15.sp,
                      ),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff7338b0),
                          Color(0xffb61d73),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    Text(
                      "INR ₹${double.parse((data.user?.last_sub?.lastSubscription?.totalPriceInr ?? 599).toString()).toInt()}",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                    ),
                    SizedBox(
                      height: 2.5.h,
                    ),
                    Text(
                      (data.user?.last_sub?.lastSubscription?.planType ??
                              "For 365 Days")
                          .capitalize(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white30,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                    ),
                    SizedBox(
                      height: 2.5.h,
                    ),
                    Text(
                      "Date of Purchase: ${DateFormat("dd MMM,yyyy").format(DateTime.parse(data.user?.last_sub?.lastSubscription?.updatedAt ?? ""))}",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            // fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                    ),
                    SizedBox(
                      height: 2.5.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 0.5.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 25.w,
                            child: Text(
                              "Status:",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white30,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                            ),
                          ),
                          SizedBox(
                            width: 19.w,
                            child: Text(
                              "Active",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.white30,
                      height: 0.2.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 0.5.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 25.w,
                            child: Text(
                              "Duration:",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white30,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                            ),
                          ),
                          SizedBox(
                            width: 19.w,
                            child: Text(
                              "${data.user?.last_sub?.lastSubscription?.duration}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.white30,
                      height: 0.2.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 0.5.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 25.w,
                            child: Text(
                              "No Of Screens:",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white30,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                            ),
                          ),
                          SizedBox(
                            width: 19.w,
                            child: Text(
                              "${data.user?.last_sub?.lastSubscription?.noOfScreens}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.white30,
                      height: 0.2.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 0.5.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 25.w,
                            child: Text(
                              "Auto Renewal:",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white30,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                            ),
                          ),
                          SizedBox(
                            width: 19.w,
                            child: Text(
                              "No",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.white30,
                      height: 0.2.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 0.5.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 25.w,
                            child: Text(
                              "Expiry Date:",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white30,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                            ),
                          ),
                          SizedBox(
                            width: 19.w,
                            child: Text(
                              DateFormat('dd MMM yyyy').format(
                                  DateTime.parse(data.user?.expiry_date ?? "")),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.white30,
                      height: 0.2.h,
                    ),
                  ],
                ),
              ),
            );
    });
  }
}
