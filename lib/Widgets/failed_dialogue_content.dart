import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

import '../Constants/assets.dart';

class FailedDialogContent extends StatelessWidget {
  const FailedDialogContent({
    super.key, required this.message,
  });
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 2.w,
        vertical: 1.h,
      ),
      width: 60.w,
      height: 36.h,
      child: Column(
        children: [
          SizedBox(
            width: 50.w,
            height: 25.h,
            child:
            Lottie.asset(Assets.failedAnimation, fit: BoxFit.fill),
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
    );
  }
}