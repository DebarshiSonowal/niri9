import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

import '../Constants/assets.dart';

class SuccessfulContentWidget extends StatelessWidget {
  const SuccessfulContentWidget({
    super.key, required this.message,
  });
  final String message;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 2.w,
        vertical: 1.h,
      ),
      width: 60.w,
      height: 34.h,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: 50.w,
              height: 22.h,
              child:
              Lottie.asset(Assets.successAnimation, fit: BoxFit.fill),
            ),
            SizedBox(
              height: 2.h,
            ),
            Text(
              message ?? "Some Messages",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}