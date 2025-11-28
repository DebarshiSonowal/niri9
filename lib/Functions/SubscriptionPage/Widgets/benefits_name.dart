import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BenefitsName extends StatelessWidget {
  const BenefitsName({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30.w,
      height: 48.h,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 4.h,
            child: Center(
              child: Text(
                "Features",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 8.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'All Content',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Movies, TV Series, Music Videos',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 8.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.tv,
                  color: Colors.white60,
                  size: 16.sp,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Watch On TV',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 8.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.block,
                  color: Colors.white60,
                  size: 16.sp,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Ad-Free',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 8.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.devices,
                  color: Colors.white60,
                  size: 16.sp,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Devices',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 8.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.hd,
                  color: Colors.white60,
                  size: 16.sp,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Video Quality',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
