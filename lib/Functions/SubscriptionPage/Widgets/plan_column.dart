import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/constants.dart';
import '../../../Models/plan_pricing.dart';

class PlanColumn extends StatelessWidget {
  final int selected;

  PlanColumn({
    super.key,
    required this.plan,
    required this.index,
    required this.selected,
    required this.updateSet,
  });

  final List<PlanPricing> plan;
  final int index;
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
                    plan[index].name ?? "",
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
                  (plan[index].movies ?? false)
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
                  (plan[index].tv ?? false)
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
                  (plan[index].ad ?? false)
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
                    "${plan[index].screenNumber}",
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
                    "${plan[index].resolution}",
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
                                "${plan[index].price}",
                                style: TextStyle(
                                  color: index==selected?Colors.white:Constants.plansColor,
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
                                  "50% OFF",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 6.sp,
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
                    "₹${plan[index].price}/yr",
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
