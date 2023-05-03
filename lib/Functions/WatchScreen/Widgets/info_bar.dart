import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class InfoBar extends StatelessWidget {
  const InfoBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 5.w,
        vertical: 2.h,
      ),
      height: 12.h,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ILLEGAL",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(
            height: 12.sp,
          ),
          Text(
            "NIRI 9 Originals . Episode 1 . Web Series",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}