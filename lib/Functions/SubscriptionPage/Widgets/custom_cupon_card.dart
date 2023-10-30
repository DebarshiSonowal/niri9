import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/constants.dart';

class CustomCuponCard extends StatelessWidget {
  const CustomCuponCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CouponCard(
      backgroundColor: Colors.white,
      firstChild: Container(
        padding: EdgeInsets.symmetric(

          horizontal: 2.w,
        ),
        height: 10.h,
        width: 4.w,
        color: Constants.selectedPlanColor,
        child: Column(
          children: [
            SizedBox(
              height: 0.5.h,
            ),
            Text(
              "CHRISTMAS SALES",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 10.sp,
              ),
            ),
            SizedBox(
              height: 0.5.h,
            ),
            Text(
              "16%\nOFF",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22.sp,
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            DottedDashedLine(height: 0.1.h, width: double.infinity, axis: Axis.horizontal,dashColor: Colors.white,),
          ],
        ),
      ),
      secondChild: Container(
        padding: EdgeInsets.symmetric(
          vertical: 0.5.h,
          horizontal: 2.w,
        ),
        height: 10.h,
        width: double.infinity,
        color: Constants.selectedPlanColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 1.w,
                vertical: 0.5.h,
              ),
              // height: 4.h,
              width: 20.w,
              child: Center(
                child: Text(
                  "Apply",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}