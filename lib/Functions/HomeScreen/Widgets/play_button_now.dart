import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PlayNowButton extends StatelessWidget {
  const PlayNowButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 1.h,
      ),
      child: Center(
        child: Text(
          "Play Now",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}