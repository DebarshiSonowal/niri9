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
            // height:,
          ),
          SizedBox(
            width: double.infinity,
            height: 8.h,
            child: Text.rich(
              TextSpan(
                text: 'All Contents\n',
                children: <InlineSpan>[
                  TextSpan(
                    text: 'Movies, Tv Series, Music Video',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      color: Colors.white54,
                      fontSize: 10.sp,
                    ),
                  )
                ],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  // fontWeight: FontWeight.bold,
                  fontSize: 9.sp,
                ),
              ),
            ),
            // height:,
          ),
          SizedBox(
            width: double.infinity,
            height: 8.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Watch On TV',
                  style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    // fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
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
                Text(
                  'Ads Free',
                  style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    // fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
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
                SizedBox(
                  width: 30.w,
                  child: Text(
                    'Number of devices that can be logged in',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      color: Colors.white,
                      // fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                    ),
                    maxLines: 2,
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
                Text(
                  'Max Video Quality',
                  style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    // fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
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