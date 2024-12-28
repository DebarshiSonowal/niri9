import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:niri9/Models/display_data.dart';
import 'package:niri9/main.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/constants.dart';
import '../../../Models/plan_pricing.dart';

class PlanColumn extends StatelessWidget {
  final int selected;

  PlanColumn({
    super.key,
    required this.displayData,
    required this.index,
    required this.selected,
    required this.updateSet, required this.plan_type, required this.discount, required this.total_price, required this.base_price,
  });

  final DisplayData displayData;
  final int index;
  final String plan_type;
  final double discount,total_price,base_price;
  //    plan_type: data.subscriptions[0].plan_type,
  //    discount: data.subscriptions[0].discount,
  //    total_price: data.subscriptions[0].total_price_inr,
  final Function(int) updateSet;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: selected == index
              ? Constants.selectedPlanColor
              : Colors.transparent,
        ),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 3.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    plan_type.capitalize(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Constants.planButtonColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 8.sp,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 3.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (displayData.mso?.value ?? false)
                      ? Icon(
                          FontAwesomeIcons.check,
                          size: 8.sp,
                        )
                      : Icon(
                          FontAwesomeIcons.close,
                          size: 8.sp,
                        ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 3.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (displayData.watch_tv?.value ?? false)
                      ? Icon(
                          FontAwesomeIcons.check,
                          size: 8.sp,
                        )
                      : Icon(
                          FontAwesomeIcons.close,
                          size: 8.sp,
                        ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 3.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (displayData.ad?.value ?? false)
                      ? Icon(
                          FontAwesomeIcons.check,
                          size: 8.sp,
                        )
                      : Icon(
                          FontAwesomeIcons.close,
                          size: 8.sp,
                        ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 3.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${displayData.screens?.value}",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: index == selected
                              ? Colors.white
                              : Constants.plansColor,
                          fontSize: 8.sp,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 3.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${displayData.quality?.value}",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: index == selected
                              ? Colors.white
                              : Constants.plansColor,
                          fontSize: 8.sp,
                        ),
                  ),
                ],
              ),
            ),
            DottedLine(
              lineLength: double.infinity,
              dashColor: Colors.white70,
              lineThickness: 0.05.h,
            ),
            SizedBox(
              height: 1.5.h,
            ),
            SizedBox(
              width: double.infinity,
              // height: 13.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  index == 0
                      ? Container(
                          height: 1.3.h,
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.5.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "$base_price",
                                style: TextStyle(
                                  color: index == selected
                                      ? Colors.white
                                      : Constants.plansColor,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.white,
                                  fontSize: 7.sp,
                                ),
                              ),
                              SizedBox(
                                width: 0.5.w,
                              ),
                              Container(
                                color: const Color(0xfffade60),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 0.5.w,
                                  vertical: 0.1.h,
                                ),
                                child: Text(
                                  "$discount OFF",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 5.sp,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  SizedBox(
                    height: 1.5.h,
                  ),
                  Text(
                    "₹$total_price/${plan_type.substring(0,1)}",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Constants.planButtonColor,
                          fontSize: 9.sp,
                        ),
                  ),
                  Transform.scale(
                    scale: 0.7,
                    child: Radio(
                      value: index,
                      activeColor: Colors.white,
                      groupValue: selected,
                      onChanged: (int? value) {
                        updateSet(value ?? index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
