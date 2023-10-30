import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ShareIndicator extends StatelessWidget {
  const ShareIndicator({
    super.key,
    required this.onTap,
  });

  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap(),
      child: SizedBox(
        width: 15.w,
        height: 5.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.share,
              size: 16.sp,
              color: Colors.white,
            ),
            Text(
              "Share",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontSize: 9.sp,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}